%hSSBurst Synchronization Signal burst (SS burst)
%   [WAVEFORM,GRID,INFO] = hSSBurst(BURST) creates an SS burst waveform
%   WAVEFORM and subcarrier grid GRID given burst configuration structure
%   BURST. Information on the burst structure and content is returned in
%   the structure INFO. The burst is generated according to TS 38.213
%   Section 4.1 and the SS/PBCH blocks within the burst are generated
%   according to TS 38.211 Section 7.4.3.
%
%   BURST must be a structure including the following fields:
%   BlockPattern            - SS block pattern, TS 38.213 Section 4.1
%                             ('Case A','Case B','Case C','Case D',
%                             'Case E'). Cases A - C are for Frequency 
%                             Range 1 (FR1), cases D and E are for FR2 (See
%                             TS 38.104 Tables 5.4.3.3-1 and 5.4.3.3-2)
%   NCellID                 - Physical layer cell identity (0...1007)
%   SampleRate              - Desired sample rate of burst waveform in Hz
%   NFrame                  - System Frame Number (0...1023) (default 0)
%   NHalfFrame              - Half frame number (0 or 1) (default 0)
%   SSBTransmitted          - Bitmap indicating blocks transmitted in the 
%                             burst (length 4 or 8 for FR1, 64 for FR2)
%                             (default ones(1,4) for FR1, ones(1,64) for
%                             FR2)
%   SSBPeriodicity          - Burst set periodicity in ms
%                             (5, 10, 20, 40, 80, 160) (default 20)
%   FrequencySSB            - Frequency of subcarrier #0 of RB #10 of the 
%                             SS block, relative to the center of the 
%                             waveform (default 0)
%   FrequencyPointA         - Frequency of Point A (TS 38.211 Section 
%                             4.4.4.2) of the carrier, relative to the 
%                             center of the waveform  (default 0)
%   DMRSTypeAPosition       - First DM-RS symbol position for SIB1 PDSCH 
%                             DM-RS (2 or 3) (default 2)
%   SubcarrierSpacingCommon - Subcarrier spacing for SIB1 in kHz
%                             (15 or 30 for FR1, 60 or 120 for FR2)
%                             (default 15 for FR1, 60 for FR2)
%   PDCCHConfigSIB1         - Configuration of SIB1 PDCCH 
%                             (TS 38.213 Section 13) (default 0)
%   CellBarred              - Indicates whether the cell allows UEs to camp
%                             on this cell (0 = not barred, 1 = barred)
%                             (default 0)
%   IntraFreqReselection    - Controls cell reselection to intra-frequency 
%                             cells (0 = not allowed, 1 = allowed)
%                             (default 0)
%   DisplayBurst            - Display burst layout plot (true or false)
%                             (default false)
%   WaveformType            - Optional. Waveform OFDM scheme
%                             ('CP-OFDM'(default),'W-OFDM','F-OFDM')
%   Windowing               - CP-OFDM only. Optional. The number of 
%                             time-domain samples over which windowing and
%                             overlapping of OFDM symbols is applied
%   Alpha                   - W-OFDM only. Window roll-off factor for 
%                             W-OFDM
%   WindowCoeffs            - W-OFDM only. Optional. Windowing function 
%                             samples (defaults to root raised cosine 
%                             window)
%   FilterLength            - F-OFDM only. Number of filter coefficients
%   ToneOffset              - F-OFDM only. Tone offset in subcarriers
%   CyclicExtension         - F-OFDM only. Optional. Cyclically extend the
%                             input for wraparound filtering 
%                             ('On'(default),'Off')
%
%   WAVEFORM is a T-by-1 matrix where T is the number of time domain
%   samples, equal to BURST.SampleRate * 0.005 as the burst waveform spans
%   half a frame.
%
%   GRID is a K-by-L matrix where K is the number of subcarriers and L is
%   the number of OFDM symbols. K = NRB * 12 where NRB is the maximum value
%   for which hOFDMInfo gives a sampling rate of BURST.SampleRate. L is the
%   number of OFDM symbols in half a frame.
%
%   INFO is a structure including the following fields providing
%   information on the SS burst:
%   SubcarrierSpacing   - Subcarrier spacing of the SS burst in kHz
%   NCRB_SSB            - The common resource block number which includes 
%                         the first subcarrier of the SS/PBCH block. For 
%                         FR1, NCRB_SSB is given in terms of 15 kHz 
%                         subcarrier spacing, for FR2 it is given in terms
%                         of 60 kHz subcarrier spacing (TS 38.211 Section 
%                         7.4.3.1)
%   k_SSB               - The offset in subcarriers (i.e. an integer number
%                         of subcarriers) between subcarrier 0 of common 
%                         resource block NCRB_SSB and the first subcarrier
%                         of the SS/PBCH block. For FR1 the unit of k_SSB
%                         is 15 kHz subcarriers, for FR2 it is the 
%                         subcarrier spacing given by  
%                         BURST.SubcarrierSpacingCommon (TS 38.211 Section
%                         7.4.3.1)
%   FrequencyOffsetSSB  - Frequency offset of the SSB not accounted for by
%                         NCRB_SSB or k_SSB. This includes offset due to
%                         channel versus sync raster and SSB versus RMSI 
%                         subcarrier spacing. In burst generation, this 
%                         offset will be implemented in the time domain
%   MIB                 - A 24-bit vector, the BCCH-BCH-Message, which 
%                         consists of a leading 0 bit then 23 bits 
%                         corresponding to the MIB. These 24 bits will be
%                         encoded on the BCH (along with 8 additional PBCH
%                         payload bits)
%   L                   - Number of SS/PBCH blocks per half frame
%   SSBIndex            - A vector containing the SS/PBCH block index for 
%                         each transmitted SS/PBCH block in the burst
%   i_SSB               - A vector containing LSBs (as an integer) of 
%                         the SS/PBCH block index for each transmitted 
%                         SS/PBCH block in the burst. The value is used to 
%                         initialize PBCH scrambling (TS 38.211 Section 
%                         7.3.3.1). For L=4 SS/PBCH blocks per half frame, 
%                         i_SSB contains the 2 LSBs of the SS/PBCH block 
%                         index. For L=8 or L=64, it contains the 3 LSBs
%   ibar_SSB            - A vector containing the PBCH DM-RS scrambling 
%                         initialization value for each transmitted SS/PBCH 
%                         block in the burst (TS 38.211 Section 7.4.1.4.1).
%                         For L=4 SS/PBCH blocks per half frame, ibar_SSB 
%                         equals i_SSB + (4*n_hf) where n_hf is the half
%                         frame number given by BURST.NHalfFrame. For L=8
%                         or L=64, ibar_SSB equals i_SSB
%   The following additional fields relate to the construction of the OFDM
%   resource grid and waveform representing the SS burst:
%   SampleRate          - The sample rate of the burst waveform, equal to 
%                         BURST.SampleRate
%   Nfft                - The number of FFT points used in the OFDM 
%                         modulator
%   NRB                 - The number of resource blocks used in the OFDM 
%                         modulator
%   CyclicPrefix        - The cyclic prefix length used in the OFDM
%                         modulator
%   OccupiedSubcarriers - The subcarriers occupied in the resource grid 
%                         (1-based)
%   OccupiedSymbols     - The OFDM symbols occupied in the resource grid 
%                         (1-based)
%   Windowing           - CP-OFDM only. The number of time-domain samples
%                         over which windowing and overlapping of OFDM 
%                         symbols is applied
%   N1                  - W-OFDM only. Number of samples in cyclic prefix
%   N2                  - W-OFDM only. Number of samples in cyclic suffix
%
%   Example:
%
%   % Configure parameters related to SS burst / blocks:
%   burst.BlockPattern = 'Case B';
%   burst.NCellID = 42;
%   burst.NFrame = 0;
%   burst.NHalfFrame = 0;
%   burst.SSBTransmitted = [1 1 1 0 1 1 1 1];
%   burst.SSBPeriodicity = 20;
%   burst.FrequencySSB = 0;
%
%   % Configure parameters related to SIB1 PDCCH and PDSCH:
%   burst.SampleRate = 30.72e6;
%   burst.FrequencyPointA = -600 * 15e3; 
%   burst.DMRSTypeAPosition = 2;
%   burst.SubcarrierSpacingCommon = 15;
%   burst.PDCCHConfigSIB1 = 0;
%
%   % Configure other parameters related solely to MIB content:
%   burst.CellBarred = 0;
%   burst.IntraFreqReselection = 0;
%   
%   % Enable displaying of burst layout:
%   burst.DisplayBurst = true;
%
%   % Generate burst:
%   [ssbWaveform,ssbGrid,ssbInfo] = hSSBurst(burst);

