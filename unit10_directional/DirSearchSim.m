classdef DirSearchSim < matlab.mixin.SetGetExactNames
    properties
        % TX and RX multi-array platforms
        tx, rx;
        
        % Search parameters
        NFFT;         % FFT size
        txPow;        % TX power in dBm
        fsamp;        % Sample rate
        noiseFig;     % Noise figure in dB
        
        % Path parameters
        aoaAz, aoaEl;
        aodAz, aodEl;
        pl;
        txPos;
        rxPos;
        dly;
        
        % Angular search parameters
        nangScan = 360;  % Number of scan angles
        azScan, elScan;  % Scan angles
        rxCwScan;        % RX codewords for scanning
        npaths = 5;      % Maximum number of paths to detect
                
        % Number of samples in delay to scan on each side of the max
        % delay
        dlyWin = 5;
        
        % Scan correlation 
        rho;
    end
    
    methods
        function obj = DirSearchSim(param)
            arguments
                param.NFFT = 1024
                param.tx MultiArrayPlatform
                param.rx MultiArrayPlatform
                param.txPow double = 23;
                param.fsamp double = 4e8;
                param.noiseFig double = 7;
                param.nangScan = 360;
            end
            
            % Set the parameters
            obj.NFFT = param.NFFT;
            obj.tx = param.tx;
            obj.rx = param.rx;
            obj.txPow = param.txPow;
            obj.fsamp = param.fsamp;
            obj.noiseFig = param.noiseFig;
            obj.nangScan = param.nangScan;
            
        end
        
        function setPathParams(obj, pathData, ind)
            % Set path parameters from the path data structure
            obj.txPos = pathData.txPos;
            obj.rxPos = pathData.rxPos(ind,:)';
            np = pathData.npaths(ind);
            obj.aoaAz = pathData.aoaAz(ind,1:np)';
            obj.aoaEl = pathData.aoaEl(ind,1:np)';
            obj.aodAz = pathData.aodAz(ind,1:np)';
            obj.aodEl = pathData.aodEl(ind,1:np)';
            obj.pl = pathData.pl(ind,1:np)';
            obj.dly = pathData.dly(ind,1:np)';
            
        end
        
        function h = chanResp(obj, params)
            % Compute the channel response with noise
            %
            % Returns an array h of size NFFT x nantRx x narrRx x ncwTx
            % where h(t,i,j,k) is the channel response at time sample t
            % RX antenna i, RX array j, and TX codeword k
            arguments
                obj
                params.txCwInd = 'all';
            end
            
            % Get dimensions
            nantRx = obj.rx.getNumElements();
            narrRx = obj.rx.getNumArrays();
            if strcmp(params.txCwInd,'all')
                ncwTx = obj.tx.getNumCW();
            else
                ncwTx = length(params.txCwInd);
            end
            
            % Initialize response array
            h = zeros(obj.NFFT,nantRx, narrRx, ncwTx);
            
            % Exit if there are no paths
            np = length(obj.pl);
            if np == 0
                return
            end
            
            % Compute the complex path gains on the TX paths for
            % beamforming
            gainTx = obj.tx.cwGain(obj.aodAz, obj.aodEl, ...
                params.txCwInd);
            ncwTx = size(gainTx,2);
            
            % Omni RX energy per sample per path
            Erx = obj.txPow - obj.pl - pow2db(obj.fsamp);
            phase = unifrnd(0,2*pi,np,1);
            gainOmni = db2mag(Erx).*exp(1i*phase);
            
            % Compute the RX spatial signature on the RX paths
            SvRx = obj.rx.step(obj.aoaAz, obj.aoaEl);
            
            % Compute the delay in samples.  There is a random
            % offset due to timing
            dlySamp = obj.dly*obj.fsamp + unifrnd(0,obj.NFFT,1,1);
            dlySamp = mod(dlySamp, obj.NFFT);
            
            % Add the paths
            t = (0:obj.NFFT-1)';
            for i = 1:np
                
                ht = sinc(t-dlySamp(i));
                ht = reshape(SvRx(:,i,:),1,nantRx,narrRx,1)...
                    .*reshape(ht,obj.NFFT,1,1,1)...
                    .*reshape(gainTx(i,:),1,1,1,ncwTx);
                h = h + ht*gainOmni(i);
            end
            
            % Add noise
            Enoise = db2pow(-174 + obj.noiseFig);
            h = h + sqrt(Enoise/2)*...
                (randn(size(h)) + 1i*randn(size(h)));
            
        end
        
        function hrx = chanRespRxCw(obj, h)
            % Finds the channel response along each RX codeword direction
            %
            % The input, h, is of size NFFT x nantRx x narrRx x ncwTx
            % where h(t,i,j,k) is the channel response at time sample t
            % RX antenna i, RX array j, and TX codeword k.  The output is
            % an array hrx(t,i,k) of the channel response at time sample t,
            % RX codeword i and TX codeword k.
            
            % Beam search along each TX and RX direction
            nantRx = size(h,2);
            ncwTx = size(h,4);
            ncwRx = obj.rx.getNumCW();
            hrx = zeros(obj.NFFT,ncwRx,ncwTx);
            
            for i = 1:ncwRx
                j = obj.rx.cwArrInd(i); % Array for this RX codeword
                w = obj.rx.codeWord(:,i);
                hi = sum(h(:,:,j,:).*reshape(w,1,nantRx,1,1), 2);
                hrx(:,i,:) = reshape(hi,obj.NFFT,1,ncwTx);
            end
        end
        
        function createScanCodebook(obj)
            % Creates the fine codewords for the angular scan
            
            % Set the angular scan.  Right now, we only search in the
            % azimuth direction
            obj.azScan = linspace(-179,180,obj.nangScan)';
            obj.elScan = zeros(obj.nangScan,1);
            
            % Get the steering vectors for each scan angle
            SvRx = obj.rx.step(obj.azScan , obj.elScan);
            SvRx = permute(SvRx, [1 3 2]);
            
            % Normalize
            SvNorm = sqrt(sum(abs(SvRx).^2,[1 2]));
            obj.rxCwScan = conj(SvRx)./SvNorm;
            
        end
        
        function pathEst = estimatePaths(obj, h, hrx)
            % Estimates path parameters
            %
            % h is the channel response from the chanResp() method
            % hrx is the channel response from the chanRespRxCw() method
            
            % Create the scan codebook
            if isempty(obj.rxCwScan)
                obj.createScanCodebook();
            end
            
            % Find the delay with the max energy
            [nfft, ncwRx, ncwTx] = size(hrx);
            hmagd = reshape(abs(hrx), nfft, ncwRx*ncwTx);
            [~, idly] = max(max(hmagd, [], 2));
            
            % Extract the components of the channel response around
            % the max delay
            i1 = max(1, idly-obj.dlyWin);
            i2 = min(nfft, idly+obj.dlyWin);
            hd = h(i1:i2,:,:,:);
            
            % Reshape the channel response to nelem*narr x ndly*ncwTx
            [ndly, nelem, narr, ncwTx] = size(hd);
            H = permute(hd, [2,3,1,4]);
            H = reshape(H, nelem*narr, ndly*ncwTx);
            
            % Take the SVD to find the low-rank decompositions
            % along the RX spatial directions
            [U, S, V] = svd(H, 'econ');
            
            % Reshape the arrays back
            lam = diag(S).^2;
            r = size(U,2);
            U = reshape(U, nelem, narr, r);
            V = reshape(V, ndly, ncwTx, r);
            
            % Set path parameters
            pathEst.aoaAz = zeros(obj.npaths,1);
            pathEst.aodAz = zeros(obj.npaths,1);
            pathEst.aoaEl = zeros(obj.npaths,1);
            pathEst.aodEl = zeros(obj.npaths,1);
            pathEst.dly = zeros(obj.npaths,1);
            pathEst.snr = zeros(obj.npaths,1);
            pathEst.peakFrac = zeros(obj.npaths,1);
            
            % Get the average variance
            hvar = mean(abs(h).^2, 'all');
            
            % Loop over paths
            for i = 1:obj.npaths
                
                % Find the correlation across the RX codewords in 
                % each array
                rhoi = sum(obj.rxCwScan .*reshape(U(:,:,i), nelem, narr, 1 ),1);
                
                % Add non-coherently across the arrays
                rhoi = sum(abs(rhoi).^2, 2);
                rhoi = squeeze(rhoi);
                                                
                % Find maximum along the RX direction
                [rhoMax, im] = max(rhoi);
                pathEst.snr(i) = rhoMax;
                pathEst.aoaAz(i) = obj.azScan(im);    
                pathEst.aoaEl(i) = obj.elScan(im);  
                
                % Find the maximum in the Tx and delay direction
                [Vmax, im] = max(abs(V(:,:,i)), [], 'all', 'linear');
                idly = mod(im-1,ndly)+1;
                pathEst.dly(i) = idly;
                
                % Get the max TX angle
                itx = floor((im-1) /ndly) + 1;
                pathEst.aodAz(i) = obj.tx.azCw(itx);
                pathEst.aodEl(i) = obj.tx.elCw(itx);
                
                % Convert to SNR
                obj.rho(:,i) = pow2db(rhoi*lam(i)*abs(Vmax)^2/hvar);
                pathEst.snr(i) = max(obj.rho(:,i));
                
                % Get the peakiness as a quality metric
                pathEst.peakFrac(i) = max(rhoi)/mean(rhoi);
            end                    
            
            % Subtract minimum delay
            pathEst.dly = pathEst.dly - min(pathEst.dly);
            
        end
        
    end
end