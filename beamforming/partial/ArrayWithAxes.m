classdef ArrayWithAxes < matlab.System
    % ArrayWithAxes.  Class containing an antenna array and axes.
    properties
        
        fc = 28e9;  % Carrier frequency
        
        % Element within each array.  Empty indicates to use an
        % isotropic element.  If non-empty, the object must be derived
        % from the matlab.System class with a step method
        %    dir = elem.step(fc,az,el)
        % that provides the directivity in dBi as a function of the
        % frequency and angles (az,el)
        elem = [];
        
        % Antenna array.  Empty indicates that there is only one element
        arr = [];
        
        % Steering vector object
        sv = []; 
        
        % Azimuth and elevation angle of the element peak directivity
        axesAz = 0;
        axesEl = 0;
        
        % Axes of the element local coordinate frame of reference
        axesLoc = eye(3);
        
        % Velocity vector in 3D in m/s
        vel = zeros(1,3);
    end
    
    methods
        function obj = ArrayWithAxes(varargin)
            % Constructor
            
            % Set key-value pair arguments
            if nargin >= 1
                obj.set(varargin{:});
            end
        end
                
        function alignAxes(obj,az,el)
            % Aligns the axes to given az and el angles
            
            % Set the axesAz and axesEl to az and el
            obj.axesAz = az;
            obj.axesEl = el;
            
            % Creates axes aligned with az and el
            obj.axesLoc = azelaxes(az,el);
        end
        
        function dop = doppler(obj,az,el)
            % Computes the Doppler shift of a set of paths
            % The angles of the paths are given as (az,el) pairs
            % in the global frame of reference.
            
            % Finds unit vectors in the direction of each path
            npath = length(el);
            [u1,u2,u3] = sph2cart(deg2rad(az),deg2rad(el),ones(1,npath));
            u = [u1; u2; u3];
            
            % Compute the Doppler shift of each path via an inner product
            % of the path direction and velocity vector.
            vcos = obj.vel*u;
            vc = physconst('lightspeed');
            dop = vcos*obj.fc/vc;            
            
        end
        
        function releaseSV(obj)
            % Creates the steering vector object if it has not yet been
            % created.  Otherwise release it.  This is needed since the 
            % sv object requires that it takes the same number of 
            % inputs each time.
            if isempty(obj.sv)
                obj.sv = phased.SteeringVector('SensorArray',obj.arr);
            else
                obj.sv.release();
            end
            
        end
        
       
    end
    
    methods (Access = protected)
        
        function setupImpl(obj)
            % setup:  This is called before the first step.
            
            % TODO: Create the steering vector object using the
            % array. 
            %    obj.sv = ...
            
        end
        
        function releaseImpl(obj)
            % release:  Called to release the object
            obj.elem.release();
            obj.sv.release();
        end
        
       function [u, elemGain] = stepImpl(obj, az, el)
            % Gets steering vectors and element gains for a set of angles
            % The angles az and el should be row vectors along which
            % the outputs are to be computed.  
            
            % Release the SV
            obj.releaseSV();
            
            % TODO:  Convert the global angles (az, el) to local
            % angles (azLoc, elLoc).  Use the 
            % global2localcoord() method with the 'ss' option.
            
            
            % TODO: Get the SV in the local coordinates
            %    u = obj.sv(...)
            
                        
            % TODO:  Get the directivity gain of the element from the
            % local angles.
            %    elemGain = obj.elem.step(...) 
            
        end

    end
    
    
end

