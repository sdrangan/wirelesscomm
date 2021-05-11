classdef DataMapper < matlab.mixin.SetGet
    % Class for mapping data for a grid
    
    properties
        posStep;  % Grid spacing in each direction
        
        % Data at position n will be mapped to grid point
        % (posInd(n,1), posInd(n,2))
        posInd;   % Index of the
       
        % Number of steps in each axis
        nsteps; 
        
        % Position along each axis
        posx, posy;
        
    end
    
    methods
        function obj = DataMapper(pos, posStep)
            % Constructor
            %
            % pos is a n x 2 list of all possible positions.
            % posStep is the 1 x 2 grid spacing in each direction
            
            % Compute the indices that each position gets mapped to
            posMin = min(pos);
            posMax = max(pos);
            obj.posStep = posStep;
            obj.nsteps = (posMax - posMin)./posStep + 1;
            obj.posInd = round((pos-posMin)./posStep)+1;
            
            % Compute the x and y positions for the imagesc function
            obj.posx = posMin(1) + (0:obj.nsteps(1)-1)*posStep(1);
            obj.posy = posMin(2) + (0:obj.nsteps(2)-1)*posStep(2);
        end
        
        function plot(obj, data, options)
            % Plots data with the positions
            %
            % Data is a vector of size n x 1.  The function will then
            % plot the value of data(i) in pos(i,1), pos(i,2).
            %
            % It can also optionally create dummy legend labels that can
            % then be displayed with the legend command            
            arguments
                obj
                data
                options.legendValues = []
                options.legendLabels = []
                options.plotHold logical = false
                options.addLegend logical = false
                options.legendLocation string = 'southeast'
                options.noDataValue = 0
            end
            
            
            % Create an image array for the data
            posImage = repmat(options.noDataValue, ...
                obj.nsteps(2), obj.nsteps(1));
            for i = 1:length(data)
                posImage(obj.posInd(i,2), obj.posInd(i,1)) = data(i);
            end
            
            % Plot the data
            imagesc(obj.posx, obj.posy, posImage);
            hold on;
            
            % Plot a dummy rectangle for each color
            if ~isempty(options.legendLabels)
                nlabels = length(options.legendLabels);                
                colorArr = parula(nlabels);
                for i = 1:nlabels
                    fill([1,1],[1,1], colorArr(i,:), 'DisplayName', ...
                        options.legendLabels{i});
                end
            end
            
            % Turn off the plot hold if not requested
            if ~options.plotHold
                hold off;
            end
            
            % Create the legend
            if options.addLegend
                legend('Location', options.legendLocation);
            end
        end
    end
end

