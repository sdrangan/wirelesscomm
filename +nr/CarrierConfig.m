classdef CarrierConfig < matlab.mixin.SetGet
    % Parameters for a single component carrier.
    % Current this does not support multiple bandwidth parts.
    % It should probably be reset to be an array of BWP configs
    properties 
        NRB = 51;                 % number of RBs
        CyclicPrefix = 'Normal';  % CP type
        SubcarrierSpacing = 120;  % SCS in kHz
        RBOffset = 0;             % Offset of the first RB
        fc = 28e9;                % Carrier frequency in Hz
    end
    
    methods        
        function obj = CarrierConfig(varargin)
            % Constructor
            
            % Set parameters from constructor arguments
            if nargin >= 1
                obj.set(varargin{:});
            end
        end        
    end
end

