%% Plots the balance of a topology
function paretoidx=plotParetoPLC(xin,yin,varargin)

p = inputParser;    % Parser to parse input arguments

p.addRequired('xin', @isnumeric);
p.addRequired('yin', @(x)isnumeric(x) && length(xin)==length(yin));

% Plot Parameters
p.addParamValue('ShowMeanValues', 'on',  @(x)strcmpi(x,'off')||strcmpi(x,'on'));
p.addParamValue('ShowSelectedidx', 0,  @(x)isnumeric(x) && x>0 && x<=length(xin));
p.addParamValue('Parent', [],  @(x)strcmpi(get(x,'type'),'axes')||strcmpi(get(x,'type'),'figure'));
p.addParamValue('Axes', [], @(x)strcmpi(get(x,'type'),'axes'));
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


if ~isempty(p.Results.Parent) && ~isempty(p.Results.Axes)
    cla(p.Results.Axes);
    set(0,'CurrentFigure',p.Results.Parent)
    set(p.Results.Parent,'CurrentAxes',p.Results.Axes);

elseif isempty(p.Results.Parent)
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
plot(xinthin,yinthin,'.','MarkerSize',5,'Color',[0.8 0.8 0.8]);
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
    text('Position',[xlims(2),meany],'String','Mean ','HorizontalAlignment','right','VerticalAlignment','top');%,'BackgroundColor','w');
    text('Position',[meanx,ylims(2)],'String','Mean ','HorizontalAlignment','right','VerticalAlignment','top','Rotation',90);%,'BackgroundColor','w');
    plot(xlims,repmat(meany,2,1),'k--','LineWidth',2);
    plot(repmat(meanx,2,1),ylims,'k--','LineWidth',2);
end

if selectedidx>0
    plot(xin(selectedidx),yin(selectedidx),'o','MarkerSize',10,'MarkerFaceColor',mycolors(1,:),'Color',darken(mycolors(1,:)),'LineWidth',2);
end

set(gca, 'Layer','top')
box off;
end