function [tx,rx] = plutoCreateTxRx(options)
% plutoCreateTxRx:  Creates TX and RX objects for the ADALM-Pluto
% 
% Parmaters
% ----------
% createTx:  Indicates if TX is to be created.  Otherwise, tx = []
% createRx:  Indicates if RX is to be created.  Otherwise, rx = []
% loopback:  Run TX and RX on same device.  
% sampleRate:  Baseband sample rate in Hz.
% nsampsFrame:  Number of samples per frame for RX.
% centerFrequency:  Center frequency in Hz
%
% Returns
% -------
% tx:  TX SDR object.  Set to [] if ~createTx.
% rx:  RX SDR object.  Set to [] if ~createRx

arguments
    options.createTx (1,1) {boolean} = true;
    options.createRx (1,1) {boolean} = true;
    options.loopback (1,1) {boolean} = false;
    options.sampleRate (1,1) double = 30.72e6;  
    options.nsampsFrame (1,1) int32 = 2^12;
    options.centerFrequency (1,1) double = 2.4e9;
end


% Find devices and validate that at least one Pluto found
devs = findPlutoRadio();
ndevs = length(devs);
if ndevs == 0
    error('No Pluto devices found');
end

% Get IDs for TX and RX
if (options.createRx && options.createTx && ~options.loopback)
    if (ndevs ==0)
        error('No Plutos found.  Non-loopback requires two devices');
    elseif (ndevs == 1)
        error('Only one Pluto found.  Non-loopback requires two devices');
    end
    disp('Two Pluto devices found');

    idtx = devs(1).RadioID;
    idrx = devs(2).RadioID;
else
    disp('Pluto device found');
    if (options.createRx)
        idrx = devs(1).RadioID;
    end
    if (options.createTx)
        idtx = devs(1).RadioID;
    end   
end

% Create the SDR TX object
if options.createTx
    tx = sdrtx('Pluto','RadioID',idtx,'BasebandSampleRate', options.sampleRate,...
        'CenterFrequency',options.centerFrequency);
    disp('Successfully created TX object');
else
    tx = [];
end

% Create the SDR RX object
if options.createRx
    rx = sdrrx('Pluto','RadioID',idrx,'BasebandSampleRate', options.sampleRate, ...
        'SamplesPerFrame', options.nsampsFrame, ...
        'CenterFrequency',options.centerFrequency);
    disp('Successfully created RX object');
else
    rx = [];
    
end
end
