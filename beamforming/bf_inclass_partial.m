%% In-Class Exercises for Beamforming
% These problems are part of the beamforming lecture.
% You can complete each problem after the corresponding section in the 
% class.
%
% For each problem, complete the sections labeled TODO.

%% Problem:  Simulating RX combining on QPSK symbols
% To illustrate RX combining, we do the following simple simulation
% of transmitting and receiving QPSK symbols with beamforming

% Consider an array with the following parameters
fc = 37e9;      % frequency
lambda = physconst('LightSpeed')/fc;
nant = [8,8];
dsep = 0.5*lambda;

% TODO:  Construct the URA with the above parameters
%   arr = ...

% TODO:  Generate nb=1e4 bits using the randi command.
%   bits = ...

% TODO:  Modulate the bits using QPSK with the qammod command
%
%     x = qammod(bits,...);
%
% Set the 'InputType' to 'bit' in the qammod command
% and the 'UnitAveragePower' to true


% Assume the angle of arrival, ang0 = [30; 45];
% TODO:  Compute the steering vector, u.
ang0 = [30; 45];

% TODO:  Compute the receive symbols.  This will be a matrix,
%  r0(:,i) = RX vector for TX symbol x(i).  
% Assume the path loss is 40 dB 
pathLoss = 40;

% TODO:  Add noise so that the SNR per antenna is 10 dB
%  r = r0 + noise
% Be careful how you scale noise! 


% TODO:  Compute the optimal BF vector.  This is the normalized
% steering vector

% TODO:  Compute the linear combined symbols, z.  

% TODO:  Plot the symbols before and after combining.
% -- subplot(1,2,1):  Plot the the constellation of r(1,:),
%    the receive symbols on the first antenna
% -- subplot(1,2,2):  Plot the the constellation of z,
%    the received symbols after beamforming


%% Problem:  Measuring the SNR with an BF error
% We will now:
% * Simulate symbols being received from a beam that is misaligned
%   to the angle of arrival
% * Compute the resulting SNR
% * Compare the SNR with the prediction from the array factor

% Using the array from above, generate the array 
% directed in the following angle that is slightly off from the
% true angle 
angbf = ang0 + [15; 15];  % 15 deg error in az and el

% TODO:  Compute, w = the BF vector for the angle angbf


% TODO:  Apply w to the RX symbols to get z.
% Convert z to a column vector and plot the symbols

% TODO:  Plot the constellations in z

%% 
% We next compute a channel estimate.  We suppose the 
% first nsymRef=100 symbols are known to the RX.  That is,
% they are reference symbols.  We know
%
%    z(i) = h x(i), i=1,...,nsymRef
%
% We can then estimate h from 
%
%    hhat = xref'*zref/(xref'*xref);
%
% where xref and zref are the TX and RX reference symbols.
% This formula is the LS estimates.  See the equalization section 
% in digital comm.

% TODO:  Compute the estimate hhat from the scalar equiv channel
nsymRef = 100;


% Now suppose the remaining symbols x(i), z(i), i=nsymRef,...,nsym
% are for data.  
% TODO:  Compute xdat, zdat, the TX and RX data symbols

% TODO:  Compute the equalized data symbols
%    xhatdat = zdat / hhat

% TODO:  Plot the equalized symbols

% TODO:  Measure the SNR after BF:
%  snrBF = 10*log10(Ex/Eerr)
%  Eerr = mean(abs(xdat-xhatdat).^2)
%  Ex = mean(abs(xdat).^2)

% TODO:  Compare to the expected SNR predicted by the 
% array factor

