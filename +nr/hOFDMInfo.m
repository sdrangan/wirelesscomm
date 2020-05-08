%hOFDMInfo OFDM modulation related information
%   INFO = hOFDMInfo(GNB) provides dimensional information related to the
%   OFDM modulation schemes implemented by <a href="matlab: doc('hOFDMModulate')">hOFDMModulate</a>. 
%   It also returns extended numerology information about the 1ms slot
%   structure across the range of subcarrier spacings as well as window
%   lengths for the W-OFDM scheme.
%  
%   The function returns the INFO structure given the following parameter
%   fields of the general link settings structure GNB:
%   NRB               - Number of downlink/uplink resource blocks
%   CyclicPrefix      - Optional. Cyclic prefix length 
%                       ('Normal'(default),'Extended')
%   Windowing         - CP-OFDM only. Optional. The number of time-domain 
%                       samples over which windowing and overlapping of 
%                       OFDM symbols is applied
%   SubcarrierSpacing - Optional. Subcarrier spacing (kHz) (default 15)
%   SymbolsPerSlot    - Optional. 7 or 14 symbols for Normal CP(default 14)
%                       12 symbols for Extended CP.
%   WaveformType      - Optional. Waveform OFDM scheme
%                       ('CP-OFDM'(default),'W-OFDM','F-OFDM')
%   Alpha             - W-OFDM only. Window roll-off factor for W-OFDM
%
%   The INFO output contains the fields:
%   SamplingRate        - The sampling rate of the OFDM modulator
%   Nfft                - The number of FFT points used in the OFDM 
%                         modulator
%   Windowing           - CP-OFDM only. The number of time-domain samples
%                         over which windowing and overlapping of OFDM 
%                         symbols is applied
%   CyclicPrefixLengths - Cyclic prefix length (in samples) of each OFDM 
%                         symbol in a 1ms subframe
%   SymbolLengths       - Symbol length (in samples) of each OFDM symbol
%                         in a 1ms subframe
%   NSubcarriers        - Number of subcarriers (NRB*12)
%   SubcarrierSpacing   - Subcarrier spacing (kHz)
%   SymbolsPerSlot      - Number of symbols per slot
%   SlotsPerSubframe    - Number of slots per 1ms subframe
%   SymbolsPerSubframe  - Number of symbols per 1ms subframe
%   SamplesPerSubframe  - Number of samples per 1ms subframe
%   SubframePeriod      - Subframe period (1ms)
%   N1                  - W-OFDM only. Number of samples in cyclic prefix
%   N2                  - W-OFDM only. Number of samples in cyclic suffix
%
%   The CyclicPrefixLengths output field gives the cyclic prefix lengths 
%   associated with all the OFDM symbols in a 1ms subframe. The CP lengths
%   are based on LTE which, for Nfft=2048 and 15kHz subcarrier spacing,
%   equal [160 144 144 144 144 144 144 160 144 144 144 144 144 144] for
%   normal CP and [512 512 512 512 512 512 512 512 512 512 512 512] for
%   extended CP. For other values of Nfft, these lengths are scaled by
%   Nfft/2048. As the subcarrier spacing doubles, according to 2^n, the 
%   number of OFDM symbols in a 1ms subframe will double too. All symbols
%   within 0.5ms have the same CP length, except for normal CP, where the
%   the first OFDM symbol every 0.5ms will be longer. In the case of 15 kHz
%   and a 2048 FFT, it is 16Ts compared to the other OFDM symbols.
%
%   If GNB.Windowing is absent, INFO.Windowing will return a default value
%   chosen as a function of GNB.NRB to compromise between the effective
%   duration of cyclic prefix (and therefore the channel delay spread
%   tolerance) and the spectral characteristics of the transmitted signal
%   (not considering any additional FIR filtering). This window parameter
%   is only relevant to the CP-OFDM scheme.
%  
%   If using the W-OFDM modulation, the amount of windowing is controlled
%   by the Alpha input parameter. In this case the N1 and N2 fields will
%   appear in the output structure, representing the length (in samples) 
%   of the cyclic prefix and suffix parts respectively. These lengths are
%   dependent on the FFT size only and independent of the inter-symbol 
%   CP lengths given in CyclicPrefixLengths.
%   
%   See also hOFDMModulate, hOFDMDemodulate.

%   Copyright 2018-2020 The MathWorks, Inc.

function info = hOFDMInfo(gnb)

    if ~isfield(gnb,'NRB')
        if isfield(gnb,'NDLRB')
            gnb.NRB = gnb.NDLRB;
        elseif isfield(gnb,'NULRB')
            gnb.NRB = gnb.NULRB;
        end
    end

    % Defaulting CyclicPrefix
    if ~isfield(gnb,'CyclicPrefix')
        gnb.CyclicPrefix = 'Normal';
    end 
    
    % Get baseline LTE CP-OFDM info (same functionality as lteOFDMInfo)
    info = lteNumerology(gnb);
    
    % Get parameters which affect the extended functionality
    scs = 15;
    symbolsperslot = length(info.CyclicPrefixLengths);
    
    if isfield(gnb,'SubcarrierSpacing')     % Subcarrier separation in kHz
        scs = gnb.SubcarrierSpacing;
    end
    if isfield(gnb,'SymbolsPerSlot')        % OFDM symbols per slot (7 or 14 symbols for NCP)
        symbolsperslot = gnb.SymbolsPerSlot;
    end
   
    % Extend the information fields and include NR aspects
    info.SymbolLengths = info.CyclicPrefixLengths + info.Nfft;
    info.NSubcarriers = gnb.NRB*12;
    info = nrNumerology(info,scs,symbolsperslot);
         
    % Calculate the CP/CS lengths for W-OFDM
    if isfield(gnb,'WaveformType')
        % Validate WaveformType parameter
        wset = {'CP-OFDM','W-OFDM','F-OFDM'};
        w = strcmpi(gnb.WaveformType,wset);
        if ~any(w)
            error('The waveform type (%s) is not one of the set (%s\b\b).',gnb.WaveformType,sprintf('%s, ',wset{:}));
        end 
        if w(2)   % W-OFDM case
            [info.N1, info.N2] = wofdminfo(info.Nfft,gnb.Alpha); 
        end
    end        
 
