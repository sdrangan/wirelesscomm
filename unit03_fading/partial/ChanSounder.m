classdef ChanSounder < matlab.System
    % TX and RX channel sounder class

    properties
        
        nfft;  % number samples per frames
        seed;  % random generator seed 
        nframesTx;   % number of TX frames 

        x0fd;  % one frame of the frequency-domain TX signal
        x0;    % one frame of the time-domain TX signal


 
    end

    methods
        function obj = ChanSounder(opt)
            % Constructor

            arguments
                opt.nfft (1,1) {mustBeInteger} = 1024;
                opt.nframesTx (1,1) {mustBeInteger} = 32;
                opt.seed = 'default';
            end

            % Set the parameters
            obj.nfft = opt.nfft;    
            obj.nframesTx = opt.nframesTx;    
            obj.seed = opt.seed;

         
        end

        function xtx = getTx(obj)
            % Creates a random transmit sounding signal
            % 
            % Outputs
            % ------
            % xtx:  A complex sequence of length nframesTx * nfft
                        

            % Set the random seed so that the TX and RX will have the 
            % same seqeuence
            rng(obj.seed);

            % TODO:  Use the qammod function to create nfft random QPSK symbols.
            % Store the symbol values in a column vector obj.x0fd
            %   obj.x0fd = ...
            

            % TOOD:  Create the time-domain signal in one frame 
            % by taking the IFFT of obj.x0fd.
            %     obj.x0 = ...
            


            % TODO:  Use the repmat command to repeat the TX signal 
            % obj.x0 obj.nframesTx times and output the signal in xtx.  
            % Since obj.x0 is obj.nfft  samples long, the resulting signal
            % xtx should be obj.nfft * obj.nframesTx long.
            %   xtx = ...            
        end

        function [hest, hestFd] = getChanEst(obj, y)
            % Estimates the time-varying channel
            %
            % Inputs
            % ------
            % r:  nfft*nframe length RX signal
            %
            % Outputs
            % -------
            % hestFd:  nfft x nframe matrix of the frequency-domain channel
            %    in each frame
            % hestTd:  Time-domain version of the channel

            % Compute the number of RX frames
            nframeRx = floor(length(y) / obj.nfft);

            % Reshape y into a nfft x nframes matrix
            ymat = reshape(y, obj.nfft, nframeRx);

            % TODO:  Take the FFT of each column of ymat and store in yfd
            %  yfd = ...
            
            
            % TODO:  Estimate the frequency domain channel by dividing each frame of
            % yfd by the transmitted frequency domain symbols x0Fd.  Store the results
            % in hestFd
            %   hestFd = ...
            

            % TODO:  Estimate the time-domain channel by taking the IFFT
            % of each column of hestFd
            %   hest = ...
            



        end       
            

    end



end

