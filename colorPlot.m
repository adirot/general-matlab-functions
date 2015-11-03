function colorPlot(x,y,varargin)
% every row in x is an x axis to plot
% every rew in y is a y axis to plot
% this will plot all [x, y]'s in different colors
   
% optional: 'labels': a cell array of strings to be used as legend
% optional: 'plotBar': plot as bar

p = inputParser();

addOptional(p, 'addLegend', []);
addOptional(p, 'plotBar', false);

parse(p, varargin{:});
Results = p.Results;

addLegend = Results.addLegend;
plotBar = Results.plotBar;

    [numOfPlots,~] = size(x);
    
  
   cmap = hsv(numOfPlots);
   
   figure; hold on;
   
   for i = 1:numOfPlots
       if plotBar
            increment = x(i,2)-x(i,1);
            bar(x(i,:)+increment/2,y(i,:),1,'EdgeColor',cmap(i,:)...
                ,'FaceColor','none')
       else
            plot(x(i,:),y(i,:),'color',cmap(i,:));
       end
   end
   
   if ~isempty(addLegend)
        legend(addLegend)
   end
   
end
       