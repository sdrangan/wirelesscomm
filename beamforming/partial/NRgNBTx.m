classdef NRgNBTx < matlab.System
    % 5G NR gNB transmitter class    
    properties                
        carrierConfig;  % Carrier configuration         
        pdschConfig;     % Default PDSCH config
        waveformConfig;  % Waveform config
        
        % OFDM grids
        ofdmGridLayer;     % Before pre-coding nsc x nsym x nlayers       
        ofdmGridAnt;       % Before pre-coding nsc x nsym x nantennas        
        
        % OFDM grid to visualize the type of symbols
        ofdmGridChan;
               
        % Transmitted data in last slots
        bits;           % TX bits
        pdschSym;       % TX symbols
        dmrsSym;        % TX data symbols
        
        % Slot number
        Nslot = 0;
        
        % TX beamforming vector.  This is fixed.
        txBF;
            
    end
    
    properties (Constant)
        % Indices for ofdmGridChan indicating the type of symbol
        
        
    end
    
    methods
        function obj = NRgNBTx(simParam, varargin)
            % Constructor
           
            % Get parameters from simulation parameters
            % Many 5G Toolbox routines do not take classes, the 
            % objects need to be converted to older structures.
            obj.carrierConfig = nr.objtostruct( simParam.carrierConfig );
            obj.pdschConfig = nr.objtostruct( simParam.pdschConfig );
            obj.waveformConfig = nr.objtostruct( simParam.waveformConfig );
                                    
            % Set parameters from constructor arguments
            if nargin >= 1
                obj.set(varargin{:});
            end
                   
        
            
        end
    end
    methods (Access = protected)
    
        function x = stepImpl(obj)
            % step implementation.  Creates one slot of samples
            
            % Set the slot number if the PDSCH config
            obj.pdschConfig.Nslot = obj.Nslot;

            % Create the PDSCH grid before pre-coding
            obj.ofdmGridLayer = zeros(...
                obj.waveformConfig.NSubcarriers,...
                obj.waveformConfig.SymbolsPerSlot, ...
                obj.pdschConfig.NLayers);
            obj.ofdmGridChan = zeros(...
                obj.waveformConfig.NSubcarriers,...
                obj.waveformConfig.SymbolsPerSlot, ...
                obj.pdschConfig.NLayers);
            
            % Get information for PDSCH and DM-RS allocations
            [pdschIndices,dmrsIndices,obj.dmrsSym,pdschIndicesInfo] = ...
                nr.hPDSCHResources(obj.carrierConfig, obj.pdschConfig);
            
            % Generate random bits
            bitsPerSym = nr.NRConst.bitsPerSym(obj.pdschConfig.Modulation);
            nsym = length(pdschIndices);
            nbits = bitsPerSym * nsym;
            obj.bits = randi([0 1], nbits, 1);
            
            % Modulate the bits to symbols
            M = nr.NRConst.modOrder(obj.pdschConfig.Modulation);
            obj.pdschSym = qammod(obj.bits,M,'InputType','bit',...
                'UnitAveragePower',true);
            
            % Map symbols to OFDM grid
            obj.ofdmGridLayer(pdschIndices) = obj.pdschSym;
            obj.ofdmGridLayer(dmrsIndices) = obj.dmrsSym;
            
            
            % Fill the channel with labels of the channels.
            % This is just for visualization
            obj.ofdmGridChan(pdschIndices) = 1;
            obj.ofdmGridChan(dmrsIndices) = 2;    
            
            % Perform the OFDM modulation
            xlayer = nr.hOFDMModulate(obj.carrierConfig, obj.ofdmGridLayer);
            
            % TODO:  Perform the TX beamforming.  At this point, 
            % xlayer will be an nsamp x 1 vector.  Use the TX beamforming
            % vector, obj.txBF, to map this to a  nsamp x nant matrix
            % where nant is the number of TX antennas.
            %    x = ...
            
            
            % Increment the slot number
            obj.Nslot = obj.Nslot + 1;
            
            
        end        
      
    end
end

