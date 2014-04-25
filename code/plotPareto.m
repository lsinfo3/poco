% PLOTPARETO Displays the solution space for two given metrics including a set of Pareto-optimal values.
%
%   X = PLOTPARETO(A,B) displays the solution space including a set of 
%   Pareto-optimal values for two given metrics A and B, where A and B are
%   two vectors of equal length. The returned array X contains a vector
%   with the ids of all Pareto-optimal values.
%
%   The parameters A and B can be followed by parameter/value pairs to 
%   specify additional properties of the plot.
%
%   The following optional parameters are possible. Default values are
%   shown in brackets '{}'.
%     - 'showMeanValues',{'on'}|'off': indicates whether mean values of 
%       metrics A and B should be shown
%     - 'ShowSelectedidx',{0}: indicates a particular placement id that
%       should be highlighted in the graph. If set to 0, no particular 
%       placement is highlighted.
%     - 'Parent',{figure()}: defines the parent of the plot. The value can
%       be either a axes or figure handle. If no value is provided, a new
%       figure is opened.
%     - 'Export',{'off'}|'pdf'|'png'|'jpg': defines as which format the 
%       plot should be exported. If set to 'off', the plot is not exported.
%     - 'Filename','filename': the name the exported file should have.
%         Default filename is 'paretoPlot.EXTENSION' where EXTENSION
%         corresponds to the extension provided in the 'Export' parameter.
%
%     Furthermore, the PLOTPARETO command supports following Figure and 
%     Axes Properties that can be directly passed as parameter/value pairs:
%     'XLabel','YLabel','XLim','Ylim','Position'.
%
%   For example use cases, see also PLOTEXAMPLE.

%   Copyright 2012-2013 David Hock, Stefan Geißler, Fabian Helmschrott,
%                       Steffen Gebert
%                       Chair of Communication Networks, Uni Würzburg   

function [paretoidx textXaxis textYaxis]=plotPareto(xin,yin,varargin)

p = inputParser;    % Parser to parse input arguments

p.addRequired('xin', @isnumeric);
p.addRequired('yin', @(x)isnumeric(x) && length(xin)==length(yin));

% Plot Parameters
p.addParamValue('ShowMeanValues', 'on',  @(x)strcmpi(x,'off')||strcmpi(x,'on'));
p.addParamValue('ShowSelectedidx', 0,  @(x)isnumeric(x) && x>0 && x<=length(xin));
p.addParamValue('Parent', [],  @(x)strcmpi(get(x,'type'),'axes')||strcmpi(get(x,'type'),'figure'));
p.addParamValue('Export', 'off',  @(x)strcmpi(x,'off')||strcmpi(x,'pdf')||strcmpi(x,'png')||strcmpi(x,'jpg'));
p.addParamValue('FileName', '',  @ischar);
p.addParamValue('XLabel', '',  @ischar);
p.addParamValue('YLabel', '',  @ischar);
p.addParamValue('XLim', [],  @(x)isnumeric(x) && length(x)==2);
p.addParamValue('YLim', [],  @(x)isnumeric(x) && length(x)==2);
p.addParamValue('Position', [0 0 800 600],  @(x)isnumeric(x) && length(x)==4);

p.parse(xin, yin, varargin{:});
mycolors=hsv(5);
% Check Matlab-version
matlabVersion=str2num(regexprep(version('-release'),'[^0-9]','')) ;

if isempty(p.Results.Parent)
    figure();
else
    if strcmpi(get(p.Results.Parent,'type'),'figure')
        figure(p.Results.Parent);
        clf;
    else
        axes(p.Results.Parent);
        cla;
    end
end

box off;

selectedidx=p.Results.ShowSelectedidx;

meanflag=strcmpi(p.Results.ShowMeanValues,'on');
plotexport=~strcmpi(p.Results.Export,'off'); % boolean if plot is used for display only

% Plot light blue dots indicating the entire search space
% do not plot several identical points to reduce the total number of points
if matlabVersion < 2013
    mythin=unique([xin;yin]','rows');
else
    mythin=unique([xin;yin]','rows', 'legacy');
end
xinthin=mythin(:,1)';
yinthin=mythin(:,2)';
plot(xinthin,yinthin,'.','MarkerSize',5,'Color',[0.7 0.7 0.7]);
hold on

% Get mean
meanx=mean(xin);
meany=mean(yin);

% Find pareto values
[x,y]=paretobest2fastlogic(xin,yin);

paretoidx=zeros(1,length(x));
for i=1:length(x)
    paretoidx(i)=find(xin==x(i) & yin==y(i),1,'last');
end

xlims=get(gca,'xlim');
ylims=get(gca,'ylim');

c=[0.9 0.9 0.9];
plot(x,y,'o-','LineWidth',2,'MarkerSize',10,'Color',darken(c),'MarkerFaceColor',c);

if meanflag
    textXaxis = text('Position',[xlims(2),meany],'String','Mean','HorizontalAlignment','right','VerticalAlignment','top');
    textYaxis = text('Position',[meanx,ylims(2)],'String','Mean','HorizontalAlignment','right','VerticalAlignment','top','Rotation',90);
    plot(xlims,repmat(meany,2,1),'k--','LineWidth',2);
    plot(repmat(meanx,2,1),ylims,'k--','LineWidth',2);
end

if selectedidx>0
    plot(xin(selectedidx),yin(selectedidx),'o','MarkerSize',10,'MarkerFaceColor',mycolors(1,:),'Color',darken(mycolors(1,:)),'LineWidth',2);
end

set(gca, 'Layer','top')
box off;
xlabel(p.Results.XLabel);
ylabel(p.Results.YLabel);
if ~isempty(p.Results.XLim)
    xlim(p.Results.XLim);
end
if ~isempty(p.Results.YLim)
    ylim(p.Results.YLim);
end

if plotexport==1 % Export is activated, save as pdf file
    originalPaperPosition=get(gcf,'PaperPosition');
    set(gcf,'Position',p.Results.Position,'PaperSize',originalPaperPosition(3:4),'PaperPosition',[0 0 originalPaperPosition(3:4)]);
    
    if isempty(p.Results.FileName)
        filename=['paretoPlot.' p.Results.Export];
    else
        filename=p.Results.FileName;
        if ~strcmpi(filename(end-length(p.Results.Export)+1:end),p.Results.Export)
            filename=[filename '.' p.Results.Export];
        end
    end
    
    saveas(gcf,filename);
end
end