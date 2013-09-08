% PLOTTOPOLOGY Plots a given topology to visualize placements and failure scenarios.
%
%   PLOTTOPOLOGY(A,B,C) plots the topology A with the latitudes and
%   longitudes B of the nodes and controller ids C.
%
%   The parameters A,B,C can be followed by parameter/value pairs to 
%   specify additional properties of the plot.
%
%   The following optional parameters are possible. Default values are
%   shown in brackets '{}'.
%     - 'nodeWeigths',{ones(1,size(topology,1))}: using this parameter, a 
%       node weight vector can be passed to PLOTTOPOLOGY. If not set, 
%       uniform node weights are used.
%     - 'ShowNodeToControllerLatency',{'on'}|'off': indicates whether the
%       node to controller latency should be displayed in the plot.
%     - 'ShowControllerImbalance',{'on'}|'off': indicates whether the
%       controller imbalance should be displayed in the plot.
%     - 'ShowControllerToControllerLatency',{'on'}|'off': indicates whether
%       the controller to controller latency should be displayed in the 
%       plot.
%     - 'ShowIds',{'on'}|'off': indicates whether the node ids should be 
%       displayed in the plot.
%     - 'ShowControllerlessHeatmap',{'on'}|'off': indicates whether the 
%       risk of controller-less nodes should be displayed in the plot.
%     - 'ShowNodeWeights',{'on'}|'off': indicates whether the node weights 
%       should be displayed in the plot.
%     - 'Parent',{figure()}: defines the parent of the plot. The value can
%       be either a axes or figure handle. If no value is provided, a new
%       figure is opened.
%     - 'Export',{'off'}|'pdf'|'png'|'jpg': defines as which format the 
%       plot should be exported. If set to 'off', the plot is not exported.
%     - 'Filename','filename': the name the exported file should have.
%         Default filename is a combination of the topology and the used
%         parameters for plotting.
%         Example:
%           V34_E84_(4-11-20)_()_()_()_(010100).pdf
%           For 34 Vertices, 84 Edges, controllers at node 4, 11 and 20, no
%           failed controllers, no failed nodes, no failed links and the
%           following parameters for plotting:
%             - ShowNodeToControllerLatency: off
%             - ShowControllerImbalance: on
%             - ShowControllerToControllerLatency: off
%             - ShowIds: on
%             - ShowControllerlessHeatmap: off
%             - ShowNodeWeigths: off
%     - 'FailedControllers',{[]}: sets the number of failed controllers,
%       Value must be a number.
%     - 'FailedNodes',{[]}: sets the number of failed nodes. Value
%       must be a number.
%     - 'FailedLinks',{[]}: sets the number of failed links. Value
%       must be a number.
%     - 'ReferenceDiameter',{nan}: sets the diameter for the topology. If 
%       set to nan, the longest of all shortest path is taken as diameter.
%     - 'Colors',{hsv(5)}: sets a different colormap for the plot.
%     - 'Markers',{'odsv^'}: changes the shapes of the controllers and assigned
%         nodes.
%
%     Furthermore, the PLOTTOPOLOGY command supports the Figure Property
%     'Position'.
%
%   For example use cases, see also PLOTEXAMPLE.

%   Copyright 2012-2013 David Hock, Stefan Geißler, Fabian Helmschrott,
%                       Steffen Gebert
%                       Chair of Communication Networks, Uni Würzburg   
%
function plotTopology(topology,latitudeLongitude,controllerPlaces,varargin)

p = inputParser;    % Parser to parse input arguments

p.addRequired('topology', @(x)isnumeric(x) && diff(size(x))==0); % symmetric numerical topology matrix
p.addRequired('latitudeLongitude', @(x)isnumeric(x) && size(x,1)==size(topology,1) && size(x,2)==2);
p.addParamValue('nodeWeights', ones(1,size(topology,1)) ,@(x)isnumeric(x) && size(x,1)==size(topology,1) && size(x,2)==1);

