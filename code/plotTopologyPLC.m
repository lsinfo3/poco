%% Plots the distances in a topology
function [tmvals,latencyvals,mycolors,meanlatencyvals,assignments]=plotTopologyPLC(mapbool,topology,coordinates,plotstyle,controllerplaces,controllersfailed,nodesfailed,linksfailed,figureid,axesid,tmPlain,mydiameter,mycolors,mymarkers)
tm=log(1+tmPlain/nanmax(tmPlain)*10);
cla(axesid,'reset');
set(0,'CurrentFigure',figureid)
set(figureid,'CurrentAxes',axesid);
if mapbool

    %fname =  strcat('file:/',pwd,'\images\worldmap.png');
    fname='worldmap.png';
%    disp('Test')
    img = imread(fname,'png');
    [imgH,imgW,~] = size(img);
    
    %# Mercator projection
    [x,y] = mercatorProjection(coordinates(:,1), coordinates(:,2), imgW, imgH);
    coordinates=[x y];
    
    %# plot markers on map
    imagesc(img)
end

% gplot(topology~=inf,coordinates,'-')%

% gray links
% [rlink,clink]=find(topology~=inf);
% beginx=coordinates(rlink,1);
% beginy=coordinates(rlink,2);
% endx=coordinates(clink,1);
% endy=coordinates(clink,2);
% for m=1:length(beginx)
%     plot([beginx(m) endx(m)],[beginy(m) endy(m)],'Color',[0.8 0.8 0.8],'LineWidth',2, 'LineSmoothing','off');
% end

% ,'Color',[0.8 0.8 0.8],'LineWidth',3);
hold on
plotids=0;  % boolean to show ids
plotdistnc=0; % boolean to color according to node-to-controller distances
plotbal=0; % boolean to color and shape according to balancing
plotdistcc=0; % boolean to color according to inter-controller distances
plottm=0; % boolean if tm should be used for node sizes
plotheatmap=0; % boolean if heatmap should be shown

if exist('plotstyle','var')
    if ~isempty(strfind(plotstyle,'ids'))
        plotids=1;
    end
    
    if ~isempty(strfind(plotstyle,'distnc'))
        plotdistnc=1;
    end
    
    if ~isempty(strfind(plotstyle,'distcc'))
        plotdistcc=1;
    end
    
    if ~isempty(strfind(plotstyle,'balance'))
        plotbal=1;
    end
    
    if ~isempty(strfind(plotstyle,'heat-map'))
        plotheatmap=1;
    end
    
    if ~isempty(strfind(plotstyle,'tm'))
        plottm=1;
    end
end

if ~exist('controllersfailed','var')
    controllersfailed=[];
end

if ~exist('nodesfailed','var')
    nodesfailed=[];
end

if ~exist('linksfailed','var')
    linksfailed=[];
    linksontop=0;
else
    linksontop=1;
end

if ~exist('mydiameter','var')
    mydist=topology;
    mydist(mydist==inf)=nan;
    mydiameter=nanmax(nanmax(mydist));
end

if ~exist('mycolors','var')
    mycolors=[hsv(5);hsv(length(controllerplaces)-5)];
end

if ~exist('mymarkers','var')
    mymarkers='o';%mymarkers='odsv^pdshov^x+*';
end

if ~exist('tm','var') || plottm==0
    tm=ones(1,size(topology,1));
end

if plotheatmap
    controllersfailed=[];
    nodesfailed=[];
    linksfailed=[];
end

nkworking=setdiff(controllerplaces,[nodesfailed controllersfailed]);

% to provide from errors due to unexpected input
if isempty(nkworking)
    plotdistnc=0; % boolean to color according to node-to-controller distances
    plotbal=0; % boolean to color and shape according to balancing
    plotdistcc=0; % boolean to color according to inter-controller distances
    plotheatmap=0; % boolean if heatmap should be shown
end

controllersfailed=intersect([controllersfailed intersect(controllerplaces,nodesfailed)],controllerplaces);

% Add broken links for broken nodes
for m=1:length(nodesfailed)
    neighbors=find(topology(:,nodesfailed(m))~=inf);
    linksfailed=[linksfailed;[repmat(nodesfailed(m),length(neighbors),1) neighbors]];
