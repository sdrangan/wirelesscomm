function plotChan(grid, labels, varargin)

    % Plot the grid
    imagesc(grid);
    
    if nargin == 2
        hold on;

        % Plot a dummy rectangle for each color
        nchan = length(labels);
        colorArr = parula(nchan);    
        for i = 1:nchan
            fill([1,1],[1,1], colorArr(i,:), 'DisplayName', labels{i});
        end
        hold off;

        % Create the legend
        legend();
    end
end