% Plot Parameters
p.addParamValue('ShowNodeToControllerLatency', 'off',  @(x)strcmpi(x,'off')||strcmpi(x,'on'));
p.addParamValue('ShowControllerImbalance', 'off',  @(x)strcmpi(x,'off')||strcmpi(x,'on'));
p.addParamValue('ShowControllerToControllerLatency', 'off',  @(x)strcmpi(x,'off')||strcmpi(x,'on'));
p.addParamValue('ShowIds', 'off',  @(x)strcmpi(x,'off')||strcmpi(x,'on'));
p.addParamValue('ShowControllerlessHeatmap', 'off',  @(x)strcmpi(x,'off')||strcmpi(x,'on'));
p.addParamValue('ShowNodeWeights', 'off',  @(x)strcmpi(x,'off')||strcmpi(x,'on'));
p.addParamValue('Parent', [],  @(x)strcmpi(get(x,'type'),'axes')||strcmpi(get(x,'type'),'figure'));
p.addParamValue('Export', 'off',  @(x)strcmpi(x,'off')||strcmpi(x,'pdf')||strcmpi(x,'png')||strcmpi(x,'jpg'));
p.addParamValue('FileName', '',  @ischar);
p.addParamValue('Position', [0 0 800 600],  @(x)isnumeric(x) && length(x)==4);

% Topology / Placement Parameters
p.addRequired('controllerPlaces',  @isnumeric);
p.addParamValue('FailedControllers', [],  @isnumeric);
p.addParamValue('FailedNodes', [],  @isnumeric);
p.addParamValue('FailedLinks', [],  @isnumeric);
p.addParamValue('ReferenceDiameter', nan,  @isnumeric);

% Visualization Parameters
p.addParamValue('Colors', [hsv(5);hsv(min(1,length(controllerPlaces)-5))],  @isnumeric);
p.addParamValue('Markers', 'odsv^pdshov^x+*',  @ischar);

p.parse(topology, latitudeLongitude, controllerPlaces, varargin{:});
% p.Results

plotids=strcmpi(p.Results.ShowIds,'on');  % boolean to show ids
plotlatencyN2C=strcmpi(p.Results.ShowNodeToControllerLatency,'on'); % boolean to color according to node-to-controller distances
plotbal=strcmpi(p.Results.ShowControllerImbalance,'on'); % boolean to color and shape according to balancing
plotlatencyC2C=strcmpi(p.Results.ShowControllerToControllerLatency,'on'); % boolean to color according to inter-controller distances
plottm=strcmpi(p.Results.ShowNodeWeights,'on'); % boolean if tm should be used for node sizes
plotheatmap=strcmpi(p.Results.ShowControllerlessHeatmap,'on'); % boolean if heatmap should be shown
plotexport=~strcmpi(p.Results.Export,'off'); % boolean if plot is used for display only

% Check Matlab-version
matlabVersion=str2num(regexprep(version('-release'),'[^0-9]','')) ;

if isempty(p.Results.Parent)
    figure();
else
    if strcmpi(get(p.Results.Parent,'type'),'figure')
        figure(p.Results.Parent);
    else
        axes(p.Results.Parent);
    end
end

gplot(topology~=inf,latitudeLongitude,'-k');

hold on

controllersfailed=p.Results.FailedControllers;

nodesfailed=p.Results.FailedNodes;

linksfailed=p.Results.FailedLinks;
linksontop=1;

if isnan(p.Results.ReferenceDiameter)
    distanceMatrix=allToAllShortestPathMatrix(topology);
    distanceMatrix(distanceMatrix==inf)=nan;
    mydiameter=nanmax(nanmax(distanceMatrix));
else
    mydiameter=p.Results.ReferenceDiameter;
end

mycolors=p.Results.Colors;

mymarkers=p.Results.Markers;

tm=p.Results.nodeWeights;

if ~plottm
    tm=ones(1,size(topology,1));
end

if plotheatmap
    controllersfailed=[];
    nodesfailed=[];
    linksfailed=[];
end