%   Copyright 2018-2020 The MathWorks, Inc.

function [waveform,grid,info] = hSSBurst(burst)
    
    % Get default values for unspecified parameters
    burst = provideDefaults(burst);
    
    % Get burst information
    info = hSSBurstInfo(burst);
    
    % Create resource grid for SS burst
    burst.NRB = info.NRB;
    burst.SubcarrierSpacing = info.SubcarrierSpacing;
    burst.CyclicPrefix = info.CyclicPrefix;
    ofdmInfo = hOFDMInfo(burst);
    grid = zeros([ofdmInfo.NSubcarriers ofdmInfo.SymbolsPerSubframe*5 1]);
    displaygrid = grid;
    
    % For each transmitted SS/PBCH block
    for i = 1:numel(info.SSBIndex)

        % Timing-related parameters for this SS/PBCH block
        SSBIndex = info.SSBIndex(i);
        i_SSB = info.i_SSB(i);
        ibar_SSB = info.ibar_SSB(i);
        
        % Create SS/PBCH block resource grid
        ssbGrid = zeros([240 4 1]);

        % PSS
        pss = nrPSS(burst.NCellID);
        pssInd = nrPSSIndices();
        ssbGrid(pssInd) = pss;

        % SSS
        sss = nrSSS(burst.NCellID);
        sssInd = nrSSSIndices();
        ssbGrid(sssInd) = sss;
        
        % PBCH DM-RS
        pbchDmrs = nrPBCHDMRS(burst.NCellID,ibar_SSB);
        pbchDmrsInd = nrPBCHDMRSIndices(burst.NCellID);
        ssbGrid(pbchDmrsInd) = pbchDmrs;
        
        % BCH
        if (info.L==64)
            idxoffset = SSBIndex;
        else
            idxoffset = info.k_SSB;
        end
        cw = nrBCH(info.MIB,fix(burst.NFrame),burst.NHalfFrame,info.L,idxoffset,burst.NCellID);
        
        % PBCH
        v = i_SSB;
        pbch = nrPBCH(cw,burst.NCellID,v);
        pbchInd = nrPBCHIndices(burst.NCellID);
        ssbGrid(pbchInd) = pbch;

        % Map SS/PBCH block to the burst
        occupiedSymbols = info.OccupiedSymbols(i,:);
        grid(info.OccupiedSubcarriers,occupiedSymbols,:) = ssbGrid;

        % Populate grid for displaying burst if requested
        if (burst.DisplayBurst)
            displayburst = zeros([240 4 1]);
            displayburst(pssInd) = 1;
            displayburst(sssInd) = 2;
            displayburst(pbchInd) = 3;
            displayburst(pbchDmrsInd) = 4;
            displaygrid(info.OccupiedSubcarriers,occupiedSymbols,:) = displayburst;
        end
        
    end

    % Modulate grid
    waveform = hOFDMModulate(burst,grid);
    
    % Apply time-domain frequency offset if required
    if (info.FrequencyOffsetSSB~=0)
        t = (0:size(waveform,1)-1).' / info.SampleRate;
        waveform = waveform .* exp(1i*2*pi*info.FrequencyOffsetSSB*t);
    end
    
    % Display burst if requested
    if (burst.DisplayBurst)
        displayBurst(burst,displaygrid);
    end
    
end

function displayBurst(burst,displaygrid)
    
    figure;
    
    [K,L] = size(displaygrid);
    imagesc(1:L,((1:K)-(K/2))*burst.SubcarrierSpacing/1e3,displaygrid);
    
    axis xy;
    ylabel('Frequency (MHz)');
    xlabel('OFDM symbols');
    title(sprintf('SS burst, block pattern = %s, SCS = %d kHz',burst.BlockPattern,burst.SubcarrierSpacing));
    
    hold on;
    for i = 1:4
        patch([-2 -3 -3 -2],[-2 -2 -3 -3],i);
    end
    legend('PSS','SSS','PBCH','PBCH DM-RS');
    
    drawnow;
    
end

function burst = provideDefaults(burst)
    
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
    
end
