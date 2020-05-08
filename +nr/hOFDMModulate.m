%hOFDMModulate 3GPP 5G OFDM modulation
%   [WAVEFORM,INFO] = hOFDMModulate(...) performs OFDM waveform processing
%   on an input resource element grid including IFFT calculation, cyclic
%   prefix insertion and optional windowing or filtering.In addition to
%   basic windowed CP-OFDM, it also supports W-OFDM (CP-OFDM with weighted
%   overlap and add (WOLA)) and F-OFDM (CP-OFDM with filtering) and the
%   windowing or filtering is applied in a cyclic fashion to give a
%   loopable waveform at the output for test and measurement applications.
%   By default, the DC subcarrier is used for data transmission.
%
%   [WAVEFORM,INFO] = hOFDMModulate(GNB,GRID) performs OFDM modulation
%   (optional DC subcarrier insertion, IFFT calculation, cyclic prefix
%   insertion and optional windowing, WOLA or filtering) of the complex
%   symbols in the resource array GRID. GRID is a 3-dimensional array of
%   resource elements for an arbitrary number of OFDM symbols across all
%   configured antenna ports. The antenna planes in GRID are separately
%   OFDM modulated to give the columns of WAVEFORM. Information about the
%   processing numerology is returned in the INFO structure (see <a
%   href="matlab: doc('hOFDMInfo')">hOFDMInfo</a>). If the input symbol
%   grid does not align with 1ms subframes for the associated numerology
%   then the NSymbol parameter should be used to specify the first symbol
%   number associated with the grid data.
%
%   GNB must be a structure including the following fields:
%   NRB               - Number of downlink/uplink resource blocks
%   CyclicPrefix      - Optional. Cyclic prefix length 
%                       ('Normal'(default),'Extended')
%   SubcarrierSpacing - Optional. Subcarrier spacing (kHz) (default 15)
%   NSymbol           - Optional. First symbol number within subframe (default 0)
%   UseDCSubcarrier   - Optional. Transmit data on the DC subcarrier 
%                       ('On'(default),'Off')
%   WaveformType      - Optional. Waveform OFDM type
%                       ('CP-OFDM'(default),'F-OFDM','W-OFDM')
%   Windowing         - CP-OFDM only. Optional. The number of time-domain 
%                       samples over which windowing and overlapping of 
%                       OFDM symbols is applied
%   Alpha             - W-OFDM only. Window roll off factor
%   WindowCoeffs      - W-OFDM only. Optional. Windowing function samples
%                       (defaults to root raised cosine window)
%   FilterLength      - F-OFDM only. Number of filter coefficients
%   ToneOffset        - F-OFDM only. Tone offset in subcarriers
%   CyclicExtension   - F-OFDM only. Optional. Cyclically extend the input
%                       for wraparound filtering ('On'(default),'Off')
%
%   Note that GRID need not contain integer multiples of the basic 1ms 
%   subframe grid. Windowing and overlapping or filtering is applied 
%   between all adjacent OFDM symbols, and also, cyclically wraps around 
%   between the first and last symbols. Therefore different overall
%   waveforms will result from the piece-wise concatenation of the output
%   segments (slots, sets of slots, subframes, frames etc) versus
%   concatenation of the input grids before processing. The concatenation
%   of the output segments will have discontinuities at the start/end of
%   each piece of the waveform. Therefore it is recommended that the number
%   of OFDM symbols in the input grid be maximized prior to calling
%   hOFDMModulate. Any use of <a href="matlab: doc('hOFDMDemodulate')">hOFDMDemodulate</a> to recover the resource
%   elements should be time aligned with the individual waveform segments
%   created by hOFDMModulate. If it possible to create a continuous 
%   time-domain output waveform by manually overlapping the grid data at 
%   the input to subsequent function calls. In the case of F-OFDM, it is 
%   also possible to stop the wraparound processing by setting the
%   CyclicExtension parameter to 'Off'.
%
%   [WAVEFORM,INFO] = hOFDMModulate(GNB,GRID,WINDOWING) allows control of
%   the number of windowed and overlapped samples used in the time-domain
%   windowing. This applies to CP-OFDM only.
%
%   See also hOFDMDemodulate, hOFDMInfo, hOFDMDemodulate.