if matlabVersion < 2013
    nkworking=setdiff(controllerPlaces,[nodesfailed controllersfailed]);
else
    nkworking=setdiff(controllerPlaces,[nodesfailed controllersfailed],'legacy');
end

% to provide from errors due to unexpected input
if isempty(nkworking)
    plotlatencyN2C=0; % boolean to color according to node-to-controller distances
    plotbal=0; % boolean to color and shape according to balancing
    plotlatencyC2C=0; % boolean to color according to inter-controller distances
    plotheatmap=0; % boolean if heatmap should be shown
end

if matlabVersion < 2013
    controllersfailed=intersect([controllersfailed intersect(controllerPlaces,nodesfailed)],controllerPlaces);
else
    controllersfailed=intersect([controllersfailed intersect(controllerPlaces,nodesfailed, 'legacy')],controllerPlaces);
end
% Add broken links for broken nodes
for m=1:length(nodesfailed)
    neighbors=find(topology(:,nodesfailed(m))~=inf);
    linksfailed=[linksfailed;[repmat(nodesfailed(m),length(neighbors),1) neighbors]];
end

% Plot broken links
if ~isempty(linksfailed)
    beginx=latitudeLongitude(linksfailed(:,1),1);
    beginy=latitudeLongitude(linksfailed(:,1),2);
    endx=latitudeLongitude(linksfailed(:,2),1);
    endy=latitudeLongitude(linksfailed(:,2),2);
    for m=1:length(beginx)
        plot([beginx(m) endx(m)],[beginy(m) endy(m)],'r--');
    end
end

% Plot broken nodes
placex=latitudeLongitude(nodesfailed,1);
placey=latitudeLongitude(nodesfailed,2);
plot(placex,placey,'ro','MarkerFaceColor','w','MarkerSize',3+20);

% Plot broken controllers
placex=latitudeLongitude(controllersfailed,1);
placey=latitudeLongitude(controllersfailed,2);
plot(placex,placey,'o','Color','r','MarkerFaceColor','none','MarkerSize',3+20);
plot(placex,placey,'o','Color','r','MarkerFaceColor','none','MarkerSize',5+20);
plot(placex,placey,'o','Color','r','MarkerFaceColor','none','MarkerSize',8+20);
plot(placex,placey,'o','Color','r','MarkerFaceColor','none','MarkerSize',11+20);
plot(placex,placey,'x','Color','r','MarkerFaceColor','none','MarkerSize',11+20,'LineWidth',4);

% Plot controller-less nodes
topologyreduced=topology;
% disable nodes
topologyreduced(nodesfailed,:)=Inf;
topologyreduced(:,nodesfailed)=Inf;
% disable links
for m=1:size(linksfailed,1)
    topologyreduced(linksfailed(m,1),linksfailed(m,2))=Inf;
    topologyreduced(linksfailed(m,2),linksfailed(m,1))=Inf;
end
modifiedDistanceMatrix=allToAllShortestPathMatrix(topologyreduced);
for m=1:length(nodesfailed)
    modifiedDistanceMatrix(nodesfailed(m),nodesfailed(m))=Inf;
end
accessnodes=[];
for m=1:size(modifiedDistanceMatrix,1)
    if length(find(modifiedDistanceMatrix(m,:)~=inf))==1
        modifiedDistanceMatrix(m,:)=Inf;
        modifiedDistanceMatrix(:,m)=Inf;
        latitudeLongitude(m,:)
        accessnodes=[accessnodes m];
    end
end
temp=min(modifiedDistanceMatrix(:,nkworking),[],2);
if matlabVersion < 2013
    uncovered=setdiff(find(temp==Inf),[accessnodes nodesfailed]);
else
    uncovered=setdiff(find(temp==Inf),[accessnodes nodesfailed],'legacy');
end
placex=latitudeLongitude(uncovered,1);
placey=latitudeLongitude(uncovered,2);
plot(placex,placey,'ko','MarkerFaceColor','w','MarkerSize',3+20);
text(placex,placey,'?','FontSize',12,'FontWeight','bold','HorizontalAlignment','center','VerticalAlignment','middle','Color','r');

