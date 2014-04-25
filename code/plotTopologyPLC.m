%% Plots the distances in a topology
function [tmvals,latencyvals,mycolors,meanlatencyvals,assignments]=plotTopologyPLC(topology,coordinates,controllerPlaces,varargin)

p = inputParser;    % Parser to parse input arguments

p.addRequired('topology', @(x)isnumeric(x) && diff(size(x))==0); % symmetric numerical topology matrix
p.addRequired('coordinates', @(x)isnumeric(x) && size(x,1)==size(topology,1) && size(x,2)==2);
p.addParamValue('nodeWeights', ones(1,size(topology,1)) ,@(x)isnumeric(x) && size(x,2)==size(topology,1) && size(x,1)==1);

% Plot Parameters
p.addParamValue('ShowNodeToControllerLatency', 'off',  @(x)strcmpi(x,'off')||strcmpi(x,'on'));
p.addParamValue('ShowControllerImbalance', 'off',  @(x)strcmpi(x,'off')||strcmpi(x,'on'));
p.addParamValue('ShowControllerToControllerLatency', 'off',  @(x)strcmpi(x,'off')||strcmpi(x,'on'));
p.addParamValue('ShowIds', 'off',  @(x)strcmpi(x,'off')||strcmpi(x,'on'));
p.addParamValue('ShowControllerlessHeatmap', 'off',  @(x)strcmpi(x,'off')||strcmpi(x,'on'));
p.addParamValue('ShowNodeWeights', 'off',  @(x)strcmpi(x,'off')||strcmpi(x,'on'));
p.addParamValue('Parent', '');
p.addParamValue('CurrentAxis', '');
p.addParamValue('Export', 'off',  @(x)strcmpi(x,'off')||strcmpi(x,'pdf')||strcmpi(x,'png')||strcmpi(x,'jpg'));
p.addParamValue('FileName', '',  @ischar);
p.addParamValue('Position', [0 0 800 600],  @(x)isnumeric(x) && length(x)==4);
p.addParamValue('ShowMap', 'off', @(x)strcmpi(x,'off')||strcmpi(x,'on'));
% Topology / Placement Parameters
p.addRequired('controllerPlaces',  @isnumeric);
p.addParamValue('FailedControllers', [],  @isnumeric);
p.addParamValue('FailedNodes', [],  @isnumeric);
p.addParamValue('FailedLinks', [],  @isnumeric);
p.addParamValue('ReferenceDiameter', nan,  @isnumeric);

% Visualization Parameters
p.addParamValue('Colors', [hsv(5);hsv(length(controllerPlaces)-5)],  @isnumeric);
p.addParamValue('Markers', 'odsv^pdshov^x+*',  @ischar);

p.parse(topology, coordinates, controllerPlaces, varargin{:});
% p.Results
plotids=strcmpi(p.Results.ShowIds,'on');  % boolean to show ids
plotlatencyN2C=strcmpi(p.Results.ShowNodeToControllerLatency,'on'); % boolean to color according to node-to-controller distances
plotbal=strcmpi(p.Results.ShowControllerImbalance,'on'); % boolean to color and shape according to balancing
plotlatencyC2C=strcmpi(p.Results.ShowControllerToControllerLatency,'on'); % boolean to color according to inter-controller distances
plottm=strcmpi(p.Results.ShowNodeWeights,'on'); % boolean if tm should be used for node sizes
plotheatmap=strcmpi(p.Results.ShowControllerlessHeatmap,'on'); % boolean if heatmap should be shown
plotexport=~strcmpi(p.Results.Export,'off'); % boolean if plot is used for display only
mapbool=strcmpi(p.Results.ShowMap,'on');

% Check Matlab-version
matlabVersion=str2num(regexprep(version('-release'),'[^0-9]','')) ;

nodeWeights=p.Results.nodeWeights;
axesid=p.Results.CurrentAxis;
if isempty(p.Results.Parent)
    figureid=figure();
