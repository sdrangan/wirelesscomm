classdef NRUERxFD < matlab.System
    % 5G NR UR receiver class implemented in frequency domain
    properties
        % Configuration
        carrierConfig;   % Carrier configuration
        pdschConfig;     % Default PDSCH config
        waveformConfig;  % Waveform config
        
        % OFDM grid
        rxGrid;
             
        % Channel estimation parameters
        sigFreq = 7;  % Channel smoothing in freq
        sigTime = 3;  % Channel smoothing in time
        lenFreq = 21;  % Filter length in freq
        Wtime; 
        
        % Test bit parameters
        bitsPerSym = 2;
        
        % Channel and noise estimate
        chanEstGrid;
        noiseEst;
        
        % RX symbols and estimated channel on the PDSCH
        pdschChan;
        pdschSym;
        
        
        % Received data in last slots
        pdschSymEq;    % Equalized PDSCH symbols
        rxBits;        % RX bits                    
        
    end
    methods
        function obj = NRUERxFD(carrierConfig, pdschConfig, ...
                varargin)
            % Constructor
            
            % Save the carrier and PDSCH configuration
            obj.carrierConfig = carrierConfig;
            obj.pdschConfig = pdschConfig;
            
            % Create the waveform configuration from the carrier
            % configuration
            obj.waveformConfig = nrOFDMInfo(obj.carrierConfig);
            
            % Set parameters from constructor arguments
            if nargin >= 1
                obj.set(varargin{:});
            end
                    
            
        end
        
        function chanEst(obj, rxGrid)
            % Computes the channel estimate
            
            % TODO:  Get the TX DM-RS symbols and indices
            %   dmrsSymTx = ...
            %   dmrsInd = ...
            
            % TODO:  Get RX symbols on the DM-RS
            %    dmrsSymRx = ...
            
            % TODO:  Get the raw channel estimate
            %   chanEstRaw = ...
                        
            % Get the symbol numbers and sub-carrier indices of the
            % DM-RS symbols from the DM-RS
            %   dmrsSymNum(i) = symbol number for the i-th DM-RS symbol
            %   dmrsScInd(i) = sub-carrier index for the i-th DM-RS symbol
            
            % TODO:  Get the list of all symbol numbers on which DM-RS was
            % transmitted.  You can use the unique command
            %   dmrsSymNums = unique(...);
            %   ndrmsSym = length(dmrsSymNums);

            % We first compute the channel and noise 
            % estimate on each of the symbols on which the DM-RS was 
            % transmitted.  We will store these in two arrays
            %   chanEstDmrs(k,i) = chan est on sub-carrier k in DM-RS
            %       symbol i
            %   noiseEstDmrs(i) = noise est for DM-RS symbol i
            chanEstDmrs = zeros(nsc, ndrmsSym);
            noiseEstDmrs  = zeros(ndrmsSym, 1);
            
            % Loop over the DM-RS symbols
            for i = 1:ndrmsSym
                
                % TODO:  Find the indices, k, in which the DM-RS
                % dmrsSymNum(k)= dmrsSymNum(i).
                %   I = find(...)                            
                
                % TODO:  Get the sub-carrier indices and raw channel 
                % channel estimate for these RS on the symbol
                %   ind = ...
                %   raw = ...
                
                % TODO:  Use kernelReg to compute the channel estimate
                % on that DM-RS symbol.  Use the lenFreq and sigFreq
                % for the kernel length and sigma.
                %    chanEstDmrs(:,i) = kernelReg(...)
                
                % TODO:  Compute the noise estimate on the symbol
                % using the residual method
                %    noiseEstDmrs(i) = ...
                
            end
            
            % TODO:  Find the noise estimate over the PDSCH by
            % averaging noiseEstDmrs
            %   obj.noiseEst = mean(...);         
                        
            % TODO:  Finally, we interpolate over time.
            % We will use an estimate of the form
            %    obj.chaneEstGrid = chanEstDrms*W
            % so that
            %    chanEstGrid(k,j) = \sum_i chanEstDmrs(k,i)*W(i,j)
            %
            % We use a kernel estimator
            %
            %     W(i,j) = W0(i,j) / \sum_k W0(k,j)
            %     W0(k,j) = exp(-D(k,j)^2/(2*obj.sigTime^2))
            %     D(k,j) = dmrsSymNum(k) - j
            %            
            
            % Save the time interpolation matrix
            obj.Wtime = W;                      
            
            % Create the channel estimate grid
            obj.chanEstGrid = chanEstDmrs*W;
            
        end
    end
    methods (Access = protected)
        
        
        function rxBits = stepImpl(obj, rxGrid, chanGrid, noiseVar)
            % Performs channel estimation, equalization and
            % symbol demodulation for one slot of data.
            %
            % Input
            % -----
            % rxGrid:  Received symbols in one slot
            % chanGrid:  Optional true channel estimate.
            % noiseVar:  Optional true noise variance
            %
            % If (chanGrid, noiseVar) are supplied the function skips
            % the channel estimate.  This is useful for testing a true
            % channel estimate without channel estimation error.            
            
            if nargin >= 3
                % Set the estimated channel and noise to the supplied
                % values if provided.
                obj.chanEstGrid = chanGrid;
                obj.noiseEst = noiseVar;
            else
                
                % Compute the channel and noise estimate
                obj.chanEst(rxGrid);
            end

            % Get indices on where the PDSCH is allocated
            pdschInd = nrPDSCHIndices(obj.carrierConfig, obj.pdschConfig);
            
            % TODO:  Get the PDSCH symbols and channel on the indicies 
            %   obj.pdschSym = ...
            %   obj.pdschChan = ...
            
            % TODO:  Perform the MMSE equalization
            %   obj.pdschSymEq
            
            % Demodulate the symbols
            M = 2^obj.bitsPerSym;
            rxBits = qamdemod(obj.pdschSymEq, M, 'OutputType', 'bit',...
                'UnitAveragePower', true);
        end
        
    end
end