% Plot nodes
% heatmap
maxfail=2;
if plotheatmap
    heatmap=zeros(1,size(topology,1));
    for i=1:maxfail
        failurepatterns=combnk(1:size(topology,1),i);
        for j=1:size(failurepatterns,1) %
            nodesfailed=failurepatterns(j,:);
            topologyreduced=topology;
            % disable nodes
            topologyreduced(nodesfailed,:)=Inf;
            topologyreduced(:,nodesfailed)=Inf;
            modifiedDistanceMatrix=allToAllShortestPathMatrix(topologyreduced);
            for m=1:length(nodesfailed)
                modifiedDistanceMatrix(nodesfailed(m),nodesfailed(m))=Inf;
            end
            accessnodes=[];
            for m=1:size(modifiedDistanceMatrix,1)
                if length(find(modifiedDistanceMatrix(m,:)~=inf))==1
                    modifiedDistanceMatrix(m,:)=Inf;
                    modifiedDistanceMatrix(:,m)=Inf;
                    accessnodes=[accessnodes m];
                end
            end
            temp=min(modifiedDistanceMatrix(:,nkworking),[],2);
            if matlabVersion < 2013
                uncovered=setdiff(find(temp==Inf),[accessnodes nodesfailed]);
            else
                uncovered=setdiff(find(temp==Inf),[accessnodes nodesfailed],'legacy');
            end
            heatmap(uncovered)=heatmap(uncovered)+1; % add 1 to all controller-less nodes in this scenario
        end
    end
    uncovered=[];
    nodesfailed=[];
end

% latencyN2C,contollerImbalance
[temp,temp2]=min(modifiedDistanceMatrix(:,nkworking),[],2);
[a,b]=sort(tm,'descend');

for m=b
    if isempty(find(m==[uncovered nodesfailed],1))
        v='o';
        if plotheatmap
            if max(heatmap)>0
                c=getgreenyellowred(log(1+heatmap(m))/log(5));
            else
                c=getgreenyellowred(0);
            end
        elseif plotlatencyN2C
            c=getgreenyellowred(temp(m)/mydiameter);
        elseif plotbal
            c=mycolors(temp2(m),:);
        else
            c=[1 1 1];
        end
        if plotbal
            v=mymarkers(temp2(m));
        end
        placex=latitudeLongitude(m,1);
        placey=latitudeLongitude(m,2);
        tmscale=plottm*(tm(m)/max(tm))*(5+(45));
        plot(placex,placey,v,'Color','k','MarkerFaceColor',c,'MarkerSize',(3+20)+tmscale);
    end
end

% Plot controllers
temp=modifiedDistanceMatrix(nkworking,nkworking);
temp(temp==Inf)=nan;
temp=nanmax(temp,[],2);
for m=1:length(nkworking(:))
    placex=latitudeLongitude(nkworking(m),1);
    placey=latitudeLongitude(nkworking(m),2);
    if plotlatencyC2C
        c=getgreenyellowred(temp(m)/mydiameter);
    elseif plotlatencyN2C
        c='g';
    elseif plotbal
        c=mycolors(m,:);
    else
        c=[1 1 1];
    end
    v='o';
    if plotbal
        v=mymarkers(m);
    end
    tmscale = plottm*(tm(nkworking(m))/max(tm))*(5+(45));
    plot(placex,placey,v,'Color','k','MarkerFaceColor',c,'MarkerSize',(3+20)+tmscale);
    plot(placex,placey,v,'Color','k','MarkerFaceColor','none','MarkerSize',(3+20)+tmscale);
    plot(placex,placey,v,'Color','k','MarkerFaceColor','none','MarkerSize',(5+20)+tmscale);
    plot(placex,placey,v,'Color','k','MarkerFaceColor','none','MarkerSize',(9+20)+tmscale);
end

