%% Demo:  Spherical coordinates

% Generate four random points in 3D
X = randn(3,4);

% Compute spherical coordinates of a matrix of points
% Note these are in radians!
[az, el, rad] = cart2sph(X(1,:), X(2,:), X(3,:));

% Convert back
[x,y,z] = sph2cart(az,el,rad);
Xhat = [x; y; z];

%% Conversion to a new frame of reference

% Angles of new frame of reference 
% Note these are in degrees!
az1 = 0;
el1 = 45;

% Rotate to the new frame of reference 
% This takes row vectors!
X1 = cart2sphvec(X,az1,el1);
