classdef SISOMPChan < matlab.System
    % SISOMPChan:  SISO multi-path fading channel    
    properties 
        fsamp;   % Sample rate in Hz
                
        % Path properties
        gain;  % path gains in dB
        dly;   % delays in seconds
        dop;   % doppler shift of each path in Hz
        
        % Fractional delay object
        fracDly;
        
        % Initial set of phases for the next step call
        phaseInit;
                                
    end
    
    methods 
        function obj = SISOMPChan(opt)
            % Constructor:  
            arguments
                opt.fsamp (1,1) = 28e9;
                opt.gain (:,1) = 1;
                opt.dly (:,1) = 0;
                opt.dop (:,1) = 0;

            end

            % Check number of paths
            npath = length(opt.gain);
            if (length(opt.dly) ~= npath)
                error('gain and dly must have same number of elements');
            end
            if (length(opt.dop) ~= npath)
                error('gain and dop must have same number of elements');
            end                      

            % Set the parameters
            obj.fsamp = opt.fsamp;
            obj.gain = opt.gain;
            obj.dly = opt.dly;
            obj.dop = opt.dop;

            
        end
        
    end
    methods (Access = protected)
        function setupImpl(obj)
              % setup:  This is called before the first step.
              % For the SISO MP channel, we will use this point to
              % construct the fractional delay object.  
              
              % Creates the fractional delay object
              obj.fracDly = dsp.VariableFractionalDelay(...
                'InterpolationMethod', 'Farrow','FilterLength',8,...
                'FarrowSmallDelayAction','Use off-centered kernel',...
                'MaximumDelay', 1024);                           
        end
        
        function resetImpl(obj)
            % reset:  Called on the first step after reset or release.
            
            % Reset the fracDly object
            obj.fracDly.reset();
            
            % Initialize phases, phaseInit, to a row vector of 
            % dimension equal to the number of paths with uniform values 
            % from 0 to 2pi
            npath = length(obj.gain);
            obj.phaseInit = 2*pi*rand(1,npath);
        end
        
        function releaseImpl(obj)
            % release:  Called after the release method
            
            % Release the fracDly object
            obj.fracDly.release();
        end
        
        function y = stepImpl(obj, x)
            % step:  Run a vector of samples through the channel
            
            % Get the length of the signal
            nsamp = size(x,1);

            % TODO:  Compute the delay in samples for each path
            %    dlySamp = ...            
            
            % TODO:  Compute gain of each path in linear scale
            % from obj.gain.
            %    gainLin = ...
            
            
            % TODO:  Create a matrix xdly where xdly(:,k) is the 
            % signal x, delayed by dlySamp(k).  You can use the 
            % obj.fracDly object to perform the delay. The resulting
            % matrix, xdly, should be be nsamp x npath where 
            % nsamp = length(x).
            %     xdly = ...          
            
            
            % TODO:  Create a matrix phase where phase(i,k) is the phase
            % shift in radians on sample i of path k given by:
            %   phase(i,k) = obj.phaseInit(k) + 2*pi*obj.dop(k)*(i-1)/obj.fsamp
            % The matrix should be (nsamp+1) x npath 
            
            
            % Save the final phase, phase(nsamp+1,:)
            % as phaseInit for the next step.
            obj.phaseInit = phase(nsamp+1,:);
            
            % TODO:  Apply the phases and gain to each path, add the
            % paths and store the result in y.
            %   y = ...
            
            
        end
    end
end