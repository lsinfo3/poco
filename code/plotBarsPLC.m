%% Plots the distances in a topology
function plotBarsPLC(timeArray,tmvals,contNames,latencyvals,changes,imbalance,mycolors,figureid,axesid1,axesid2,axesid3,axesid4,axesid5,meanlatencyvals,avgLatency,avgTM,changesPLC,sumbalancearrayPLC,myidx,newPLCCalc,bestmaxidx,currentmaxidx)
cla(axesid2,'reset')
set(0,'CurrentFigure',figureid)
set(figureid,'CurrentAxes',axesid2);
if ~isempty(tmvals)
    hold on;
    for i = 1:length(tmvals)
        bar(i, tmvals(i),'FaceColor', mycolors(i,:),'LineWidth',2);
    end
    box off;

    xlim([0.5 length(tmvals)+0.5])
    set(gca,'XTick',1:length(tmvals))
    set(gca,'XTickLabel',regexprep(contNames,'^.*\.([^\.]*\.[^\.]*)$','$1'))
    set(gca,'YGrid','on')
    ylabel(['Controller load',10,'distribution'])
    set(gca,'Visible','on')
end

if newPLCCalc & ~isempty(changesPLC)
    cla(axesid3,'reset')
    set(0,'CurrentFigure',figureid)
    set(figureid,'CurrentAxes',axesid3);
    plotParetoPLC(changesPLC,sumbalancearrayPLC,'ShowSelectedidx',myidx,'Parent',figureid,'Axes',axesid3);
    if ~isempty(bestmaxidx)
        plot(changesPLC(currentmaxidx),sumbalancearrayPLC(currentmaxidx),'o','MarkerSize',5,'MarkerFaceColor',[0 0 1],'Color',darken([0 0 1]));
        plot(changesPLC(bestmaxidx),sumbalancearrayPLC(bestmaxidx),'o','MarkerSize',10,'MarkerFaceColor',[0 1 0],'Color',darken([0 1 0]),'LineWidth',2)
        text('Position',[changesPLC(bestmaxidx),sumbalancearrayPLC(bestmaxidx)],'String','    Overall best according to \pi^{max latency}_{\0}','VerticalAlignment','middle','HorizontalAlignment','left','Color',darken([0 1 0]),'FontSize',9);

        plot(changesPLC(currentmaxidx(end)),sumbalancearrayPLC(currentmaxidx(end)),'o','MarkerSize',10,'MarkerFaceColor',[0 0 1],'Color',darken([0 0 1]),'LineWidth',2)
        text('Position',[changesPLC(currentmaxidx(end)),sumbalancearrayPLC(currentmaxidx(end))],'String','    Current best according to \pi^{max latency}_{\0}','VerticalAlignment','middle','HorizontalAlignment','left','Color',darken([0 0 1]),'FontSize',9);    
    end
    text('Position',[changesPLC(myidx),sumbalancearrayPLC(myidx)],'String','    Current Placement','VerticalAlignment','middle','HorizontalAlignment','left','Color','r','FontSize',9);

    xlabel('Accumulated number of changes')
    ylabel('Average  \pi^{imbalance}_{\0}')
end

cla(axesid4,'reset')
set(0,'CurrentFigure',figureid)
set(figureid,'CurrentAxes',axesid4);
if ~isempty(avgLatency)
    [ax,h1,h2]=plotyy(24*60*(timeArray-min(timeArray)),1000*avgLatency,24*60*(timeArray-min(timeArray)),avgTM,'plot');
    box off;
    set(h1,'LineWidth',2)
    set(h2,'LineWidth',2)
    xlabel('Time (min)')
    set(ax(1),'ylim',[0 450],'ytick',[0 450],'yminorgrid','on');
    ylims2=get(ax(2),'Ylim');
    set(ax(2),'ytick',ylims2,'yminorgrid','on');
    set(get(ax(1),'Ylabel'),'String',['Avg node-to-controller',10,' latency (msec)'])
    set(get(ax(2),'Ylabel'),'String','Avg total load')
end

cla(axesid5,'reset')
set(0,'CurrentFigure',figureid)
set(figureid,'CurrentAxes',axesid5);
if ~isempty(avgLatency)
    [ax,h1,h2]=plotyy(24*60*(timeArray-min(timeArray)),changes,24*60*(timeArray-min(timeArray)),imbalance,'plot');
    box off;
    set(h1,'LineWidth',2)
    set(h2,'LineWidth',2)
    xlabel('Time (min)')
    ylims1=get(ax(1),'Ylim');
    set(ax(1),'ytick',ylims1,'yminorgrid','on');
    ylims2=get(ax(2),'Ylim');
    set(ax(2),'ytick',ylims2,'yminorgrid','on');
    set(get(ax(1),'Ylabel'),'String',['Controller assignment',10,' changes'])
    set(get(ax(2),'Ylabel'),'String','Load imbalance  \pi^{imbalance}_{\0}')
end

cla(axesid1,'reset')
set(0,'CurrentFigure',figureid)
set(figureid,'CurrentAxes',axesid1);
if ~isempty(latencyvals)
    hold on;
    box off;
    ylim([0 600])
    set(gca,'YGrid','on')
    xlim([0.5 length(latencyvals)+0.5])
    set(gca,'XTick',1:length(latencyvals))
    ylabel(['Node-to-controller',10,'latencies (msec)'])
    xlabel('Node ID')
    set(gca,'Visible','on')
    ml=min(600,1000*latencyvals);
    ml(isnan(latencyvals))=nan;
    meanml=min(600,1000*meanlatencyvals);
    meanml(isnan(meanlatencyvals))=nan;
    for i = 1:length(latencyvals)
        bar(i, ml(i),'FaceColor', getgreenyellowred(latencyvals(i)),'LineWidth',2);
        plot(i+[-0.4 +0.4], [1 1]*meanml(i),'k+-','LineWidth',2);
        if ~isnan(meanlatencyvals(i)) & meanlatencyvals(i)<inf & meanlatencyvals(i)<0.6
            text('Position',[i, 1000*meanlatencyvals(i)],'String',sprintf('%.0f',1000*meanlatencyvals(i)),'VerticalAlignment','bottom','HorizontalAlignment','center','Color','k','FontSize',9);
        elseif isnan(meanlatencyvals(i))
            text('Position',[i, 25],'String',sprintf('cont\nless'),'VerticalAlignment','bottom','HorizontalAlignment','center','Color','k','FontSize',9);
        elseif meanlatencyvals(i)>=0.6
            text('Position',[i, 600],'String','>600','VerticalAlignment','bottom','HorizontalAlignment','center','Color','k','FontSize',9);
        else
            text('Position',[i, 25],'String','broken','VerticalAlignment','bottom','HorizontalAlignment','center','Color','k','FontSize',9);
        end
    end
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