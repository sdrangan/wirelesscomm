classdef ElemWithAxes < matlab.System
    % ElemWithAxes:  An antenna element with a local frame of reference
    %
    % This class combines an antenna element from the phased array toolbox
    % along with a local coordinate system to facilitate geometric
    % computations.
    %
    % In addition, it provides smooth interpolation of the directivity
    % which is not performed in the phased array toolbox
    properties
        % The antenna object from the phased array toolbox
        ant = [];
        
        % Azimuth and elevation angle of the element peak directivity
        axesAz = 0;
        axesEl = 0;
        
        % Axes of the element local coordinate frame of reference
        axesLoc = eye(3);
        
        % Frequency in Hz
        fc = 28e9;
        
        % Directivity interpolant
        dirInterp = [];
        
        % Velocity vector in 3D in m/s
        vel = zeros(1,3);
    end
    methods
        function obj = ElemWithAxes(fc, ant)
            % Constructor
            % Inputs:  fc is the carrier frequency in Hz and ant is
            % an antenna compatible with the phased array toolbox.  It must
            % support the ant.pattern() method.
            
            % Set parameters
            obj.fc = fc;
            obj.ant = ant;
        end
        
        function alignAxes(obj,az,el)
            % Aligns the axes to given az and el angles
            
            % Set the axesAz and axesEl to az and el            
            obj.axesAz = az;
            obj.axesEl = el;
            
            % TODO:  Use the azelaxes() function to create a 3 x 3 array
            % corresponding to an orthonormal basis for the local
            % coordinate system of the array aligned in the direction
            % (az,el).  Save this in the axesLoc property.
            %    obj.axesLoc = azelaxes(...);
            obj.axesLoc = azelaxes(az,el);
        end
        
        function dop = doppler(obj,az,el)
            % Computes the Doppler shift of a set of paths
            % The angles of the paths are given as (az,el) pairs
            % in the global frame of reference.

            % Get the number of paths
            npath = length(el);
            
            % TODO:  Use the sph2cart method to find unit vectors in the
            % direction of each path.  That is, create an array where
            % u(:,i) is a unit vector in the angle (az(i), el(i)).
            % Remember to convert from degrees to radians!
            %    [u1,u2,u3] = sph2cart(...);
            %    u = [u1; u2; u3];             
            
            % TODO:  Compute the Doppler shift of each path from the
            % velocity vector, obj.vel.  The Doppler shift of path i is
            %     dop(i) = obj.vel*u(:,i)*fc/vc,
            % where vc = speed of light
            %   dop = ...;
     
            
        end
        
    end
    
    methods (Access = protected)
        
        function setupImpl(obj)
            % setup:  This is called before the first step.
            % We will use this point to interpolator
            
            % TODO:  Get the pattern from ant.pattern
            %     [dirPat,azPat,elPat] = obj.ant.pattern(...);
            
            % TODO:  Create the gridded interpolant object.  You can follow
            % the demo in the antennas lecture
            %     obj.dirInterp = griddedInterpolant(...)
                                   
            
        end
        function dir = stepImpl(obj, az, el)
            % Computes the directivity along az and el angles
            % The angles are given in the global frame of reference
            % We do this by first rotating the angles into the local axes
           
          
            
            % TODO:  Use the global2localcoord function to translate 
            % the gloabl angles (az(i), el(i)) into angles
            % (azLoc(i),elLoc(i)) in the local coordinate system.  use
            % the 'ss' option along with the local axes obj.axesLoc.
            %     uglobal = [ax; el; ones(1,length(az)];
            %     ulocal = lobal2localcoord(...);
            %     azLoc = ulocal(1,:);
            %     elLoc = ulocal(2,:);
            
            % TODO:  Run the interplationn object to compute the directivity
            % in the local angles
            %   dir = obj.dirInterp(...);
            
        end
        
        
    end
    
    
end