end

% % Plot broken links
% if exist('linksfailed','var') && ~isempty(linksfailed)
%     beginx=coordinates(linksfailed(:,1),1);
%     beginy=coordinates(linksfailed(:,1),2);
%     endx=coordinates(linksfailed(:,2),1);
%     endy=coordinates(linksfailed(:,2),2);
%     for m=1:length(beginx)
%         plot([beginx(m) endx(m)],[beginy(m) endy(m)],'r--','LineWidth',3, 'LineSmoothing','off');
%     end
% end

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
% plot(placex,placey,'o','Color','r','MarkerFaceColor','none','MarkerSize',29);
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
mydistreduced=topologyreduced;
for m=1:length(nodesfailed)
    mydistreduced(nodesfailed(m),nodesfailed(m))=Inf;
end
accessnodes=[];
for m=1:size(mydistreduced,1)
    if length(find(mydistreduced(m,:)~=inf))==1
        mydistreduced(m,:)=Inf;
        mydistreduced(:,m)=Inf;
        coordinates(m,:)
        accessnodes=[accessnodes m];
    end
end
temp=nanmin(mydistreduced(:,nkworking),[],2);
uncovered=setdiff(find(temp==Inf | isnan(temp)),[accessnodes nodesfailed]);
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
            mydistreduced=topologyreduced;
            for m=1:length(nodesfailed)
                mydistreduced(nodesfailed(m),nodesfailed(m))=Inf;
            end
            accessnodes=[];
            for m=1:size(mydistreduced,1)
                if length(find(mydistreduced(m,:)~=inf))==1
                    mydistreduced(m,:)=Inf;
                    mydistreduced(:,m)=Inf;
                    accessnodes=[accessnodes m];
                end
            end
            temp=min(mydistreduced(:,nkworking),[],2);
            uncovered=setdiff(find(temp==Inf),[accessnodes nodesfailed]);
            heatmap(uncovered)=heatmap(uncovered)+1; % add 1 to all controller-less nodes in this scenario
        end
    end
    uncovered=[];
    nodesfailed=[];
end

% size(heatmap)

% distnc,balance
[temp,temp2]=nanmin(mydistreduced(:,nkworking),[],2);

% for output
if ~isempty(temp2)
    latencyvals=temp;
    latencyvals(latencyvals==inf)=nan;
    assignments=temp2;
    meanlatencyvals=nanmean(mydistreduced(:,nkworking),2);
    tmvals=accumarray(temp2,tmPlain,[],@nansum);
else
    latencyvals=[];
    meanlatencyvals=[];
    tmvals=[];
end

[a,b]=sort(tm,'descend');
% size(b)


% colored links % PLC ADAPTED
if plotbal || plotdistnc
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
        elseif plotdistnc
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
        plot3(placex,placey,1,v,'MarkerFaceColor',c,'MarkerSize',max(1e-3,20*tm(m)),'Color',cborder,'LineWidth',3, 'LineSmoothing','off');
    end
end

% Plot controllers
temp=mydistreduced(nkworking,nkworking);
temp(temp==Inf)=nan;
temp=nanmax(temp,[],2);
for m=1:length(nkworking(:))
    placex=coordinates(nkworking(m),1);
    placey=coordinates(nkworking(m),2);
    if plotdistcc
        c=getgreenyellowred(temp(m)/mydiameter);
    elseif plotdistnc
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
    %     plot3(placex,placey,1,v,'MarkerFaceColor','none','MarkerSize',9+20*tm(nkworking(m)),'Color',darken(c),'LineWidth',1, 'LineSmoothing','off');
end

% if linksontop
%     % Plot broken links again on top
%     if exist('linksfailed','var') && ~isempty(linksfailed)
%         beginx=coordinates(linksfailed(:,1),1);
%         beginy=coordinates(linksfailed(:,1),2);
%         endx=coordinates(linksfailed(:,2),1);
%         endy=coordinates(linksfailed(:,2),2);
%         for m=1:length(beginx)
%             plot([beginx(m) endx(m)],[beginy(m) endy(m)],'r','LineWidth',2);
%         end
%     end
% end

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