if linksontop
    % Plot broken links again on top
    if ~isempty(linksfailed)
        beginx=latitudeLongitude(linksfailed(:,1),1);
        beginy=latitudeLongitude(linksfailed(:,1),2);
        endx=latitudeLongitude(linksfailed(:,2),1);
        endy=latitudeLongitude(linksfailed(:,2),2);
        for m=1:length(beginx)
            plot([beginx(m) endx(m)],[beginy(m) endy(m)],'r','LineWidth',2);
        end
    end
end

if plotids
    for i=1:size(latitudeLongitude,1)
        placex=latitudeLongitude(i,1);
        placey=latitudeLongitude(i,2);
        text('Position',[placex,placey,1],'String',num2str(i),'FontSize',8,'HorizontalAlignment','center');
    end
end

% Adapt visible range and remove axes
set(gca,'Visible','off');
xlim([min(latitudeLongitude(:,1))-0.3 max(latitudeLongitude(:,1))+0.3]);
ylim([min(latitudeLongitude(:,2))-1 max(latitudeLongitude(:,2))+1.5]);


set(gcf,'Position',p.Results.Position, 'PaperPositionMode','auto');

if plotexport==1 % Export is activated, save as pdf file
    originalPaperPosition=get(gcf,'PaperPosition');
    if strcmpi(p.Results.Export,'pdf')
        set(gcf,'PaperSize',originalPaperPosition(3:4),'PaperPosition',[0 0 originalPaperPosition(3:4)]);
    end
    plotpattern(1)=plotlatencyN2C;
    plotpattern(2)=plotbal;
    plotpattern(3)=plotlatencyC2C;
    plotpattern(4)=plotids;
    plotpattern(5)=plotheatmap;
    plotpattern(6)=plottm;
    
    if isempty(p.Results.FileName)
        numNodes=size(topology,1);
        numLinks=length(find(topology~=inf & topology>0));
        filename=[sprintf('V%d_E%d_(%s)_(%s)_(%s)_(%s)_(%s)',numNodes,numLinks,...
            regexprep(num2str(controllerPlaces),'\s+','-'),regexprep(num2str(controllersfailed),'\s+','-'),...
            regexprep(num2str(nodesfailed),'\s+','-'),regexprep(num2str(linksfailed),'\s+','-'),...
            regexprep(num2str(plotpattern),'\s','')), ['.' p.Results.Export]];
    else
        filename=p.Results.FileName;
        if ~strcmpi(filename(end-length(p.Results.Export)+1:end),p.Results.Export)
            filename=[filename '.' p.Results.Export];
        end
    end
    
    saveas(gcf,filename);
end

% getgreenyellowred Creates a colormap from green to dark red depending on
% the value x in [0,1]. Values x<0 are set to green, values x>1 to dark
% red.
    function c=getgreenyellowred(x)
        myyellow=0.5;
        myred=1;
        mycolormap=[];
        
        % Blue RGB component is always zero
        mycolormap(1:200,3)=zeros(1,200);
        
        % Green to Yellow
        mycolormap(1:ceil(200*myyellow),1)=(1:ceil(200*myyellow))/ceil(200*myyellow);
        mycolormap(1:ceil(200*myyellow),2)=ones(1,ceil(200*myyellow));
        
        % Yellow to Red
        mycolormap((ceil(200*myyellow)+1):ceil(200*myred),1)=ones(1,length((ceil(200*myyellow)+1):ceil(200*myred)));
        mycolormap((ceil(200*myyellow)+1):ceil(200*myred),2)=1-(1:length((ceil(200*myyellow)+1):ceil(200*myred)))/length((ceil(200*myyellow)+1):ceil(200*myred));
        
        % Red to Dark Red
        mycolormap((ceil(200*myred)+1):200,1)=1-(1:length((ceil(200*myred)+1):200))/(1.5*length((ceil(200*myred)+1):200));
        mycolormap((ceil(200*myred)+1):200,2)=0;
        
        c=mycolormap(max(1,min(200,ceil(x*200))),:);
    end

end
