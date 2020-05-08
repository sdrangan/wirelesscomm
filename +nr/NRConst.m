classdef NRConst < matlab.mixin.SetGet
    % NRUtil:  5G NR constants
    properties (Constant)
        % Dictionaries mapping modulation string to bits per sym and 
        % number of levels
        bitsPerSym = containers.Map(...
                {'QPSK', '8PSK', '16QAM', '64QAM', '256QAM'}, ...
                {2,3,4,6,8});
        modOrder = containers.Map(...
                {'QPSK', '8PSK', '16QAM', '64QAM', '256QAM'}, ...
                {4,8,16,64,256});               
    end
    
    methods
        function obj = NRConst()          
        end        
    end
end

