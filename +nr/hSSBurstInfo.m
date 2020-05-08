%hSSBurstInfo Synchronization Signal burst (SS burst) information
%   INFO = hSSBurstInfo(BURST) creates burst information structure INFO
%   given burst configuration structure BURST.
%
%   See hSSBurst for a description of the fields of BURST and INFO.

%   Copyright 2018-2020 The MathWorks, Inc.

function info = hSSBurstInfo(burst)

    % Continue to support the older v15.2.0 RRC derived parameter name
    % 'DL_DMRS_typeA_pos' in this function, if present at the input
    pwarningstr = 'The %s parameter name is based on a pre-v15.3.0 version of the 3GPP NR standard. Use %s instead.';   
    if isfield(burst,'DL_DMRS_typeA_pos')
        burst.DMRSTypeAPosition = burst.DL_DMRS_typeA_pos;
        warning('nr5g:DMRSParametersRelease15',pwarningstr,'DL_DMRS_typeA_pos','DMRSTypeAPosition');
        burst = rmfield(burst,'DL_DMRS_typeA_pos');
    end
    
    % Get default values for unspecified parameters
    burst = provideDefaults(burst);
    
    % Get starting symbols of SS blocks in the half frame according to TS
    % 38.213 Section 4.1. The number of SS blocks is denoted L
    ssbStartSymbols = getStartSymbols(burst);
    L = length(ssbStartSymbols);
    
    % Get the half frame number of the SS burst
    n_hf = mod(burst.NHalfFrame,2);
    
    % If the SS burst should be inactive in this half frame according to
    % periodicity, zero the SSBTransmitted bitmap
    if (mod(fix(burst.NFrame)*10 + n_hf*5,burst.SSBPeriodicity)~=0)
        burst.SSBTransmitted(:) = 0;
    end
    
    % Get subcarrier spacing for SS burst
    burst.SubcarrierSpacing = getSSBSubcarrierSpacing(burst);
    
    % Calculate number of resource blocks in SS burst numerology needed to
    % achieve the appropriate sampling rate. The largest number of resource
    % blocks yielding the appropriate sampling rate is selected, in order
    % to maximize the flexibility of SS burst placement
    nfft = burst.SampleRate / (burst.SubcarrierSpacing * 1e3);
    burst.NRB = floor(nfft * 0.85 / 12);
    if (burst.NRB < 20)
        error('Maximum NRB supported by sample rate (%0.2f MHz) and SSB subcarrier spacing (%d kHz) is %d, but SSB requires at least NRB=20.',burst.SampleRate/1e6,burst.SubcarrierSpacing,burst.NRB);
    end
    
    % Calculate OFDM information
    burst.CyclicPrefix = 'Normal';
    ofdmInfo = hOFDMInfo(burst);
    
    % Validate FrequencyPointA
    k_freqPointA = burst.FrequencyPointA / (burst.SubcarrierSpacingCommon * 1e3);
    if (mod(k_freqPointA,1)~=0)
        error('FrequencyPointA must be an exact multiple of the common subcarrier spacing (%d kHz).',burst.SubcarrierSpacingCommon);
    end
    gridFreqSpan = burst.NRB * 12 / 2 * burst.SubcarrierSpacing * 1e3;
    if ((burst.FrequencyPointA < -gridFreqSpan) || (burst.FrequencyPointA > (gridFreqSpan - (burst.SubcarrierSpacingCommon * 1e3))))
        error('Resource grid (NRB = %d, spanning %0.3f .... %0.3f MHz) configured by sample rate (%0.2f MHz) and SSB subcarrier spacing (%d kHz) does not span frequency point A (%0.3f MHz).',burst.NRB,-gridFreqSpan/1e6,(gridFreqSpan - (burst.SubcarrierSpacing*1e3))/1e6,burst.SampleRate/1e6,burst.SubcarrierSpacing,burst.FrequencyPointA/1e6);
    end
    
    % Calculate NCRB_SSB, k_SSB and FrequencyOffsetSSB
    if (mod(burst.FrequencySSB,5e3)~=0)
        error('FrequencySSB must be an exact multiple of 5 kHz. Waveform center frequency is assumed to lie on the channel raster.');
    end
    ssbf0 = burst.FrequencySSB - (120 * burst.SubcarrierSpacing * 1e3);
    delta_f = ssbf0 - burst.FrequencyPointA;
    if (L==64)
        k_SSB_units = burst.SubcarrierSpacingCommon;
        NCRB_SSB_units = 60;
    else
        k_SSB_units = 15;
        NCRB_SSB_units = 15;
    end
    % NCRB_SSB is the CRB containing the first SSB carrier
    NCRB_SSB = floor(delta_f / (12 * NCRB_SSB_units * 1e3));
    delta_f = delta_f - (NCRB_SSB * 12 * NCRB_SSB_units * 1e3);
    % k_SSB is the offset between subcarrier 0 of CRB NCRB_SSB and the
    % first SSB subcarrier, k_SSB is signalled in the MIB
    k_SSB = floor(delta_f / (k_SSB_units * 1e3));
    kStep = burst.SubcarrierSpacing / k_SSB_units;
    delta_f = delta_f - ((k_SSB-mod(k_SSB,kStep)) * k_SSB_units * 1e3);
    % frequencyOffsetSSB is the part of the offset between the carrier and
    % SSB locations that is not a multiple of the SSB SCS
    frequencyOffsetSSB = delta_f;
    % For some parameter combinations, the frequency of the first SSB
    % subcarrier (ssbf0) will not be an integer multiple of the SSB SCS. In
    % this case, adjust the SSB frequency to lie on the SSB grid
    delta_f = mod(ssbf0,burst.SubcarrierSpacing * 1e3);
    ssbf0 = ssbf0 - delta_f;
    
    % Calculate offset to the subcarrier in the resource grid which 
    % represents SSB subcarrier k=0
    k0_offset = ofdmInfo.NSubcarriers/2 + (ssbf0 / (burst.SubcarrierSpacing * 1e3));
    if ((k0_offset < 0) || (k0_offset > (ofdmInfo.NSubcarriers - 240)))
        error('Resource grid (NRB = %d, spanning %0.3f ... %0.3f MHz) configured by sample rate (%0.2f MHz) and SSB subcarrier spacing (%d kHz) does not span SSB (%0.3f ... %0.3f MHz) configured by FrequencySSB (%0.3f MHz).',burst.NRB,-gridFreqSpan/1e6,(gridFreqSpan - (burst.SubcarrierSpacing*1e3))/1e6,burst.SampleRate/1e6,burst.SubcarrierSpacing,(burst.FrequencySSB - 120 * burst.SubcarrierSpacing *1e3)/1e6,(burst.FrequencySSB + 119 * burst.SubcarrierSpacing *1e3)/1e6,burst.FrequencySSB/1e6);
    end
    
    % Create Master Information Block (MIB) bit payload
    mib = zeros(24,1);
    SFN = dec2bin(fix(burst.NFrame),10)=='1';
    mib(2:7) = SFN(1:6);
    if (L==64)
        mib(8) = (burst.SubcarrierSpacingCommon == 120);
    else
        mib(8) = (burst.SubcarrierSpacingCommon == 30);
    end
    mib(9:12) = dec2bin(mod(k_SSB,16),4)=='1';
    mib(13) = (burst.DMRSTypeAPosition == 3);
    mib(14:21) = dec2bin(burst.PDCCHConfigSIB1,8)=='1';
    mib(22) = burst.CellBarred;
    mib(23) = burst.IntraFreqReselection;

    % Create information output
    info = struct();
    info.SubcarrierSpacing = burst.SubcarrierSpacing;
    info.NCRB_SSB = NCRB_SSB;
    info.k_SSB = k_SSB;
    info.FrequencyOffsetSSB = frequencyOffsetSSB;
    info.MIB = mib;
    info.L = L;
    info.SSBIndex = find(burst.SSBTransmitted) - 1;
    if (L==4)
        info.i_SSB = mod(info.SSBIndex,4);
        info.ibar_SSB = info.i_SSB + 4*n_hf;
    else
        info.i_SSB = mod(info.SSBIndex,8);
        info.ibar_SSB = info.i_SSB;
    end
    info.SampleRate = ofdmInfo.SamplingRate; 
    info.Nfft = double(ofdmInfo.Nfft);
    info.NRB = burst.NRB;
    info.CyclicPrefix = burst.CyclicPrefix;
    info.OccupiedSubcarriers = k0_offset + (1:240).';
    info.OccupiedSymbols = ((1:4).' + ssbStartSymbols(logical(burst.SSBTransmitted))).';
    info.Windowing = ofdmInfo.Windowing;
    if (isfield(ofdmInfo,'N1'))
        info.N1 = ofdmInfo.N1;
        info.N2 = ofdmInfo.N2;
    end
    
end

function scs = getSSBSubcarrierSpacing(burst)

    if (strcmpi(burst.BlockPattern,'Case A'))
        scs = 15;
    elseif (any(strcmpi(burst.BlockPattern,{'Case B','Case C'})))
        scs = 30;
    elseif (strcmpi(burst.BlockPattern,'Case D'))
        scs = 120;
    elseif (strcmpi(burst.BlockPattern,'Case E'))
        scs = 240;
    end

end

function ssbStartSymbols = getStartSymbols(burst)

    % 'alln' gives the overall set of SS block indices 'n' described in 
    % TS 38.213 Section 4.1, from which a subset is used for each Case A-E
    alln = [0; 1; 2; 3; 5; 6; 7; 8; 10; 11; 12; 13; 15; 16; 17; 18];
    
    L = length(burst.SSBTransmitted);
    
    cases = {'Case A' 'Case B' 'Case C' 'Case D' 'Case E'};
    m = [14 28 14 28 56];
    i = {[2 8] [4 8 16 20] [2 8] [4 8 16 20] [8 12 16 20 32 36 40 44]};
    nn = [2 1 2 16 8];
    
    caseIdx = find(strcmpi(burst.BlockPattern,cases));
    if (any(caseIdx==[1 2 3]))
        if (L==4)
            nn = nn(caseIdx);
        elseif (L==8)
            nn = nn(caseIdx) * 2;
        else
            error('For %s, the SSBTransmitted bitmap must be of length 4 or 8.',cases{caseIdx});
        end
    else
        if (L==64)
            nn = nn(caseIdx);
        else
            error('For %s, the SSBTransmitted bitmap must be of length 64.',cases{caseIdx});
        end
    end
    
    n = alln(1:nn);
    ssbStartSymbols = (i{caseIdx} + m(caseIdx)*n).';
    ssbStartSymbols = ssbStartSymbols(:).';
    
end

function burst = provideDefaults(burst)
    
    defaults.SSBTransmitted = [];
    defaults.SSBPeriodicity = 20;
    defaults.FrequencySSB = 0;
    defaults.FrequencyPointA = 0;
    defaults.DMRSTypeAPosition = 2;
    defaults.SubcarrierSpacingCommon = [];
    defaults.PDCCHConfigSIB1 = 0;
    defaults.CellBarred = 0;
    defaults.IntraFreqReselection = 0;
    defaults.DisplayBurst = false;
    defaults.NFrame = 0;
    defaults.NHalfFrame = 0;

    fields = fieldnames(defaults);
    for i = 1:numel(fields)
        field = fields{i};
        if (~isfield(burst,field))
            burst.(field) = defaults.(field);
        end
    end
    
    FR1 = any(strcmpi(burst.BlockPattern,{'Case A' 'Case B' 'Case C'}));
    
    if (isempty(burst.SSBTransmitted))
        % Default SSB-transmitted bitmap length from choices in TS 38.331
        % ServingCellConfigCommon IE ssb-PositionsInBurst
        if (FR1)
            % Short bitmap, for sub 3 GHz
            burst.SSBTransmitted = ones(1,4);
        else % FR2
            % Long bitmap, for above 6 GHz 
            burst.SSBTransmitted = ones(1,64);
        end
    end
    
    if (isempty(burst.SubcarrierSpacingCommon))
        if (FR1)
            burst.SubcarrierSpacingCommon = 15;
        else % FR2
            burst.SubcarrierSpacingCommon = 60;
        end
    end
    
end
