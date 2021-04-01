
function [hest, w] = kernelReg(ind,hestRaw,nsc,len,sig)
% kernelReg:  Kernel regression with a RBF 

% Create the RBF kernel
w = exp(-0.5*(-len:len).^2/sig^2)';

% Place the raw channel esimates in a vector at the locations 
% of the indices.
%   y(ind(i))  = hestRaw(i) 
%   y0(ind(i)) = 1 
y = zeros(nsc,1);
y0 = zeros(nsc,1);
y(ind) = hestRaw;
y0(ind) = 1;

% Get the filter length
len = floor(length(w)/2);

% Filter both raw estimates and the indicators
[z1, z1f] = filter(w,1,y);
z1 = [z1(len+1:end); z1f(1:len)];
[z0, z0f] = filter(w,1,y0);
z0 = [z0(len+1:end); z0f(1:len)];

% Compute the channel estimate
hest = z1./max(1e-8,z0);
end

