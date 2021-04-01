classdef FDChan < matlab.System
    % Frequency-domain multipath channel
    properties
        % Configuration
        carrierConfig;   % Carrier configuration
        waveformConfig;  % Waveform parameters
                
        
        % Path parameters
        gain;  % Relative path gain in dB
        dly;   % Delay of each path in seconds  
        aoaAz, aoaEl; % Angle of arrival of each path in degrees      
        fd;    % Doppler shift for each path
        
        rxVel = [30,0,0]';  % Mobile velocity vector in m/s
        fc = 28e9;    % Carrier freq in Hz        
                
        gainComplex;  % Complex gain of each path
        
        % SNR parameters
        Etx = 1;       % average energy per PDSCH symbol 
        EsN0Avg = 20;  % Avg SNR per RX symbol in dB
       
        % Symbol times
        symStart;  % symStart(i) = start of symbol i relative to subframe
                     
    end
    methods
        function obj = FDChan(carrierConfig, varargin)
            % Constructor
            
            % Save the carrier configuration
            obj.carrierConfig = carrierConfig;
                                 
            % Set parameters from constructor arguments
            if nargin >= 1
                obj.set(varargin{:});
            end
            
            % Complex gain for each path using a random initial phase
            % The gains are normalized to an average of one
            npath = length(obj.gain);
            phase = 2*pi*rand(npath, 1);
            obj.gainComplex = db2mag(obj.gain).*exp(1i*phase);
            obj.gainComplex = obj.gainComplex / norm(obj.gainComplex);
            
          
            % Symbol times relative to the start of the subframe       
            obj.waveformConfig = nrOFDMInfo(obj.carrierConfig);
            nsym = obj.waveformConfig.SymbolLengths;
            obj.symStart = nsym/obj.waveformConfig.SampleRate;
            obj.symStart = cumsum([0 obj.symStart]');      
            
            % Compute unit vector in direction of each path
            [ux, uy, uz] = sph2cart(deg2rad(obj.aoaAz), deg2rad(obj.aoaEl), 1);
                        
            % Get Doppler shift
            vc = physconst('Lightspeed');
            obj.fd = [ux uy uz]*obj.rxVel*obj.fc/vc;    
                                                   
        end
        
        
    end
    methods (Access = protected)
        
        
        function [rxGrid, chanGrid, noiseVar] = stepImpl(obj, txGrid, frameNum, slotNum)
            % Applies a frequency domain channel and noise
            %
            % Parameters
            % ----------
            % txGrid:  The OFDM grid of TX symbols for one slot
            % frameNum:  The index of the frame  (1 frame = 10ms)
            % slotNum:  The index of the slot in the frame 
            %    This should be 0,...,waveformConfig.SlotsPerFrame
            %
            % Outputs
            % -------
            % rxGrid:  RX grid of RX symbols for one slot
            % chanGrid:  Grid of the channel values
            % noiseVar:  Noise variance
            
            % Get dimensions of the TX grid
            [nsc, nsym] = size(txGrid);
            
            % Compute the frequency of each carrier 
            f = (0:nsc-1)'*obj.carrierConfig.SubcarrierSpacing*1e3;
            
            % Compute slot in sub-frame and sub-frame index
            sfNum = floor(slotNum / obj.waveformConfig.SlotsPerSubframe);
            slotNum1 = mod(slotNum, obj.waveformConfig.SlotsPerSubframe);
            
            % Compute the time for each symbol
            framePeriod = 0.01;
            sfPeriod = 1e-3;
            t = frameNum*framePeriod + sfPeriod*sfNum + ...
                obj.symStart(slotNum1+1:slotNum1+nsym);
            
            % Generate the channel
            chanGrid = zeros(nsc, nsym);
            npath = length(obj.gain);
            for i = 1:npath
                phase = 2*pi*(f*obj.dly(i) + t'*obj.fd(i));
                chanGrid = chanGrid + obj.gainComplex(i)*exp(1i*phase);
            end
            
            % Compute noise variance
            Erx = sum(abs(obj.gainComplex).^2,'all')*obj.Etx;            
            noiseVar = Erx * db2pow(-obj.EsN0Avg);                                     
            
            % Apply channel
            rxGrid = chanGrid.*txGrid;
            
            % Add noise
            w = (randn(nsc,nsym) + 1i*randn(nsc,nsym))*sqrt(noiseVar/2);
            rxGrid = rxGrid + w;
                                                
        end
        
    end
end