end

% W-OFDM windowing information
function [n1, n2] = wofdminfo(nfft,alpha)
    n1 = max(0,fix(alpha*(nfft/2)) - 1);
    n2 = n1 + 1;
end

% Generate the CP and frame numerology for the 1ms subframe
function info = nrNumerology(info,deltaf,slotduration)

    % 1ms subframe duration with 15kHz reference numerology 
    baseslotduration = length(info.CyclicPrefixLengths);
    if nargin == 2 || baseslotduration == 12
        slotduration = baseslotduration;
    else
        if nargin == 3 && all(slotduration~=[7,14])
            error('For normal cyclic prefix the number of symbols per slots (%d) must be 7 or 14.',slotduration);
        end
    end
   
    % Validate and process subcarrier spacing
    log2df = log2(deltaf/15);
    scsConfig = fix(log2df);
    if log2df < 0 || (scsConfig ~= log2df)
        error('The subcarrier spacing in kHz (%1g) must equal 15*(2^n), and n must be a non-negative integer in this function. Therefore valid values are 15,30,60,120,240 etc.',deltaf);
    end
    scsScale = 2^scsConfig;     % Scaling factor from the 15kHz reference
   
    % Scale OFDM sampling rate according to the subcarrier spacing   
    info.SamplingRate = info.Nfft * deltaf * 1000;
      
    % Copy subcarrier spacing value to the output
    info.SubcarrierSpacing = deltaf;
    
    % Scale the basic slot numerology relative to the 15kHz reference
    info.SymbolsPerSlot = slotduration;
    info.SlotsPerSubframe = fix(14/slotduration) * scsScale;
    info.SymbolsPerSubframe = info.SymbolsPerSlot * info.SlotsPerSubframe;
   
    % Scale the cyclic prefix lengths, relative to the 15kHz reference, where,
    % for normal CP, the first OFDM symbol per 0.5ms (half subframe) will be longer
    xcp = info.CyclicPrefixLengths(end)*ones(1,info.SymbolsPerSubframe,class(info.CyclicPrefixLengths));
    xcp([1 1+length(xcp)/2]) = scsScale*info.CyclicPrefixLengths(1) - (scsScale-1)*info.CyclicPrefixLengths(2);   
    info.CyclicPrefixLengths = xcp;
    info.SymbolLengths = xcp + info.Nfft;
    
    info.SamplesPerSubframe = sum(info.CyclicPrefixLengths) + info.SymbolsPerSubframe*info.Nfft;
    info.SubframePeriod = double(info.SamplesPerSubframe) / info.SamplingRate;
    
end

% lteOFDMInfo functionality (LTE baseline numerology with any NRB)
function info = lteNumerology(enb)

    % Valid the parameters
    if ~any(strcmpi(enb.CyclicPrefix,{'Extended', 'Normal'}))
        error('The cyclic prefix type must be one Normal or Extended');
    end
  
    % Get FFT size (allowing NRB > 110)
    nFFT = power(2,ceil(log2(enb.NRB*12/0.85)));
    nFFT = max(128,nFFT);
    
    info.SamplingRate = nFFT * 15e3;
    info.Nfft = nFFT;

    ecp = strcmpi(enb.CyclicPrefix,'Extended');
     
    % The number of window samples is chosen in accordance with the maximum
    % values implied by TS 36.101, Tables F.5.3-1, and F.5.4-1.
    if (isfield(enb,'Windowing') && ~isempty(enb.Windowing))
        w = enb.Windowing;
    else
        w = 0;
        if (ecp)
            switch (nFFT)
                case 128
                    w = 4;
                case 256
                    w = 6;
                case 512
                    w = 4;
                case 1024
                    w = 6;
                case 2048
                    w = 8;
            end
        else
            switch (nFFT)
                case 128
                    w = 4;
                case 256
                    w = 6;
                case 512
                    w = 4;
                case 1024
                    w = 6;
                case 2048
                    w = 8;
            end
        end
        if w==0
            % Additional rule for other FFT sizes
            w = max(0,8-2*(11-(log2(nFFT))));  
        end
    end    
    info.Windowing = w;
      
    % CP lengths for 2048 point FFT per LTE slot (6 or 7 symbols)
    if ecp
        cpLengths = [512 512 512 512 512 512];
    else
        cpLengths = [160 144 144 144 144 144 144];
    end
    
    % Scale according to the FFT size and repeat the slots for a LTE subframe
    info.CyclicPrefixLengths = repmat(cpLengths*double(nFFT)/2048,1,2);
    
end