classdef FDChan < matlab.System
    % Frequency-domain multipath channel
    properties
        % Configuration
        carrierConfig;   % Carrier configuration
        
        % Path parameters
        gain;  % Path gain in dB
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
            
            % TODO:  Create complex path gain for each path
            %   obj.gainComplex = ...            
           
            % TODO:  Compute the Doppler shift for each path
            %    obj.fd = ...
            
            % Compute unit vector in direction of each path
            
            % TODO:  Compute the vector of 
            % symbol times relative to the start of the subframe
            %    obj.symStart = ...            
                                                   
        end
        
        
    end
    methods (Access = protected)
        
        
        function [rxGrid, chanGrid, noiseVar] = stepImpl(obj, txGrid, sfNum, slotNum)
            % Applies a frequency domain channel and noise
            %
            % Given the TX grid of OFDM REs, txGrid, the function
            % *  Computes the channel grid, chanGrid, given the 
            %    subframe number, sfNum, and slotNum, slotNum.
            % *  Computes the noise variance per symbol, noiseVar,
            %    for a target SNR
            % *  Applies the channel and noise to create the RX grid 
            %    of symbols, rxGrid.
            
            % TODO
 
        end
        
    end
end