%   Copyright 2018-2020 The MathWorks, Inc.

function [waveform,info] = hOFDMModulate(gnb,grid,varargin)

    if ~isfield(gnb,'NRB')
        if isfield(gnb,'NDLRB')
            gnb.NRB = gnb.NDLRB;
        elseif isfield(gnb,'NULRB')
            gnb.NRB = gnb.NULRB;
        end
    end

    if (~isnumeric(grid))
        error('The input resource grid must be a numeric array.');
    end

    % Get dimensionality information derived from the parameters
    info = nr.hOFDMInfo(gnb);
    % Cache the main dims
    nSC = info.NSubcarriers;
    nFFT = info.Nfft;
    cpLengths = info.CyclicPrefixLengths;
    symbolsPerSubframe = info.SymbolsPerSubframe;
    
    % Get dimensional information derived from the resource grid
    nSymbols = size(grid,2);
    nAnts = size(grid,3);
    
    % Initial symbol number of input wrt subframe
    initialsymbol = 0;  
    if isfield(gnb,'NSymbol')
        initialsymbol = mod(gnb.NSymbol,symbolsPerSubframe);
    end
    
    % Handle optional CP-OFDM windowing argument
    % N is the number of windowed samples
    if (nargin==3 && ~isempty(varargin{1}))
        N = varargin{1};
    else
        N = double(info.Windowing);
    end
    if (~isscalar(N))
        error('The Windowing parameter must be an even scalar integer.');
    end
    if (N>(nFFT-info.CyclicPrefixLengths(1)))
        error('For the Windowing parameter the value (%d) must be less than or equal to %d (the IFFT size (%d) minus the longest cyclic prefix length (%d))',N,nFFT-info.CyclicPrefixLengths(1),nFFT,info.CyclicPrefixLengths(1));
    end
    if (mod(N,2)~=0)
        error('For the Windowing parameter the value (%d) must be even.',N);
    end
    info.Windowing = N;
    
    % Index of first subcarrier in IFFT input
    firstSC = (nFFT/2) - (gnb.NRB*6) + 1;
    
    % Number of active subcarriers in IFFT
    if (~any(size(grid,1)==[0 nSC info.Nfft]))
        error('The input resource grid must contain a whole number of resource blocks i.e. number of rows must be an integer multiple of 12.');
    end
    
    % Handle various empty input cases
    if(size(grid,1)==0)
        nSymbols = 0;
    end
    if (nSymbols==0)
       head = 0;
       N = 0;
    end
    
    % Waveform dependent initialization
    wola = isfield(gnb,'WaveformType') && strcmpi(gnb.WaveformType,'W-OFDM');
    fofdm = isfield(gnb,'WaveformType') && strcmpi(gnb.WaveformType,'F-OFDM');
    % If F-OFDM then zero the amount of OFDM symbol windowing performed
    if fofdm
        info.Windowing = 0;
        N = 0;
    end
    
    % Should the DC subcarrier be used for transmission or not
    includezsc = ~(isfield(gnb,'UseDCSubcarrier') && strcmpi(gnb.UseDCSubcarrier,'Off'));
       
    % Some calculations still need this (those which worked with the number of frames associated with data)
    nSubframes = ceil(nSymbols/symbolsPerSubframe);
    
    if wola 
        
        % Perform W-OFDM specific initialization
        N1 = info.N1;               % Cyclic prefix part
        N2 = info.N2;               % Cyclic suffix part
        TL = nFFT + N1 + N2;        % Overall length of windowed W-OFDM symbol (not accounting for overlap - it's the window length)  
        % Pre-calculate windowing; there is a only a single window required since it's independent of the CP length
        if isfield(gnb,'WindowCoeffs') && ~isempty(gnb.WindowCoeffs)
            window0 = gnb.WindowCoeffs;
            if length(window0) ~= TL
                error('The W-OFDM window length must be equal to %d',TL);
            end
        else
            window0 = sqrt(raised_cosine_window(nFFT,N1+N2));        
        end  
        window1 = window0;      
        
        % Extension periods (CP and CS) for symbols
        exLengths = [N1*ones(size(cpLengths));N2*ones(size(cpLengths))];
               
        % Inter-symbol distances
        % Current stride length is the distance between the current symbol
        % and the start of the next one
        strideLengths = circshift(cpLengths,-1) + nFFT;
        
        % N1 + N2 is combined symbol extension
        % cpLength is required symbol extension 
        % Overlap is the amount of overlap required to achieve cpLength
        % Initialize starting position of first extended symbol in output waveform
        o = N1 + N2 - cpLengths(1);  % Overlap for first symbol in subframe: Positive if true overlap, negative if no overlap but instead an explicit gap between symbols
                    
        % Where to place the start of the first extended symbol       
        pos = -o;  % Start the first symbol output location such that there is none of the previous symbol present i.e. no overlap part
       
        % General calculation of the midpoint locations between consecutive symbols for any initial pos
        % The mid-point is in the middle of the overlap part 
        jumps = nFFT + fix((cpLengths)/2) + ceil(circshift(cpLengths,-1)/2);
        mp1 = pos + N1 - fix(cpLengths(1)/2) + 1;
        info.Midpoints = cumsum([mp1 repmat(jumps,[1 nSubframes])]);
        
        % Overlap between windowed, extended symbols
        info.WindowOverlap = N1+N2 - cpLengths;        
    
        % Re-adjust for the first actual symbol at the input
        pos = -(N1 + N2 - cpLengths(initialsymbol+1));
        
    else
        
        % Pre-calculate windowing; there are two different windows required:
        % one for the first OFDM symbol of a slot and one for other OFDM
        % symbols, because the first OFDM symbol of a slot has a different
        % cyclic prefix length.    

        % Window size will be nFFT + N + CP length
        window0 = raised_cosine_window(nFFT+cpLengths(1),N);
        window1 = raised_cosine_window(nFFT+cpLengths(2),N);
        
        % Extension periods (prefix, zero suffix) for symbols, accounting 
        % for any required for the windowing
        exLengths = [cpLengths+N; zeros(size(cpLengths))];

        % Inter-symbol distances
        % Current stride length is the distance between the current symbol
        % and the start of the next one
        strideLengths = cpLengths + nFFT;
        
        % Amount of overlap between extended symbols
        o = N;
   
        % Initialize starting position of first extended symbol in output waveform
        % With CP-OFDM, the windowing part will warp around into the end of
        % last symbol in the grid block
        pos = -N;
        
        % Midpoints between the extended symbols
        info.Midpoints = cumsum([1+pos+fix(o/2) repmat(strideLengths,[1 nSubframes])]); 
                   
        % Overlap between windowed, extended symbols           
        info.WindowOverlap = N*ones(size(cpLengths));
    
    end
      
    % Create storage for the returned waveform
    nsamples = sum(cpLengths(mod(initialsymbol + (0:nSymbols-1),symbolsPerSubframe)+1)) + nFFT*nSymbols;
    waveform = zeros(nsamples,nAnts);

    % Modulate each OFDM symbol of the resource grid
    for i = 1:nSymbols

        currentsymbol = initialsymbol+i-1;
        
        % Create IFFT input (map subcarriers)
        if (size(grid,1)==nFFT)
            ifftin = squeeze(grid(:,i,:));
        else
            ifftin = zeros(nFFT,nAnts);
            ifftin(firstSC+(0:nSC/2-1),:) = grid(1:nSC/2,i,:);
            ifftin(firstSC+nSC/2+(includezsc==0)+(0:nSC/2-1),:) = grid(nSC/2+1:end,i,:);
        end

        % Perform IFFT
        iffout = ifft(fftshift(ifftin,1));
            
        % Add cyclic extension to the symbol 
        exLength = exLengths(:,mod(currentsymbol,length(exLengths))+1);   % Extension lengths (CP/CS) for current symbol
        stride = strideLengths(mod(currentsymbol,length(strideLengths))+1);
        
        % Create extended symbol
        extended = [iffout(end-(exLength(1))+1:end,:); iffout; iffout(1:(exLength(2)),:)];
               
        % Perform windowing, using the appropriate window (first OFDM symbol
        % of half a subframe (0.5ms))
        if (mod(currentsymbol,symbolsPerSubframe/2)==0)
            windowed = extended .* window0;
        else
            windowed = extended .* window1;
        end

        % Perform overlapping and creation of output signal. Note that with
        % windowing the signal "head" gets chopped off the start of the
        % waveform and finally superposed on the end. This means the
        % overall signal can be seamlessly looped when output from an
        % arbitrary waveform generator
        if (i==1)
            % For the first OFDM symbol, chop the windowed "head" (which 
            % will be added to the final waveform end) and then output the
            % rest (rotate around the waveform)
            p = max(-pos,0);
            head = windowed(1:p,:);                 % Part of leading edge of extended symbol which overlaps with previous one (which here will be the last symbol)
            L = size(windowed,1) - size(head,1);    % Length of extended symbol which doesn't overlap with previous symbol
            p = max(pos,0);
            waveform(p+(1:L),:) = windowed(size(head,1)+1:end,:);  % Write non-overlapped (on leading edge) part of waveform to output                      
        else
            % For subsequent OFDM symbols, add the windowed part to the end
            % of the previous OFDM symbol (overlapping them) and then output
            % the rest; 'pos' points to the end of the previous OFDM symbol
            % i.e. the start of the current one, so merge it from N samples
            L = size(windowed,1);
            waveform(pos+(1:L),:) = waveform(pos+(1:L),:) + windowed;            
        end

        % Update 'pos' to point to the start of the next extended OFDM
        % symbol in the output waveform
        pos = pos + stride;         
    end

    % Finally, overlap the "head" with the very end of the signal
    waveform(end-size(head,1)+1:end,:) = waveform(end-size(head,1)+1:end,:) + head;
    
    % If W-OFDM then a final rotation is required to place the effective CP
    % of the first symbol at the beginning of the output waveform
    if wola
        waveform = circshift(waveform,N2,1);
        info.Midpoints = info.Midpoints + N2;
    end
    
    % If F-OFDM then filtering is required
    if fofdm 
        waveform = fofdm_filter(gnb,nFFT,waveform);
    end
    
end

% Raised Cosine window creation; creates a window function of length n+w
% with raised cosine transitions on the first and last 'w' samples, where
% 'w' is the "number of time-domain samples (at each symbol edge) over 
% which windowing and overlapping of OFDM symbols is applied" as described
% in the product help.
function p = raised_cosine_window(n,w)
    
    p = 0.5*(1-sin(pi*(w+1-2*(1:w).')/(2*w)));
    p = [p; ones(n-w,1); flipud(p)];
    
end

% Apply filtering to input waveform
function waveform = fofdm_filter(gnb,nFFT,waveform)
       
    % Manage the parameter set associated with the filter and resulting
    % coefficients to minimize the need to recreate them
    persistent existingConfig;
    persistent fnum;
    if isempty(existingConfig) 
        existingConfig = [-1 -1 -1];
    end
      
    % Half the filter length
    halfFilt = floor(gnb.FilterLength/2);
     
    % If there is a change to any of the filtering parameters then 
    % redesign the filter  
    currentConfig = [gnb.NRB, gnb.FilterLength, gnb.ToneOffset];

    if any(existingConfig ~= currentConfig)
        existingConfig = currentConfig;
       
        % Filter design  
        nSC = gnb.NRB*12;
        W = nSC;  % Number of data subcarriers

        n = -halfFilt:halfFilt;  

        % Sinc function
        pb = sinc((W+2*gnb.ToneOffset).*n./nFFT);

        % Sinc truncation window
        w = (0.5*(1+cos(2*pi.*n/(gnb.FilterLength-1)))).^0.6;

        % Normalized lowpass filter coefficients
        fnum = (pb.*w)/sum(pb.*w);
    end

    % If no cyclic extension required then just filter
    if isfield(gnb,'CyclicExtension') && strcmpi(gnb.CyclicExtension,'off')
        % Filter
        waveform = filter(fnum, 1, waveform);
    else       
        % Create a cyclic, 'loopable' waveform by cyclically extending the input,
        % filtering and then removing leading transient part
        ewaveform = [waveform(end-gnb.FilterLength:end,:); waveform];

        % Filter then realign
        efwaveform = filter(fnum, 1, ewaveform);
        waveform = efwaveform(end-size(waveform,1)+1:end,:);

        % Remove filter delay so that filtered OFDM symbols have the same
        % temporal alignment as other OFDM variants
        waveform = circshift(waveform,-halfFilt);    
    end
        
end

