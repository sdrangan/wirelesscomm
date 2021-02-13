%% In-Class Exercises for the Multi-Path Fading
% These problems are part of the multi-path fading lecture.
% You can complete each problem after the corresponding section in the 
% class.
%
% For each problem, complete the sections labeled TODO.  

%% Up and down-conversion, Problem 1
% Consider a system with the following parameters
bw = 20e6;    % bandwdith
pl = 80;      % path loss (dB)
tau = 200e-9;    % timing error

% TODO:  Plot the real component of the frequency response
% over the bandwidth.  Assume phase = 0 at DC.
% Use 1024 frequency points



%% Up and down-conversion, Problem 2
% Suppose a link has the following parameters:
fc = 37e9;  % carrier freq 
loppm = 1;  % LO error in ppm

% TODO:  Plot the relative change of the gain 
%
%     E(t) = |g(t)-g(t+tau)|^2 / |g(t)|^2 
%
% as a function of tau from 0 to 5 us


%% Discrete-time filter problem
% In this problem, we will show the effect of fractional
% delays on a TX constellation

% TODO:  Generate nb=1024 bits using the randi command.

% TODO:  Modulate the bits using QPSK with the qammod command
%
%     x = qammod(bits,...);
%
% Set the 'InputType' to 'bit' in the qammod command


% TODO:  Create a delay object
%    dly = dsp.VariableFractionalDelay(...)
% You can follow the demo

% TODO:  Shift the symbols x by delays 
%    tau = 10,10.1 and 10.5 samples

% TODO:  Plot the received constellations
% Use the subplot command so the constellations for the three
% delays occur on different windows

%% Computing an OFDM frequency response
% Consider a system with the following parameters.
% These paramters are similar to common configuration for 
% a 5G NR system used in the mmWave system
scs = 120e3;  % sub-carrier spacing
nsc = 12*60;  % number of sub-carriers
tsym = 1e-3/14/8;       % OFDM symbol period
nsym = 1000;  % number of symbols to plot

% Channel parameters
fc = 73e9;  % carrier frequency
v = 10;     % RX velocity in m/s
dly = [0,20,50]'*1e-9;   % Delay in sec of the paths
theta = [0,pi/4,pi]';    % Path AoA relative to motion
gaindB = [0,-3,-5]';     % gain of each path in dB

% Random initial phase of the gains
npath = length(dly);
phi = rand(npath,1)*2*pi;

% TODO:  Compute the Doppler shift of each path


% TODO:  Compute the OFDM channel H(k,n)


% TODO:  Plot the power 10*log10 |H(k,n)|^2.  
% Use the imagesc function. Label the axes across 
% time in ms and frequency in MHz












