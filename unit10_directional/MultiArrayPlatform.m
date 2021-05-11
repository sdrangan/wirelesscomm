classdef MultiArrayPlatform < matlab.System
    % MultiArrayPlatform.  Class containing multiple arrays
    % 
    % The class also has methods for supporting codebook design
    properties
        
        % Cell array of array platforms
        arrPlat;
        
        % Codebook parameters
        azCw, elCw;  % Angles for each codewords
        cwArrInd;    % CW i goes out over array cwArrInd(i)
        codeWord;    % nelem x ncw 
        cwGainMax;   % Max gain over codewords in dBi
    end
    
    methods
        function obj = MultiArrayPlatform(param)
            arguments
                param.narr
                param.elem
                param.array
                param.fc = 28e9
            end
            
            % Create the cell array of platforms
            obj.arrPlat = cell(param.narr,1);
            for i = 1:param.narr
                obj.arrPlat{i} = ArrayPlatform(...
                    'elem', param.elem, 'arr', param.array, 'fc', param.fc);
                obj.arrPlat{i}.computeNormMatrix();
            end
        end
        
        function alignAzimuth(obj, az0)
            % Align the arrays across uniformly in the azimuth plane
            %
            % Array i is aligned to az0 + (i-1)*360/narr
            
            if nargin < 2
                az0 = 0;
            end
            
            % Compute the angles to align the arrays
            narr = length(obj.arrPlat);
            
            
            for i = 1:narr
                az = mod(az0 + (i-1)*360/narr,360);
                if (az > 180)
                    az = az - 360;
                end
                obj.arrPlat{i}.alignAxes(az, 0);
            end
            
        end
        
        function nelem = getNumElements(obj)
            nelem = obj.arrPlat{1}.getNumElements();
        end
            
        
        function createCodebook(obj, options)
            % Creates a codebook.
            % Right now, only a uniform layout in the azimuth direction is
            % supported
            arguments
                obj    
                options.layout = 'azimuth'
                options.numCodeWords = 0
            end
            
            % Get the dimensions
            narr = length(obj.arrPlat);
            nelem = obj.arrPlat{1}.getNumElements();
            
            % Get the number of codewords
            % By default, use the number of elements in the array
            if (options.numCodeWords <= 0)                
                ncw = narr * nelem;
            else
                ncw = options.numCodeWords;
            end
            
            % Get desired angle for each codeword
            if strcmp(options.layout, 'azimuth')
                obj.azCw = (1:ncw)'*360/ncw-180;
                obj.elCw = zeros(ncw,1);
            else
                e = MException('MultiArrayPlatform',...
                    'Unsupported layout %s', options.layout);
                throw(e);
            end
            
            % Get the steering vector in each direction from each
            % array
            Sv = obj.step(obj.azCw, obj.elCw);
            
            % Find the array with the maximum gain
            gain = reshape(sum(abs(Sv).^2,1), ncw, narr);
            [obj.cwGainMax, obj.cwArrInd] = max(gain, [], 2);
            obj.cwGainMax = pow2db(obj.cwGainMax);
            
            % Get the codewords
            obj.codeWord = zeros(nelem, ncw);
            for i = 1:ncw
                j = obj.cwArrInd(i);
                obj.codeWord(:,i) = Sv(:,i,j);
                obj.codeWord(:,i) = conj(obj.codeWord(:,i))/...
                    norm(obj.codeWord(:,i));
                
            end
                        
        end
        
        function ncw = getNumCW(obj)
            % Gets number of codewords
            ncw = length(obj.azCw);
        end
        
        function ncw = getNumArrays(obj)
            % Gets number of codewords
            ncw = length(obj.arrPlat);
        end
        
        function gainComplex = cwGain(obj, az, el, cwInd, relSV)
            arguments
                obj
                az
                el
                cwInd = 'all'
                relSV logical = true
            end
            % Gets the gain of a vectors on codeword directions
            %
            % az, el:  The angles of arrival to compute the gains
            % cwInd:   The codeword indices to compute the gains            
            if strcmp(cwInd, 'all')
                ncw = size(obj.codeWord, 2);
                cwInd = (1:ncw);
            end
            
            % Get the steering vectors in the angles from all the arrays
            Sv = obj.step(az, el, relSV);
            
            % Get the complex gains
            ncw = length(cwInd);
            nang = length(az);
            gainComplex = zeros(nang, ncw);
            for i = 1:ncw
                j = obj.cwArrInd(i);
                gainComplex(:,i) = sum(obj.codeWord(:,i).*Sv(:,:,j), 1);
            end
                                    
            
        end
            
    end
    
    methods (Access = protected)
        
        function setupImpl(obj)
            % setup:  This is called before the first step.
            narr = length(obj.arrPlat);
            for i = 1:narr
                obj.arrPlat{i}.setup();
            end                                    
        end
        
        function releaseImpl(obj)
            % Release the object
            narr = length(obj.arrPlat);
            for i = 1:narr
                obj.arrPlat{i}.release();
            end  
        end
        
        function [Sv, elemGain] = stepImpl(obj, az, el, relSV)
            % Gets normalized steering vectors and element gains for a set of angles
            % The angles az and el should be columns vectors along which
            % the outputs are to be computed.
            % If the relSV == true, then the steering vector object is
            % released.  This is needed in case the dimensions of the past
            % call are the different from the past one
            
            % Release the SV
            if nargin < 4
                relSV = true;
            end           
            
            % Get dimensions
            narr = length(obj.arrPlat);
            nelem = obj.arrPlat{1}.getNumElements();
            nang = length(az);
            
            
            % Get the SV and element gains for each array
            Sv = zeros(nelem,nang,narr);
            elemGain = zeros(nang,narr);
            for i = 1:narr
                [Sv(:,:,i), elemGain(:,i)] = obj.arrPlat{i}.step(az, el, relSV);                
            end  
            
            
        end
        
    end
    
end