else
    if strcmpi(get(p.Results.Parent,'type'),'figure') 
        figureid=figure(p.Results.Parent);
    else
        a = p.Results.Parent;
        figureid=axes(p.Results.Parent);
    end
end

tm=log(1+nodeWeights/nanmax(nodeWeights)*10);
cla(axesid,'reset');
set(0,'CurrentFigure',figureid)
set(figureid,'CurrentAxes',axesid);
if mapbool
    fname = 'worldmap.png';
    img = imread(fname,'png');
    [imgH,imgW,tildevar] = size(img);
    
    %# Mercator projection
    [x,y] = mercatorProjection(coordinates(:,1), coordinates(:,2), imgW, imgH);
    coordinates=[x y];
    
    %# plot markers on map
    imagesc(img)
end
hold on;

controllersfailed=p.Results.FailedControllers;

nodesfailed=p.Results.FailedNodes;

linksfailed=p.Results.FailedLinks;
linksontop=0;

if isnan(p.Results.ReferenceDiameter)
    distanceMatrix=topology;
    distanceMatrix(distanceMatrix==inf)=nan;
    mydiameter=nanmax(nanmax(distanceMatrix));
else
    mydiameter=p.Results.ReferenceDiameter;
end

mycolors=p.Results.Colors;

mymarkers=p.Results.Markers;

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
    controllersfailed=intersect([controllersfailed intersect(controllerPlaces,nodesfailed,'legacy')],controllerPlaces,'legacy');
end

% Add broken links for broken nodes
for m=1:length(nodesfailed)
    neighbors=find(topology(:,nodesfailed(m))~=inf);
    linksfailed=[linksfailed;[repmat(nodesfailed(m),length(neighbors),1) neighbors]];
end

% Plot broken nodes
placex=coordinates(nodesfailed,1);
placey=coordinates(nodesfailed,2);
plot(placex,placey,'ro','MarkerFaceColor','w','MarkerSize',20,'LineWidth',3, 'LineSmoothing','off');

% Plot broken controllers
placex=coordinates(controllersfailed,1);
placey=coordinates(controllersfailed,2);
plot(placex,placey,'o','Color','r','MarkerFaceColor','none','MarkerSize',20,'LineWidth',3, 'LineSmoothing','off');
plot(placex,placey,'o','Color','r','MarkerFaceColor','none','MarkerSize',29,'LineWidth',3, 'LineSmoothing','off');
plot(placex,placey,'o','Color','r','MarkerFaceColor','none','MarkerSize',38,'LineWidth',3, 'LineSmoothing','off');
plot(placex,placey,'x','Color','r','MarkerFaceColor','none','MarkerSize',38,'LineWidth',4);

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
modifiedDistanceMatrix=topologyreduced;
for m=1:length(nodesfailed)
    modifiedDistanceMatrix(nodesfailed(m),nodesfailed(m))=Inf;
end
accessnodes=[];
for m=1:size(modifiedDistanceMatrix,1)
    if length(find(modifiedDistanceMatrix(m,:)~=inf))==1
        modifiedDistanceMatrix(m,:)=Inf;
        modifiedDistanceMatrix(:,m)=Inf;
        coordinates(m,:);
        accessnodes=[accessnodes m];
    end
end
temp=nanmin(modifiedDistanceMatrix(:,nkworking),[],2);
if matlabVersion < 2013
    uncovered=setdiff(find(temp==Inf | isnan(temp)),[accessnodes nodesfailed]);
else
    uncovered=setdiff(find(temp==Inf | isnan(temp)),[accessnodes nodesfailed],'legacy');
end
placex=coordinates(uncovered,1);
placey=coordinates(uncovered,2);
plot(placex,placey,'o','MarkerFaceColor',[0.95 0.95 0.95],'MarkerSize',20,'LineWidth',3, 'LineSmoothing','off','MarkerEdgeColor',[0.9 0.9 0.9]);
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
            modifiedDistanceMatrix=topologyreduced;
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


