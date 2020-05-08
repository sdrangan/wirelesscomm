classdef PDSCHConfig < matlab.mixin.SetGet
    % Parameters for a single PDSCH parameters
    properties 
        Nslot = 0;      % Slot number
        PRBSet = (0:0); % Set of PRBs 
        SymbolSet = (0:13);  % Set of symbols
        PortSet = (0);   % Set of ports for the transmission
        NLayers = 1;     % Total number of layers
        pdschParamMappingType = 'A';     % pdschParam mapping type ('A'(slot-wise),'B'(non slot-wise))
        DMRSTypeAPosition = 2;      % Mapping type A only. First DM-RS symbol position (2,3)
        DMRSLength = 1;             % Number of front-loaded DM-RS symbols (1(single symbol),2(double symbol))
        DMRSAdditionalPosition = 0; % Additional DM-RS symbol positions (max range 0...3)
        DMRSConfigurationType = 2;  % DM-RS configuration type (1,2)
        NumCDMGroupsWithoutData = 1;% Number of CDM groups without data
        NIDNSCID = 1;               % Scrambling identity (0...65535)
        NSCID = 0;                  % Scrambling initialization (0,1)
            
        % Reserved PRB patterns (for CORESETs, forward compatibility etc)
        % Array of reservations, each reservations should have entries
        %   res.Symbols:  Reserved PDSCH symbols
        %   res.PRB:      Reserved PDSCH PRBs
        %   res.Period:   Periodicity of reserved resources
        Reserved = [];
        %ReservedSymbols = [];      % Reserved PDSCH symbols
        %ReservedPRB = [];          % Reserved PDSCH PRBs
        %ReservedPeriod = [];       % 
        % PDSCH resource block mapping (TS 38.211 Section 7.3.1.6)
        VRBToPRBInterleaving = 0;   % Disable interleaved resource mapping
        Modulation = 'QPSK';          
    end
    
    methods        
        function obj = PDSCHConfig(varargin)
            % Constructor
            
            % Set parameters from constructor arguments
            if nargin >= 1
                obj.set(varargin{:});
            end
        end        
    end
end