% distnc,balance
[temp,temp2]=nanmin(modifiedDistanceMatrix(:,nkworking),[],2);

% for output
if ~isempty(temp2)
    latencyvals=temp;
    latencyvals(latencyvals==inf)=nan;
    assignments=temp2;
    meanlatencyvals=nanmean(modifiedDistanceMatrix(:,nkworking),2);
    tmvals=accumarray(temp2,nodeWeights,[],@nansum);
else
    latencyvals=[];
    meanlatencyvals=[];
    tmvals=[];
end

[a,b]=sort(tm,'descend');


% colored links % PLC ADAPTED
if plotbal || plotlatencyN2C
    for m=b % all nodes
        if isempty(find(m==[uncovered' nodesfailed nkworking],1))
            beginx=coordinates(m,1);
            beginy=coordinates(m,2);
            endx=coordinates(nkworking(temp2(m)),1);
            endy=coordinates(nkworking(temp2(m)),2);
            if plotbal
                plot([beginx endx],[beginy endy],'Color',mycolors(temp2(m),:),'LineWidth',3, 'LineSmoothing','off');
            else
                plotFadingLink([beginx endx],[beginy endy],getgreenyellowred(temp(m)/mydiameter),getgreenyellowred(0));
            end
        end
    end
end

for m=b
    if isempty(find(m==[uncovered' nodesfailed],1))
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
            c=[0.9 0.9 0.9];
        end
        if plotbal
            v=mymarkers(1+mod(temp2(m)-1,length(mymarkers)));
            cborder=darken(mycolors(temp2(m),:));
        else
            cborder=darken(c);
        end
        placex=coordinates(m,1);
        placey=coordinates(m,2);
        plot3(placex,placey,1,v,'MarkerFaceColor',c,'MarkerSize',max(1e-3,20*tm(m)),'Color',cborder,'LineWidth',3, 'LineSmoothing','off')
    end
end

% Plot controllers
temp=modifiedDistanceMatrix(nkworking,nkworking);
temp(temp==Inf)=nan;
temp=nanmax(temp,[],2);
for m=1:length(nkworking(:))
    placex=coordinates(nkworking(m),1);
    placey=coordinates(nkworking(m),2);
    if plotlatencyC2C
        c=getgreenyellowred(temp(m)/mydiameter);
    elseif plotlatencyN2C
        c='g';
    elseif plotbal
        c=mycolors(m,:);
    else
        c=[0.9 0.9 0.9];
    end
    if plotbal
        v=mymarkers(1+mod(temp2(m)-1,length(mymarkers)));
        cborder=darken(mycolors(m,:));
    else
        cborder=darken(c);
    end
    v='o';
    if plotbal
        v=mymarkers(1+mod(m-1,length(mymarkers)));
    end
    plot3(placex,placey,1,v,'MarkerFaceColor',c,'MarkerSize',max(1e-3,20*tm(nkworking(m))),'Color',cborder,'LineWidth',3, 'LineSmoothing','off');
    plot3(placex,placey,1,v,'MarkerFaceColor','none','MarkerSize',max(1e-3,9+20*tm(nkworking(m))),'Color',cborder,'LineWidth',3, 'LineSmoothing','off');
    plot3(placex,placey,1,v,'MarkerFaceColor','none','MarkerSize',max(1e-3,18+20*tm(nkworking(m))),'Color',cborder,'LineWidth',3, 'LineSmoothing','off');
end

if plotids
    for i=1:size(coordinates,1)
        placex=coordinates(i,1);
        placey=coordinates(i,2);
        text('Position',[placex,placey,1],'String',num2str(i),'FontSize',8,'HorizontalAlignment','center');
    end
end

% Adapt visible range and remove axes
set(gca,'Visible','off');
if mapbool
    xlim([2.5*imgW/72 imgW*71/72]);
    ylim([0.17*imgH 0.67*imgH]);
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