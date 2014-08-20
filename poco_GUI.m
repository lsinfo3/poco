% POCO_GUI Provides a graphical user interface for plotting resilient
%   Pareto-based Optimal COntrollerplacements.
%
%   Copyright 2012-2014 David Hock, Stefan Geiﬂler, Fabian Helmschrott,
%                       Steffen Gebert
%                       Chair of Communication Networks, Uni Wuerzburg
%
function poco_GUI
% Check Matlab-version
matlabVersion=str2num(regexprep(version('-release'),'[^0-9]','')) ;

addpath('code');
addpath('images');
addpath('planetlab');
topology=[];
topology_org=[];
coordinates=[];
tm=[];
tm_org=[];
solution=[];
tmbool=0;
nk=[];
active_k=0;
optType='';
paretoidx=[];
valuex='';
valuey='';
tmindex=1;
last20plots=[];
last20plotsidx=1;
optTm=0;
nodenames={};
selectednode=[];
mValues={};
distanceMatrix=[];
distanceMatrix_org=[];
topologyName = '';
plcTopo = 0;
currPlacement=0;
textXaxis = '';
textYaxis = '';
isHierarchic=0;
highLatency=300;

topologyPLC=[];
coordinatesPLC=[];
tmPLC=[];
nodenamesPLC={};


controllerplacesOriginal=[];
controllernamesOriginal={};
controllerplacesPLC=[];
failedControllersPLC=[];
failedControllersOriginal=[];
failedControllerNamesOriginal={};
failedNodesPLC=[];

timeArray=[];
avgLatencyArray=[];
avgTMArray=[];
changes=[];
imbalance=[];
assignments=[];
maxmaxarrayPLC=[];
sumuncoveredarrayPLC=[];
sumbalancearrayPLC=[];
changesPLC=[];
balancevalsPLC=[];
balancevalsPLCNew=[];
maxarrayPLC=[];
uncoveredarrayPLC=[];
balancearrayPLC=[];
plcCounter=0;
plcFileCounter=11100;
newPLCCalc=0;
currentmaxidxHist=[];

% Variables to save the PLC history
tmvals=[];
latencyvals=[];
myidx='';
mycolors=[];
meanlatencyvals=[];
bestmaxidx='';
compactViewSize = [0.05 0.04 0.72 0.95];
fullViewSize = [0.05 0.5 0.72 0.47];


mValues={};

mValuesF={'<html><font size="2">Max node to controller latency (failure free)</font></html>', 'maxLatencyN2C',['Max node to controller latency',10,'(failure free)'];...
    '<html><font size="2">Controller imbalance (failure free)</font></html>', 'controllerImbalance','Controller imbalance (failure free)';...
    '<html><font size="2">Max controller to controller latency (failure free)</font></html>', 'maxLatencyC2C',['Max controller to controller',10,'latency (failure free)'];...
    '<html>&pi;<sub><i>R</i></sub><sup>max latency</sup></html>', 'maxarrayall','\pi^{max latency}_{\it{R}}';...
    '<html>&pi;<sub><i>R</i></sub><sup>imbalance</sup></html>', 'balancemaxarrayall','\pi^{imbalance}_{\it{R}}';...
    '<html>&pi;<sub><i>R</i></sub><sup>max latency</sup>(Inter-controller)</html>', 'maxarrayCCall','\pi^{max latency}_{\it{R}} (Inter-controller)';...
    '<html>&pi;<sub><i>R</i></sub><sup>controller-less</sup></html>', 'maxNumberOfControllerlessNodes','\pi^{controller-less}_{\it{R}}'};

mValuesN={'<html><font size="2">Max node to controller latency (failure free)</font></html>', 'maxLatencyN2C',['Max node to controller latency',10,'(failure free)'];...
    '<html><font size="2">Controller imbalance (failure free)</font></html>', 'controllerImbalance','Controller imbalance (failure free)';...
    '<html><font size="2">Max controller to controller latency (failure free)</font></html>', 'maxLatencyC2C',['Max controller to controller',10,'latency (failure free)'];...
    '<html><font size="2">Max node to controller latency (up to two node failures)</font></html>', 'maxLatencyN2CAllNodeFailures',['Max node to controller latency',10,'(up to two node failures)'];...
    '<html><font size="2">Controller imbalance (up to two node failures)</font></html>', 'controllerImbalanceAllNodeFailures',['Controller imbalance',10,'(up to two node failures)'];...
    '<html><font size="2">Max controller to controller latency (up to two node failures)</font></html>', 'maxLatencyC2CAllNodeFailures',['Max controller to controller',10,'latency (up to two node failures)'];...
    '<html><font size="2">Controller-less nodes (up to two node failures)</font></html>', 'maxNumberOfControllerlessNodes',['Controller-less nodes',10,'(up to two node failures)']};

mValuesC={'<html><font size="2">Max node to controller latency (failure free)</font></html>', 'maxLatencyN2C',['Max node to controller latency',10,'(failure free)'];...
    '<html><font size="2">Controller imbalance (failure free)</font></html>', 'controllerImbalance','Controller imbalance (failure free)';...
    '<html><font size="2">Max controller to controller latency (failure free)</font></html>', 'maxLatencyC2C',['Max controller to controller',10,'latency (failure free)'];...
    '<html><font size="2">Max node to controller latency (up to k-1 controller failures)</font></html>', 'maxLatencyN2CAllControllerFailures',['Max node to controller latency',10,'(up to k-1 controller failures)'];...
    '<html><font size="2">Max controller imbalance (up to k-1 controller failures)</font></html>', 'controllerImbalanceAllControllerFailures',['Max controller imbalance',10,'(up to k-1 controller failures)'];...
    '<html><font size="2">Max controller to controller latency (up to k-1 controller failures)</font></html>', 'maxLatencyC2CAllControllerFailures',['Max controller to controller latency',10,'(up to k-1 controller failures)'];...
    '<html><font size="2">Controller-less nodes (up to k-1 controller failures)</font></html>', 'maxNumberOfControllerlessNodes',['Controller-less nodes ',10,'(up to k-1 controller failures)']};

rbValuesC={'<html></html>',...
    '<html><font size="2">Failure free</font></html>',...
    '<html><font size="2">Worst max node to controller latency (up to k-1 controller failures)</font></html>',...
    '<html><font size="2">Worst controller imbalance (up to k-1 controller failures)</font></html>'
    };

rbValuesN={'<html></html>',...
    '<html><font size="2">Failure free</font></html>',...
    '<html><font size="2">Worst max node to controller latency (up to two node failures)</font></html>',...
    '<html><font size="2">Worst controller imbalance (up to two node failures)</font></html>',...
    '<html><font size="2">Worst max controller to controller latency (up to two node failures)</font></html>',...
    '<html><font size="2">Worst controller-less nodes (up to two node failures)</font></html>'};

rbValues=[];

pValues={};

pValuesF={'<html></html>',...
    '<html><font size="2">Max node to controller latency (failure free)</font></html>',...
    '<html><font size="2">Controller imbalance (failure free)</font></html>',...
    '<html><font size="2">Max controller to controller latency (failure free)</font></html>'};

pValuesC={'<html></html>',...
    '<html><font size="2">Max node to controller latency (failure free)</font></html>',...
    '<html><font size="2">Controller imbalance (failure free)</font></html>',...
    '<html><font size="2">Max controller to controller latency (failure free)</font></html>',...
    '<html><font size="2">Max node to controller latency (up to k-1 controller failures)</font></html>',...
    '<html><font size="2">Controller imbalance (up to k-1 controller failures)</font></html>'
    };

pValuesN={'<html></html>',...
    '<html><font size="2">Max node to controller latency (failure free)</font></html>',...
    '<html><font size="2">Controller imbalance (failure free)</font></html>',...
    '<html><font size="2">Max controller to controller latency (failure free)</font></html>',...
    '<html><font size="2">Max node to controller latency (up to two node failures)</font></html>',...
    '<html><font size="2">Controller imbalance (up to two node failures)</font></html>',...
    '<html><font size="2">Max controller to controller latency (up to two node failures)</font></html>',...
    '<html><font size="2">Controller-less nodes (up to two node failures)</font></html>'};

screensize=get(0,'Screensize');
if screensize(3)<1000 || screensize(4)<800
    initialpos=screensize-[0 -30 0 70];
else
    initialpos=[screensize(3:4)-[1000 840] 1000 800];
end
hMainFigure    =   figure('MenuBar','none','Toolbar','none','HandleVisibility','on','Name', 'POCO','NumberTitle','off','Position',initialpos,'Resize','on','Color','w','CloseRequestFcn',@closeGUI);
hFigurePLC   =   figure('MenuBar','none','Toolbar','none','HandleVisibility','on','Name', 'PLC Live View','NumberTitle','off','Position',[0 0 400 300],'Resize','on','Color','w','Visible','off','CloseRequestFcn',@closePLCFig);
inputFig = '';
% For plots
hPanelAxes2 = uipanel('Parent',hMainFigure,'Units','normalized','HandleVisibility','on','Position',[0.05 0.11 0.72 0.34],'BorderType','none','BorderWidth',0,'BackgroundColor','none');
hPanelAxes1 = uipanel('Parent',hMainFigure,'Units','normalized','HandleVisibility','on','Position',fullViewSize,'BorderType','none','BorderWidth',0,'BackgroundColor','none');
hPlotAxes1      =   axes('Parent', hPanelAxes1,'Units', 'normalized','HandleVisibility','on','Position',[0 0 0.98 1],'Visible','off','Box','off');
hPlotAxes2      =   axes('Parent', hPanelAxes2,'Units', 'normalized','HandleVisibility','on','Position',[0.08 0.25 0.9 0.7],'Visible','off');
hPlotAxesPLC      =   axes('Parent', hFigurePLC,'Units', 'normalized','HandleVisibility','on','Position',[0.03 0.57 0.94 0.43],'Visible','off');
hPlotAxesPLCbar1 = axes('Parent', hFigurePLC,'Units', 'normalized','HandleVisibility','on','Position',[0.072 0.03 0.9 0.13],'Visible','off');
hPlotAxesPLCbar2      =   axes('Parent', hFigurePLC,'Units', 'normalized','HandleVisibility','on','Position',[0.07 0.21 0.38 0.13],'Visible','off');
hPlotAxesPLCbar2b      =   axes('Parent', hFigurePLC,'Units', 'normalized','HandleVisibility','on','Position',[0.57 0.21 0.38 0.13],'Visible','off');
hPlotAxesPLCbar3     =   axes('Parent', hFigurePLC,'Units', 'normalized','HandleVisibility','on','Position',[0.07 0.39 0.38 0.13],'Visible','off');
hPlotAxesPLCbar3b     =   axes('Parent', hFigurePLC,'Units', 'normalized','HandleVisibility','on','Position',[0.57 0.39 0.38 0.13],'Visible','off');

% File menu
hFileMenu = uimenu('Parent',hMainFigure,'HandleVisibility','on','Label','File');
hOpenMenu = uimenu('Parent',hFileMenu,'HandleVisibility','on','Label','Open...','Callback', @OpenTopologyCallback,'Accelerator','O');
hSaveAsMenu = uimenu('Parent',hFileMenu,'HandleVisibility','on','Label','Save as','Accelerator','S','Enable','off','Callback', @SaveAsTopologyCallback);
hResetAllMenu = uimenu('Parent',hFileMenu,'Label','Close','HandleVisibility','on','Callback', @resetAllHandle,'Accelerator','W','Enable','off');
hImportMenu = uimenu('Parent',hFileMenu,'Label','Import','HandleVisibility','on','Separator','on','Enable','off');
hImportNodeWeightsMenu = uimenu('Parent',hImportMenu,'Label','Node weights','HandleVisibility','on','Callback',@importNodeWeights);
hExportMenu = uimenu('Parent',hFileMenu,'HandleVisibility','on','Label','Export','Enable','off');
hExportImageMenuitem = uimenu('Parent',hExportMenu,'HandleVisibility','on','Label','Save topology as image','Callback',{@exportPlotCallback,''});
hExportGephiMenuitem = uimenu('Parent',hExportMenu,'HandleVisibility','on','Label','Save Gephi csv','Callback',@exportGephiCSV);
hExitMenu = uimenu('Parent',hFileMenu','Label','Exit','HandleVisibility','on','Separator','on','Callback', @closeGUI);

% Edit menu
hEditMenu = uimenu('Parent',hMainFigure,'HandleVisibility','on','Label','Edit','Enable','off');
hUndoMenuitem = uimenu('Parent',hEditMenu,'Label','Undo','HandleVisibility','on','Callback', @undoPlot,'Enable','off','Accelerator','Z');
hRedoMenuitem = uimenu('Parent',hEditMenu,'Label','Redo','HandleVisibility','on','Callback', @redoPlot,'Enable','off','Accelerator','Y');
hResetFields = uimenu('Parent',hEditMenu,'Label','Reset fields','HandleVisibility','on','Callback', @resetFieldsHandle,'Accelerator','R');
hNodeOptionsMenu = uimenu('Parent',hEditMenu,'Label','Node options','HandleVisibility','on','Separator','on','Enable','off');
hToggleControllerItem = uimenu('Parent',hNodeOptionsMenu,'Label','Toggle Controller','HandleVisibility','on','Callback', @toggleController,'Accelerator','E','Separator','on');
hToggleControllerFailureItem = uimenu('Parent',hNodeOptionsMenu,'Label','Toggle Controller Failure','HandleVisibility','on','Callback', @toggleControllerFailure,'Accelerator','F');
hToggleNodeFailureItem = uimenu('Parent',hNodeOptionsMenu,'Label','Toggle Node Failure','HandleVisibility','on','Callback', @toggleNodeFailure,'Accelerator','G');
hEdgeOptionsMenu = uimenu('Parent',hEditMenu,'Label','Edge options','HandleVisibility','on');
hCreateEdgeMenuitem = uimenu('Parent',hEdgeOptionsMenu,'Label','Create edge','HandleVisibility','on','Callback',@createEdgeInput);
hDeleteEdgeMenuitem = uimenu('Parent',hEdgeOptionsMenu,'Label','Delete edge','HandleVisibility','on','Callback',@deleteEdgeInput);
hResetEdgeMenuitem = uimenu('Parent',hEdgeOptionsMenu,'Label','Reset edges','HandleVisibility','on','Callback',@resetEdges);
hNodeWeightsMenu = uimenu('Parent',hEditMenu,'Label','Node Weights','HandleVisibility','on');
hEditNodeWeightsMenuitem = uimenu('Parent',hNodeWeightsMenu,'Label','Edit','HandleVisibility','on','Callback',@editNodeWeightsInput);
hResetNodeWeightsMenuitem = uimenu('Parent',hNodeWeightsMenu,'Label','Reset','HandleVisibility','on','Callback',@resetNodeWeights);
hLatenciesMenu = uimenu('Parent',hEditMenu,'Label','Latencies','HandleVisibility','on');
hEditLatenciesMenuitem = uimenu('Parent',hLatenciesMenu,'Label','Edit','HandleVisibility','on','Callback',@editLatencies);
hResetLatenciesMenuitem = uimenu('Parent',hLatenciesMenu,'Label','Reset','HandleVisibility','on','Callback',@resetLatencies);

% Placements menu
hPlacementsMenu  = uimenu('Parent',hMainFigure,'HandleVisibility','on','Label','Placements','Enable','off');
hCalculatePlacementsMenu  =   uimenu('Parent',hPlacementsMenu,'Label','Calculate placements','HandleVisibility','on');
hFFMenuitem.base  =   uimenu('Parent',hCalculatePlacementsMenu,'Label','Failure free','HandleVisibility','on');
for i=1:5
    hFFMenuitem.(['FFk' num2str(i)])  =   uimenu('Parent',hFFMenuitem.base,'Label',['k=' num2str(i)],'HandleVisibility','on','Callback',{@optimizeFailureFree,i});
end
hNMenuitem.base  =   uimenu('Parent',hCalculatePlacementsMenu,'Label','Up to two node failures','HandleVisibility','on');
for i=3:5
    hNMenuitem.(['Nk' num2str(i)])  =   uimenu('Parent',hNMenuitem.base,'Label',['k=' num2str(i)],'HandleVisibility','on','Callback',{@optimizeNodeFailure,i});
end
hRMenuitem = uimenu('Parent',hNMenuitem.base,'Label','Find minimum resilient k','HandleVisibility','on','Callback',@findMinimumK);
hCMenuitem.base  =   uimenu('Parent',hCalculatePlacementsMenu,'Label','Up to k-1 controller failures','HandleVisibility','on');
for i=1:5
    hCMenuitem.(['Ck' num2str(i)])  =   uimenu('Parent',hCMenuitem.base,'Label',['k=' num2str(i)],'HandleVisibility','on','Callback',{@optimizeControllerFailure,i});
end
hNodeWeightsMenuItem = uimenu('Parent',hCalculatePlacementsMenu,'Label','Use node weights','HandleVisibility','on','Checked','off','Separator','on','Callback', @toggleNodeWeights,'Visible','off','Enable','off');
hOpenPlacementsMenuitem  =   uimenu('Parent',hPlacementsMenu,'Label','Open...','HandleVisibility','on','Callback',@loadPlacementsCallback,'Separator','on');
hSavePlacementsMenuitem  =   uimenu('Parent',hPlacementsMenu,'Label','Save','HandleVisibility','on','Callback',@savePlacementsCallback,'Enable','off');

% View menu
hViewMenu = uimenu('Parent',hMainFigure,'HandleVisibility','on','Label','View','Enable','on');
hPlotOptionsMenu = uimenu('Parent',hViewMenu,'Label','Plot options','HandleVisibility','on','Enable','off');
hCheckBoxMenuIDs = uimenu('Parent',hPlotOptionsMenu,'Label','Node IDs','HandleVisibility','on','Visible','on','Callback',{@plotFiguresCallbackMenu,4},'Accelerator','4');
hCheckBoxMenuTM = uimenu('Parent',hPlotOptionsMenu,'Label','Node weights','HandleVisibility','on','Visible','on','Callback',{@plotFiguresCallbackMenu,6},'Accelerator','6');
hCheckBoxMenuDistNC = uimenu('Parent',hPlotOptionsMenu,'Label','<html>Max node to controller latency</html>','HandleVisibility','on','Visible','on','Callback',{@plotFiguresCallbackMenu,1},'Accelerator','1');
hCheckBoxMenuBalance = uimenu('Parent',hPlotOptionsMenu,'Label','<html>Controller imbalance</html>','HandleVisibility','on','Visible','on','Callback',{@plotFiguresCallbackMenu,2},'Accelerator','2');
hCheckBoxMenuDistCC = uimenu('Parent',hPlotOptionsMenu,'Label','<html>Max controller to controller latency</html>','HandleVisibility','on','Visible','on','Callback',{@plotFiguresCallbackMenu,3},'Accelerator','3');
hCheckBoxMenuHeatmap = uimenu('Parent',hPlotOptionsMenu,'Label','<html>Controller-less nodes heatmap</html>','HandleVisibility','on','Visible','on','Callback',@heatmapCheckCallbackMenu,'Accelerator','5');
hHierarchicalShowIconsMenuitem = uimenu('Parent',hPlotOptionsMenu,'Label','Use icons','HandleVisibility','on','Visible','off','Checked','off','Callback',{@hierarchicalPlotOptionCallback,3});
hHierarchicalShowLinksMenuitem = uimenu('Parent',hPlotOptionsMenu,'Label','Links','HandleVisibility','on','Visible','off','Checked','off','Callback',{@hierarchicalPlotOptionCallback,4});
hHierarchicalShowBaseStationsMenuitem = uimenu('Parent',hPlotOptionsMenu,'Label','Base Stations','HandleVisibility','on','Visible','off','Checked','off','Callback',{@hierarchicalPlotOptionCallback,5});
hHierarchicalShowAccessNodesMenuitem = uimenu('Parent',hPlotOptionsMenu,'Label','Access Nodes','HandleVisibility','on','Visible','off','Callback',{@hierarchicalPlotOptionCallback,6});
hHierarchicalShowSGWlocationsMenuitem = uimenu('Parent',hPlotOptionsMenu,'Label','SGW locations','HandleVisibility','on','Visible','off','Callback',{@hierarchicalPlotOptionCallback,7});
hHierarchicalShowSGWsMenuitem = uimenu('Parent',hPlotOptionsMenu,'Label','SGWs','HandleVisibility','on','Visible','off','Callback',{@hierarchicalPlotOptionCallback,8});
hHierarchicalShowVirtualSGWsMenuitem = uimenu('Parent',hPlotOptionsMenu,'Label','Virtual SGWs','HandleVisibility','on','Visible','off','Callback',{@hierarchicalPlotOptionCallback,9},'Enable','off');
hHierarchicalShowMegaEventsMenuitem = uimenu('Parent',hPlotOptionsMenu,'Label','MegaEvents','HandleVisibility','on','Visible','off','Callback',{@hierarchicalPlotOptionCallback,10},'Enable','off');
hHierarchicalShowMegaEventResourcesMenuitem = uimenu('Parent',hPlotOptionsMenu,'Label','MegaEvent Resources','HandleVisibility','on','Visible','off','Callback',{@hierarchicalPlotOptionCallback,11},'Enable','off');
hHierarchicalShowNeplusMenuitem = uimenu('Parent',hPlotOptionsMenu,'Label','NE+','HandleVisibility','on','Visible','off','Callback',{@hierarchicalPlotOptionCallback,12});
hPredefinedViewsMenu = uimenu('Parent',hViewMenu,'Label','Predefined views','HandleVisibility','on','Enable','off');
hViewMaxLatencyMenuitem = uimenu('Parent',hPredefinedViewsMenu,'Label','<html>Max node to controller latency only</html>','HandleVisibility','on','Callback',{@plotFiguresCallbackMenu,7},'Accelerator','7');
hViewImbalanceMenuitem = uimenu('Parent',hPredefinedViewsMenu,'Label','<html>Controller imbalance only</html>','HandleVisibility','on','Callback',{@plotFiguresCallbackMenu,8},'Accelerator','8');
hViewMaxLatencyCCMenuitem = uimenu('Parent',hPredefinedViewsMenu,'Label','<html>Max controller to controller latency only</html>','HandleVisibility','on','Callback',{@plotFiguresCallbackMenu,9},'Accelerator','9');
hViewControllerlessMenuitem = uimenu('Parent',hPredefinedViewsMenu,'Label','<html>Controller-less nodes heatmap only</html>','HandleVisibility','on','Callback',{@plotFiguresCallbackMenu,0},'Accelerator','0');
hHierarchicalView1 = uimenu('Parent',hPredefinedViewsMenu,'Label','Assignment SGW','HandleVisibility','on','Visible','off','Callback',{@hierarchicalPlotOptionCallback,13},'Accelerator','1');
hHierarchicalView2 = uimenu('Parent',hPredefinedViewsMenu,'Label','Assignment SGW no BS','HandleVisibility','on','Visible','off','Callback',{@hierarchicalPlotOptionCallback,14},'Accelerator','2');
hHierarchicalView3 = uimenu('Parent',hPredefinedViewsMenu,'Label','Mega Events + SGW','HandleVisibility','on','Visible','off','Callback',{@hierarchicalPlotOptionCallback,15},'Accelerator','3');
hHierarchicalView4 = uimenu('Parent',hPredefinedViewsMenu,'Label','Basic','HandleVisibility','on','Visible','off','Callback',{@hierarchicalPlotOptionCallback,16},'Accelerator','4');
hHierarchicalViewLatStat = uimenu('Parent',hPredefinedViewsMenu,'Label','Static - Latency','HandleVisibility','on','Visible','off','Callback',{@hierarchicalPlotOptionCallback,17},'Accelerator','5');
hHierarchicalViewBalStat = uimenu('Parent',hPredefinedViewsMenu,'Label','Static - Assignment','HandleVisibility','on','Visible','off','Callback',{@hierarchicalPlotOptionCallback,18},'Accelerator','6');
hHierarchicalViewLatDyn = uimenu('Parent',hPredefinedViewsMenu,'Label','Dynamic - Latency','HandleVisibility','on','Visible','off','Callback',{@hierarchicalPlotOptionCallback,19},'Accelerator','7');
hHierarchicalViewBalDyn = uimenu('Parent',hPredefinedViewsMenu,'Label','Dynamic - Assignment','HandleVisibility','on','Visible','off','Callback',{@hierarchicalPlotOptionCallback,20},'Accelerator','8');
hThemesMenu = uimenu('Parent',hViewMenu,'Label','Themes','HandleVisibility','on','Enable','on','Separator','on');
hThemesClassicMenuitem = uimenu('Parent',hThemesMenu,'Label','Classic','HandleVisibility','on','Enable','on','Callback',{@changeThemeCallback,[1 1 1], [0 0 0]},'Checked','on','Accelerator','');
hThemesDarkMenuitem = uimenu('Parent',hThemesMenu,'Label','Dark','HandleVisibility','on','Enable','on','Callback',{@changeThemeCallback,[0.26 0.26 0.26],[0.8 0.8 0.8]},'Accelerator','K');
hViewModeMenu = uimenu('Parent',hViewMenu,'Label','Mode','HandleVisibility','on','Enable','on');
hFullViewMenuitem = uimenu('Parent',hViewModeMenu,'Label','Full','HandleVisibility','on','Callback',@fullViewCallback,'Checked','on','Accelerator','');
hCompactViewMenuitem = uimenu('Parent',hViewModeMenu,'Label','Compact','HandleVisibility','on','Callback',@compactViewCallback,'Accelerator','T');
hExtractMenuitem = uimenu('Parent',hViewMenu,'Label','Duplicate plot','HandleVisibility','on','Callback', @duplicatePlot,'Accelerator','D','Separator','on','Enable','off');

% PLC Menu
hPLCMenu      =   uimenu('Parent',hMainFigure,'HandleVisibility','on','Label','POCO PLC','Visible','on','Enable','off');
hInitPLCMenuitem = uimenu('Parent',hPLCMenu,'Label','Start POCO PLC','HandleVisibility','on','Callback',@InitPOCOPLC,'Accelerator','P');
hStopPLCMenuitem = uimenu('Parent',hPLCMenu,'Label','Stop POCO PLC','HandleVisibility','on','Callback',@StopPOCOPLC,'Visible','off');
hLoadHistPLCMenuitem = uimenu('Parent',hPLCMenu,'Label','Load history...','HandleVisibility','on','Callback',@loadPLCHistory,'Visible','off','Separator','on');
hSaveHistPLCMenuitem = uimenu('Parent',hPLCMenu,'Label','Save Planetlab history','HandleVisibility','on','Callback',@savePLCHistoryCallback,'Visible','off','Enable','off');
hStartPlanetlabPlotLoopMenuitem  =   uimenu('Parent',hPLCMenu,'Label','Start Planetlab Plot Loop','HandleVisibility','on','Callback', {@startPLCLoopCallback},'Accelerator','#','Enable','off','Visible','off','Separator','on');
hStopPlanetlabPlotLoopMenuitem  =   uimenu('Parent',hPLCMenu,'Label','Stop Planetlab Plot Loop','HandleVisibility','on','Callback', {@stopPLCLoopCallback},'Accelerator','-','Enable','off','Visible','off');
hStartPlanetlabCalcLoopMenuitem  =   uimenu('Parent',hPLCMenu,'Label','Start Planetlab Calc Loop','HandleVisibility','on','Callback', {@startPLCCalcCallback},'Accelerator','#','Enable','off','Visible','off');
hStopPlanetlabCalcLoopMenuitem  =   uimenu('Parent',hPLCMenu,'Label','Stop Planetlab Calc Loop','HandleVisibility','on','Callback', {@stopPLCCalcCallback},'Accelerator','-','Enable','off','Visible','off');
hFetchPlanetlabDataMenuitem  =   uimenu('Parent',hPLCMenu,'Label','Fetch Planetlab Data','HandleVisibility','on','Callback', {@fetchPLCdataCallback},'Accelerator','U','Visible','off');

% Hierarchical-Review Menu
hHierarchicalMenu = uimenu('Parent',hMainFigure,'Label','SGW placement','HandleVisibility','on','Visible','on');
hInitHierarchicalMenuitem = uimenu('Parent',hHierarchicalMenu,'Label','Start','HandleVisibility','on','Visible','on','Callback',@initHierarchical);
hstopHierarchicalMenuitem = uimenu('Parent',hHierarchicalMenu,'Label','Stop','HandleVisibility','on','Visible','off','Callback',@stopHierarchicalCallback);
hresetHierarchicalMenuitem = uimenu('Parent',hHierarchicalMenu,'Label','Reset','HandleVisibility','on','Visible','off','Enable','off','Callback',@resetHierarchicalCallback);
hMegaEventsMenu = uimenu('Parent',hHierarchicalMenu,'Label','Place Mega Events','HandleVisibility','on','Visible','off','Separator','on');
hPlacePredefinedMenuitem = uimenu('Parent',hMegaEventsMenu,'Label','Load placements...','HandleVisibility','on','Visible','on','Callback',@loadPredefinedMegaEventsCallback);
hPlaceManualMenuitem = uimenu('Parent',hMegaEventsMenu,'Label','Manual','HandleVisibility','on','Visible','on','Callback',@placeMegaEventsManual);
hPlaceAutoMenuitem = uimenu('Parent',hMegaEventsMenu,'Label','Random','HandleVisibility','on','Visible','on','Callback',@placeRandomMegaEvents);
hSaveMegaEventsMenuitem = uimenu('Parent',hHierarchicalMenu,'Label','Save Mega Events','HandleVisibility','on','Visible','off','Enable','off','Callback',@saveMegaEventsCallback);
hHierarchicalPlotMetricsMenu = uimenu('Parent',hHierarchicalMenu,'Label','Metrics','HandleVisibility','on','Visible','off','Enable','on');
hHierarchicalShowLatencyMenuitem = uimenu('Parent',hHierarchicalPlotMetricsMenu,'Label','Latency','HandleVisibility','on','Visible','on','Checked','off','Callback',{@hierarchicalPlotOptionCallback,1},'Enable','on');
hHierarchicalShowAssociationsMenuitem = uimenu('Parent',hHierarchicalPlotMetricsMenu,'Label','BS-SGW assignment','HandleVisibility','on','Visible','on','Checked','off','Callback',{@hierarchicalPlotOptionCallback,2});
hPlanningMenuitem = uimenu('Parent',hHierarchicalMenu,'Label','Start Planning','HandleVisibility','on','Visible','off','Enable','off','Callback',@startPlanningCallback,'Separator','on');

% Help menu
hHelpMenu = uimenu('Parent',hMainFigure,'HandleVisibility','on','Label','Help');
hOnlinHelpMenu = uimenu('Parent',hHelpMenu,'Label','Open online help','HandleVisibility','on','Callback', @openOnlineHelp);
hAboutMenu = uimenu('Parent',hHelpMenu,'Label','About','HandleVisibility','on','Callback', @openAbout);


% hPlotAxes1 Controls
hLabelControllerIDs = uicontrol('Parent',hMainFigure,'Units','normalized','HorizontalAlignment','left','Position',[0.78 0.91 0.17 0.02],'String','Controller IDs','Style','text','BackgroundColor',get(hMainFigure,'Color'),'Visible','on','FontWeight','bold');
hLabelControllerFailureIDs = uicontrol('Parent',hMainFigure,'Units','normalized','HorizontalAlignment','left','Position',[0.78 0.85 0.17 0.02],'String','Controller failure IDs','Style','text','BackgroundColor',get(hMainFigure,'Color'),'Visible','on','FontWeight','bold');
hLabelNodeFailureIDs = uicontrol('Parent',hMainFigure,'Units','normalized','HorizontalAlignment','left','Position',[0.78 0.79 0.17 0.02],'String','Node failure IDs','Style','text','BackgroundColor',get(hMainFigure,'Color'),'Visible','on','FontWeight','bold');
hEditControllerIDs = uicontrol('Parent',hMainFigure,'Units','normalized','HorizontalAlignment','left','Position',[0.78 0.88 0.14 0.03],'Style','edit','BackgroundColor','w','HandleVisibility','on','Visible','on','Callback',@inputMainFigureCallback);
hEditControllerFailureIDs = uicontrol('Parent',hMainFigure,'Units','normalized','HorizontalAlignment','left','Position',[0.78 0.82 0.14 0.03],'Style','edit','BackgroundColor','w','HandleVisibility','on','Visible','on','Callback',@inputMainFigureCallback);
hEditNodeFailureIDs = uicontrol('Parent',hMainFigure,'Units','normalized','HorizontalAlignment','left','Position',[0.78 0.76 0.14 0.03],'Style','edit','BackgroundColor','w','HandleVisibility','on','Visible','on','Callback',@inputMainFigureCallback);

hLabelPlotOptions = uicontrol('Parent',hMainFigure,'Units','normalized','HorizontalAlignment','left','Position',[0.78 0.69 0.1 0.05],'String','Show:','Style','text','BackgroundColor',get(hMainFigure,'Color'),'Visible','on','FontWeight','bold');
hCheckBoxIDs = uicontrol('Parent',hMainFigure,'Units','normalized','Position',[0.78 0.69 0.15 0.03],'String','Node IDs','Style','checkbox','Value',1,'BackgroundColor',get(hMainFigure,'Color'),'HandleVisibility','on','Visible','on','Callback',@plotFiguresCallback);
hCheckBoxDistNC = uicontrol('Parent',hMainFigure,'Units','normalized','Position',[0.78 0.65 0.17 0.03],'String','<html>Max node to controller latency</sup></html>','Style','checkbox','Value',0,'BackgroundColor',get(hMainFigure,'Color'),'HandleVisibility','on','Visible','on','Callback',@plotFiguresCallback);
hCheckBoxBalance = uicontrol('Parent',hMainFigure,'Units','normalized','Position',[0.78 0.61 0.2 0.03],'String','<html>Controller imbalance</html>','Style','checkbox','Value',0,'BackgroundColor',get(hMainFigure,'Color'),'HandleVisibility','on','Visible','on','Callback',@plotFiguresCallback);
hCheckBoxDistCC = uicontrol('Parent',hMainFigure,'Units','normalized','Position',[0.78 0.57 0.2 0.03],'String','<html>Max controller to controller latency</html>','Style','checkbox','Value',0,'BackgroundColor',get(hMainFigure,'Color'),'HandleVisibility','on','Visible','on','Callback',@plotFiguresCallback);
hCheckBoxHeatmap = uicontrol('Parent',hMainFigure,'Units','normalized','Position',[0.78 0.53 0.2 0.03],'String','<html>Controller-less nodes heatmap</html>','Style','checkbox','Value',0,'BackgroundColor',get(hMainFigure,'Color'),'HandleVisibility','on','Visible','on','Callback',@heatmapCheckCallback);
hCheckBoxTM = uicontrol('Parent',hMainFigure,'Units','normalized','Position',[0.78 0.49 0.2 0.03],'String','Node weights','Style','checkbox','Value',0,'BackgroundColor',get(hMainFigure,'Color'),'HandleVisibility','on','Visible','on','Callback',@plotFiguresCallback);

% Best placement and scenario menus

hResultLabel = uicontrol('Parent',hMainFigure,'Units','normalized','HorizontalAlignment','left','Position',[0.78 0.4 0.17 0.02],'String','Best placement concerning','Style','text','BackgroundColor',get(hMainFigure,'Color'),'Visible','off','FontWeight','bold');
hResultPopupMenu = uicontrol('Parent', hMainFigure,'Units','normalized','Position',[0.78 0.36 0.17 0.04],'HandleVisibility','on','String',pValues,'Style','popupmenu','FontUnits','normalized','FontSize',0.63,'Callback',@hResultPopupMenuCallback,'Visible','off','BackgroundColor',get(hMainFigure,'Color'));

hScenarioLabel = uicontrol('Parent',hMainFigure,'Units','normalized','HorizontalAlignment','left','Position',[0.78 0.32 0.14 0.02],'String','Scenario ','Style','text','BackgroundColor',get(hMainFigure,'Color'),'Visible','off','FontWeight','bold');
hScenarioPopupMenu = uicontrol('Parent', hMainFigure,'Units','normalized','Position',[0.78 0.28 0.17 0.04],'HandleVisibility','on','String',rbValues,'Style','popupmenu','FontUnits','normalized','FontSize',0.63,'Callback',@hScenarioPopupMenuCallback,'Visible','off','BackgroundColor',get(hMainFigure,'Color'));

% Pareto-plot controller
hXAxisLabel = uicontrol('Parent',hMainFigure,'Units','normalized','HorizontalAlignment','left','Position',[0.07 0.08 0.14 0.02],...
    'String','Value on x-axis','Style','text','BackgroundColor',get(hMainFigure,'Color'),'Visible','off','FontWeight','bold');
hXAxisPopupMenu = uicontrol('Parent', hMainFigure,'Units','normalized','Position',[0.07 0.06 0.3 0.02],'HandleVisibility','on','String','','Style','popupmenu','Callback',@hAxisPopupMenuCallback,'Visible','off','BackgroundColor',get(hMainFigure,'Color'));
hXAxisPopupMenuHierarchical = uicontrol('Parent', hMainFigure,'Units','normalized','Position',[0.07 0.06 0.3 0.02],'HandleVisibility','on','String','','Style','popupmenu','Callback',@hAxisPopupMenuHierarchicalCallback,'Visible','off','BackgroundColor',get(hMainFigure,'Color'));
hYAxisLabel = uicontrol('Parent',hMainFigure,'Units','normalized','HorizontalAlignment','left','Position',[0.45 0.08 0.14 0.02],...
    'String','Value on y-axis','Style','text','BackgroundColor',get(hMainFigure,'Color'),'Visible','off','FontWeight','bold');
hYAxisPopupMenu = uicontrol('Parent', hMainFigure,'Units','normalized','Position',[0.45 0.06 0.3 0.02],'HandleVisibility','on','String','','Style','popupmenu','Callback',@hAxisPopupMenuCallback,'Visible','off','BackgroundColor',get(hMainFigure,'Color'));
hYAxisPopupMenuHierarchical = uicontrol('Parent', hMainFigure,'Units','normalized','Position',[0.45 0.06 0.3 0.02],'HandleVisibility','on','String','','Style','popupmenu','Callback',@hAxisPopupMenuHierarchicalCallback,'Visible','off','BackgroundColor',get(hMainFigure,'Color'));

% Status bar

hStatusPanel = uipanel('Parent', hMainFigure,'Units','pixels','Position',[-10 -10 3000 30],'HandleVisibility','on','BorderType','beveledout','Visible','off');
hStatusLabel = uicontrol('Parent',hStatusPanel,'Units','pixels','FontWeight','bold','HorizontalAlignment','left','Position',[12 10 1000 17],...
    'String','GUI started - Load topology to continue','Style','text','BackgroundColor',get(hStatusPanel,'BackgroundColor'));

% Data cursor mode
dcobj=datacursormode(hMainFigure);
set(dcobj,'Enable','on','SnapToDataVertex','on','UpdateFcn', @datacursorUpdateFcn);
dcobjPLC=datacursormode(hFigurePLC);
set(dcobjPLC,'Enable','on','SnapToDataVertex','on','UpdateFcn', @datacursorUpdateFcn);
plotTimer=timer('TimerFcn',@plotFiguresCallback, 'StartDelay', 0.5);
plotTimer2=timer('TimerFcn',@updatePlotAxes1Callback, 'StartDelay', 0.5);
plotParetoTimer = timer('TimerFcn',@plotParetoHierarchicalCallback,'StartDelay',0.5);
plcPlotTimer=timer('TimerFcn',@PLCPlotLoop, 'StartDelay', 0, 'Period', 3,'ExecutionMode','fixedRate');
plcCalcTimer=timer('TimerFcn',@PLCCalcLoop, 'StartDelay', 3, 'Period', 10,'ExecutionMode','fixedSpacing');
plcCalcNowTimer=timer('TimerFcn',@PLCCalcLoop, 'StartDelay', 0.5);

%----------------------------------------------------------------------

% Controls for hierarchical topologies

panelLeft = 0.78;
buttonLeft = 0.78;
buttonWidth = 0.2;
hPlanningButton = uicontrol('Parent',hMainFigure,'Style','pushbutton','Units','normalized','Position',[buttonLeft 0.9 buttonWidth 0.06],'FontUnits','normalized','FontSize',0.38,'String','Start Planning','Callback',@startPlanningCallback,'Visible','off','Enable','off');
hLayerLabel = uicontrol('Parent',hMainFigure,'Units','normalized','HorizontalAlignment','left','Position',[panelLeft 0.65 0.17 0.02],'String','Plot options','Style','text','BackgroundColor',get(hMainFigure,'Color'),'Visible','off','FontWeight','bold');
hCheckIcons = uicontrol('Parent',hMainFigure,'Style','checkbox','Units','normalized','Position',[panelLeft 0.61 0.2 0.03],'String','Use icons','Value',0,'backgroundColor',get(hMainFigure,'Color'),'Callback',@hierarchicalCheckboxCallback,'Visible','off');
hCheckLinks = uicontrol('Parent',hMainFigure,'Style','checkbox','Units','normalized','Position',[panelLeft 0.57 0.2 0.03],'String','Links','Value',0,'backgroundColor',get(hMainFigure,'Color'),'Callback',@hierarchicalCheckboxCallback,'Visible','off');
hCheckBaseStations = uicontrol('Parent',hMainFigure,'Style','checkbox','Units','normalized','Position',[panelLeft 0.53 0.2 0.03],'String','Base Stations','Value',0,'backgroundColor',get(hMainFigure,'Color'),'Callback',@hierarchicalCheckboxCallback,'Visible','off');
hCheckAccessNodes = uicontrol('Parent',hMainFigure,'Style','checkbox','Units','normalized','Position',[panelLeft 0.49 0.2 0.03],'String','Access Nodes','Value',0,'backgroundColor',get(hMainFigure,'Color'),'Callback',@hierarchicalCheckboxCallback,'Visible','off');
hCheckSGWlocations = uicontrol('Parent',hMainFigure,'Style','checkbox','Units','normalized','Position',[panelLeft 0.45 0.2 0.03],'String','SGW locations','Value',0,'backgroundColor',get(hMainFigure,'Color'),'Callback',@hierarchicalCheckboxCallback,'Visible','off');
hCheckSGWs = uicontrol('Parent',hMainFigure,'Style','checkbox','Units','normalized','Position',[panelLeft 0.41 0.2 0.03],'String','SGWs','Value',0,'backgroundColor',get(hMainFigure,'Color'),'Callback',@hierarchicalCheckboxCallback,'Visible','off');
hCheckVirtualSGWs = uicontrol('Parent',hMainFigure,'Style','checkbox','Units','normalized','Position',[panelLeft 0.37 0.2 0.03],'String','Virtual SGWs','Value',0,'backgroundColor',get(hMainFigure,'Color'),'Callback',@hierarchicalCheckboxCallback,'Visible','off','Enable','off');
hCheckMegaEvents = uicontrol('Parent',hMainFigure,'Style','checkbox','Units','normalized','Position',[panelLeft 0.33 0.2 0.03],'String','MegaEvents','Value',0,'backgroundColor',get(hMainFigure,'Color'),'Callback',@hierarchicalCheckboxCallback,'Visible','off','Enable','off');
hCheckMegaEventResources = uicontrol('Parent',hMainFigure,'Style','checkbox','Units','normalized','Position',[panelLeft 0.29 0.2 0.03],'String','MegaEvent Resources','Value',0,'backgroundColor',get(hMainFigure,'Color'),'Callback',@hierarchicalCheckboxCallback,'Visible','off','Enable','off');
hCheckNeplus = uicontrol('Parent',hMainFigure,'Style','checkbox','Units','normalized','Position',[panelLeft 0.25 0.2 0.03],'String','NE+','Value',0,'backgroundColor',get(hMainFigure,'Color'),'Callback',@hierarchicalCheckboxCallback,'Visible','off');
hMetricsLabel = uicontrol('Parent',hMainFigure,'Units','normalized','HorizontalAlignment','left','Position',[panelLeft 0.85 0.17 0.02],'String','Metrics','Style','text','BackgroundColor',get(hMainFigure,'Color'),'Visible','off','FontWeight','bold');
hCheckLatency = uicontrol('Parent',hMainFigure,'Style','checkbox','Units','normalized','Position',[panelLeft 0.81 0.2 0.03],'String','Latency','Value',0,'backgroundColor',get(hMainFigure,'Color'),'Visible','off','Callback',@hierarchicalCheckboxCallback,'Enable','on');
hCheckAssignment = uicontrol('Parent',hMainFigure,'Style','checkbox','Units','normalized','Position',[panelLeft 0.73 0.2 0.03],'String','BS-SGW assignment','Value',0,'backgroundColor',get(hMainFigure,'Color'),'Visible','off','Callback',@hierarchicalCheckboxCallback);
hLabelLatency = uicontrol('Parent',hMainFigure,'Style','text','Units','normalized','Position',[panelLeft 0.77 0.12 0.03],'String','Red threshold (km)','Value',0,'backgroundColor',get(hMainFigure,'Color'),'Visible','off','Enable','on');
hEditLatency = uicontrol('Parent',hMainFigure,'Style','edit','Units','normalized','Position',[0.89 0.78 0.06 0.03],'String','','Value',0,'backgroundColor',get(hMainFigure,'Color'),'Visible','off','Callback',@updatePlotAxes1Callback,'Enable','on');
hBusyLabel = uicontrol('Parent',hMainFigure,'Style','text','Units','pixels','FontSize',12,'Position',[10 5 120 30],'String','','BackgroundColor',get(hMainFigure,'Color'),'Visible','on');


mValues2={'<html><font size="2">Number of virtual SGWs</font></html>', 'numberOfControllers','Number of virtual SGWs';...
    '<html><font size="2">Maximum latency between base stations and SGW</font></html>', 'maxLatencyN2C',['Maximum latency between',10,'base stations and SGW'];...
    '<html><font size="2">Average latency between base stations and SGW</font></html>', 'avgLatencyN2C',['Average latency between',10,'base stations and SGW']};
planningValues={'<html><font size="2">Maximum latency between base stations and SGW</font></html>', 'maxLatencyN2C',['Maximum latency between',10,'base stations and SGW'];...
    '<html><font size="2">Average latency between base stations and SGW</font></html>', 'avgLatencyN2C',['Average latency between',10,'base stations and SGW']};

% Global variables for hierarchical topologies
baseX=[];
baseY=[];
citynodes=[];
corenodes=[];
locX=[];
locY=[];
neplusnodes=[];
neplusnodesNOSGW=[];
newBSX=[];
newBSY=[];
nk=[];
numMegaEvents=0;
sgwnodesstatic=[];
solutionAll=struct;
planned=0;
highLatency=300;
sgwImg = '';
neplusImg = '';
sgwLight='';
sgwVirtual='';
neplusLight = '';


%----------------------------------------------------------------------
% Stops the functionality for hierarchical topologies

    function stopHierarchicalCallback(hObject, eventdata)
        stopHierarchical;
    end

    function stopHierarchical
        topology=[];
        coordinates=[];
        distanceMatrix=[];
        corenodes=[];
        citynodes=[];
        neplusnodes=[];
        neplusnodesNOSGW=[];
        baseX=[];
        baseY=[];
        locX=[];
        locY=[];
        isHierarchic=0;
        fullView;
        set(hPlotAxes1,'Position',[0 0 0.98 1]);
        fullViewSize = [0.05 0.5 0.72 0.47];
        compactViewSize=[0.05 0.04 0.72 0.95];
        set(hPanelAxes1,'Position',fullViewSize);
        set(hPlanningButton,'Visible','off');
        set(hLayerLabel,'Visible','off');
        set(hCheckIcons,'Value',0);
        set(hCheckIcons,'Visible','off');
        set(hCheckLinks,'Value',0);
        set(hCheckLinks,'Visible','off');
        set(hCheckBaseStations,'Value',0);
        set(hCheckBaseStations,'Visible','off');
        set(hCheckAccessNodes,'Value',0);
        set(hCheckAccessNodes,'Visible','off');
        set(hCheckSGWlocations,'Value',0);
        set(hCheckSGWlocations,'Visible','off');
        set(hCheckSGWs,'Value',0);
        set(hCheckSGWs,'Visible','off');
        set(hCheckVirtualSGWs,'Value',0);
        set(hCheckVirtualSGWs,'Visible','off');
        set(hCheckMegaEvents,'Value',0);
        set(hCheckMegaEvents,'Visible','off');
        set(hCheckMegaEventResources,'Value',0);
        set(hCheckMegaEventResources,'Visible','off');
        set(hCheckNeplus,'Value',0);
        set(hCheckNeplus,'Visible','off');
        set(hMetricsLabel,'Visible','off');
        set(hCheckLatency,'Value',0);
        set(hCheckLatency,'Visible','off');
        set(hCheckAssignment,'Value',0);
        set(hCheckAssignment,'Visible','off');
        set(hLabelLatency,'Visible','off');
        set(hEditLatency,'Visible','off');
        set(hInitHierarchicalMenuitem,'Visible','on');
        set(hstopHierarchicalMenuitem,'Visible','off');
        set(hMegaEventsMenu,'Visible','off');
        set(hresetHierarchicalMenuitem,'Visible','off');
        set(hPlanningMenuitem,'Visible','off');
        set(hSaveMegaEventsMenuitem,'Visible','off');
        set(hHierarchicalPlotMetricsMenu,'Visible','off');
        set(hLabelControllerIDs,'Visible','on');
        set(hLabelControllerFailureIDs,'Visible','on');
        set(hLabelNodeFailureIDs,'Visible','on');
        set(hEditControllerIDs,'Visible','on');
        set(hEditControllerFailureIDs,'Visible','on');
        set(hEditNodeFailureIDs,'Visible','on');
        set(hLabelPlotOptions,'Visible','on');
        set(hCheckBoxIDs,'Visible','on');
        set(hCheckBoxDistNC,'Visible','on');
        set(hCheckBoxBalance,'Visible','on');
        set(hCheckBoxDistCC,'Visible','on');
        set(hCheckBoxHeatmap,'Visible','on');
        set(hCheckBoxTM,'Visible','on');
        set(hPlotOptionsMenu,'Enable','off');
        set(hYAxisPopupMenuHierarchical,'Visible','off');
        set(hXAxisPopupMenuHierarchical,'Visible','off');
        set(hHierarchicalShowIconsMenuitem,'Visible','off');
        set(hHierarchicalShowLinksMenuitem,'Visible','off');
        set(hHierarchicalShowBaseStationsMenuitem,'Visible','off');
        set(hHierarchicalShowAccessNodesMenuitem,'Visible','off');
        set(hHierarchicalShowSGWlocationsMenuitem,'Visible','off');
        set(hHierarchicalShowSGWsMenuitem,'Visible','off');
        set(hHierarchicalShowVirtualSGWsMenuitem,'Visible','off');
        set(hHierarchicalShowMegaEventsMenuitem,'Visible','off');
        set(hHierarchicalShowMegaEventResourcesMenuitem,'Visible','off');
        set(hHierarchicalShowNeplusMenuitem,'Visible','off');
        set(hCheckBoxMenuIDs,'Visible','on');
        set(hCheckBoxMenuTM,'Visible','on');
        set(hCheckBoxMenuDistNC,'Visible','on');
        set(hCheckBoxMenuBalance,'Visible','on');
        set(hCheckBoxMenuDistCC,'Visible','on');
        set(hCheckBoxMenuHeatmap,'Visible','on');
        set(hExportMenu,'Enable','off');
        set(hExportGephiMenuitem,'Enable','on');
        set(hPredefinedViewsMenu,'Enable','off');
        set(hViewMaxLatencyMenuitem,'Visible','on');
        set(hViewImbalanceMenuitem,'Visible','on');
        set(hViewMaxLatencyCCMenuitem,'Visible','on');
        set(hViewControllerlessMenuitem,'Visible','on');
        isBusy(0);
        reset;
    end

%----------------------------------------------------------------------
% Deletes all placed Mega Events and restores the initial setup of the plot
    function resetHierarchicalCallback(hObject, eventdata)
        resetHierarchical;
    end

    function resetHierarchical
        locX=[];
        locY=[];
        newBSX=[];
        newBSY=[];
        nk=[];
        numMegaEvents=0;
        solution=struct;
        solutionAll=struct;
        planned=0;
        highLatency=300;
        set(hViewMenu,'Enable','on');
        set(hCheckLatency,'Value',0);
        axes(hPlotAxes2);
        cla;
        box off;
        set(gca,'Visible','off');
        compactView;
        set(hCheckBaseStations,'Value',1);
        set(hHierarchicalShowBaseStationsMenuitem,'Checked','on');
        set(hCheckAccessNodes,'Value',1);
        set(hHierarchicalShowAccessNodesMenuitem,'Checked','on');
        set(hCheckAssignment,'Value',0);
        set(hHierarchicalShowAssociationsMenuitem,'Checked','off');
        set(hCheckLatency,'Value',0);
        set(hHierarchicalShowLatencyMenuitem,'Checked','off');
        set(hCheckSGWlocations,'Value',0);
        set(hHierarchicalShowSGWlocationsMenuitem,'Checked','off');
        set(hCheckNeplus,'Value',0);
        set(hHierarchicalShowNeplusMenuitem,'Checked','off');
        set(hCheckIcons,'Value',0);
        set(hHierarchicalShowIconsMenuitem,'Checked','off');
        set(hCheckSGWs,'Value',0);
        set(hHierarchicalShowSGWsMenuitem,'Checked','off');
        set(hPanelAxes1,'Visible','on');
        set(hCheckLinks,'Value',1);
        set(hHierarchicalShowLinksMenuitem,'Checked','on');
        set(hSaveMegaEventsMenuitem,'Enable','off');
        set(hPlanningButton,'Enable','off');
        set(hPlanningMenuitem,'Enable','off');
        set(hHierarchicalViewLatDyn,'Visible','off');
        set(hHierarchicalViewBalDyn,'Visible','off');
        set(hHierarchicalView3,'Visible','off');
        set(hHierarchicalView4,'Visible','off');
        if ~isempty(topology)
            resetMegaEvents;
        end
    end

%----------------------------------------------------------------------
% Starts the functionality for hierarchical topologies
    function initHierarchical(hObject, eventdata)
        reset;
        isHierarchic=1;
        set(hPlotAxes1,'Position',[0 0.02 1 0.98]);
        set(hLabelControllerIDs,'Visible','off');
        set(hLabelControllerFailureIDs,'Visible','off');
        set(hLabelNodeFailureIDs,'Visible','off');
        set(hEditControllerIDs,'Visible','off');
        set(hEditControllerFailureIDs,'Visible','off');
        set(hEditNodeFailureIDs,'Visible','off');
        set(hLabelPlotOptions,'Visible','off');
        set(hCheckBoxIDs,'Visible','off');
        set(hCheckBoxDistNC,'Visible','off');
        set(hCheckBoxBalance,'Visible','off');
        set(hCheckBoxDistCC,'Visible','off');
        set(hCheckBoxHeatmap,'Visible','off');
        set(hCheckBoxTM,'Visible','off');
        fullViewSize = [0.2 0.5 0.42 0.5];
        compactViewSize=[0.1 0.04 0.6 0.98];
        set(hPanelAxes1,'Position',fullViewSize);
        set(hPlanningButton,'Visible','on');
        set(hLayerLabel,'Visible','on');
        set(hCheckIcons,'Visible','on');
        set(hCheckLinks,'Visible','on');
        set(hCheckBaseStations,'Visible','on');
        set(hCheckAccessNodes,'Visible','on');
        set(hCheckSGWlocations,'Visible','on');
        set(hCheckSGWs,'Visible','on');
        set(hCheckVirtualSGWs,'Visible','on');
        set(hCheckMegaEvents,'Visible','on');
        set(hCheckMegaEventResources,'Visible','on');
        set(hCheckNeplus,'Visible','on');
        set(hMetricsLabel,'Visible','on');
        set(hCheckLatency,'Visible','on');
        set(hCheckAssignment,'Visible','on');
        set(hLabelLatency,'Visible','on');
        set(hEditLatency,'Visible','on');
        set(hInitHierarchicalMenuitem,'Visible','off');
        set(hstopHierarchicalMenuitem,'Visible','on');
        set(hMegaEventsMenu,'Visible','on');
        set(hresetHierarchicalMenuitem,'Visible','on');
        set(hPlanningMenuitem,'Visible','on');
        set(hSaveMegaEventsMenuitem,'Visible','on');
        set(hHierarchicalPlotMetricsMenu,'Visible','on');
        resetHierarchical;
        set(hHierarchicalShowIconsMenuitem,'Visible','on');
        set(hHierarchicalShowLinksMenuitem,'Visible','on');
        set(hHierarchicalShowBaseStationsMenuitem,'Visible','on');
        set(hHierarchicalShowAccessNodesMenuitem,'Visible','on');
        set(hHierarchicalShowSGWlocationsMenuitem,'Visible','on');
        set(hHierarchicalShowSGWsMenuitem,'Visible','on');
        set(hHierarchicalShowVirtualSGWsMenuitem,'Visible','on');
        set(hHierarchicalShowMegaEventsMenuitem,'Visible','on');
        set(hHierarchicalShowMegaEventResourcesMenuitem,'Visible','on');
        set(hHierarchicalShowNeplusMenuitem,'Visible','on');
        set(hCheckBoxMenuIDs,'Visible','off');
        set(hCheckBoxMenuTM,'Visible','off');
        set(hCheckBoxMenuDistNC,'Visible','off');
        set(hCheckBoxMenuBalance,'Visible','off');
        set(hCheckBoxMenuDistCC,'Visible','off');
        set(hCheckBoxMenuHeatmap,'Visible','off');
        set(hPlotOptionsMenu,'Enable','on');
        set(hExportMenu,'Enable','on');
        set(hExportGephiMenuitem,'Enable','off');
        isBusy(1);
        sgwImg = imread('sgw.png');
        neplusImg = imread('neplus.png');
        sgwLight=imread('sgw_light.png');
        sgwVirtual=imread('virtual_sgw.png');
        neplusLight = imread('neplus_light.png');
        compactView;
        set(gcf,'Pointer','watch');
        set(hPredefinedViewsMenu,'Enable','on');
        set(hViewMaxLatencyMenuitem,'Visible','off');
        set(hViewImbalanceMenuitem,'Visible','off');
        set(hViewMaxLatencyCCMenuitem,'Visible','off');
        set(hViewControllerlessMenuitem,'Visible','off');
        set(hHierarchicalView1,'Visible','on');
        set(hHierarchicalView2,'Visible','on');
        set(hHierarchicalViewLatStat,'Visible','on');
        set(hHierarchicalViewBalStat,'Visible','on');

        if isempty(topology)
            [coordinates, topology, citynodes, sgwnodesstatic, neplusnodes, neplusnodesNOSGW, baseX, baseY, corenodes, distanceMatrix] = loadHierarchical('topologies/hierarchicalTopology.mat');
        end
        plotLinks;
        plotBaseStations(0);
        plotAccessNodes(0,0);
        set(hThemesMenu,'Enable','on');
        set(gcf,'Pointer','arrow');
        isBusy(0);
    end

%----------------------------------------------------------------------
% Updates the plot an the plot option menu for hierarchical
% topologies when an option checkbox is selected
    function hierarchicalCheckboxCallback(hObject, eventdata)
        updatePlotAxes1;
        updateHierarchicalPlotOptions;
    end

%----------------------------------------------------------------------
% Updates the plot option menu for hierarchical topologies according
% to the plot option checkboxes
    function updateHierarchicalPlotOptions
        checkValue={'off','on'};
        set(hHierarchicalShowLatencyMenuitem,'Checked',checkValue{get(hCheckLatency,'Value')+1});
        set(hHierarchicalShowAssociationsMenuitem,'Checked',checkValue{get(hCheckAssignment,'Value')+1});
        set(hHierarchicalShowIconsMenuitem,'Checked',checkValue{get(hCheckIcons,'Value')+1});
        set(hHierarchicalShowLinksMenuitem,'Checked',checkValue{get(hCheckLinks,'Value')+1});
        set(hHierarchicalShowBaseStationsMenuitem,'Checked',checkValue{get(hCheckBaseStations,'Value')+1});
        set(hHierarchicalShowAccessNodesMenuitem,'Checked',checkValue{get(hCheckAccessNodes,'Value')+1});
        set(hHierarchicalShowSGWlocationsMenuitem,'Checked',checkValue{get(hCheckSGWlocations,'Value')+1});
        set(hHierarchicalShowSGWsMenuitem,'Checked',checkValue{get(hCheckSGWs,'Value')+1});
        set(hHierarchicalShowVirtualSGWsMenuitem,'Checked',checkValue{get(hCheckVirtualSGWs,'Value')+1});
        set(hHierarchicalShowMegaEventsMenuitem,'Checked',checkValue{get(hCheckMegaEvents,'Value')+1});
        set(hHierarchicalShowMegaEventResourcesMenuitem,'Checked',checkValue{get(hCheckMegaEventResources,'Value')+1});
        set(hHierarchicalShowNeplusMenuitem,'Checked',checkValue{get(hCheckNeplus,'Value')+1});
    end

%----------------------------------------------------------------------
% Updates the plot an the plot option checkboxes for hierarchical
% topologies when an option in the menu is selected
    function hierarchicalPlotOptionCallback(hObject, eventdata, k)
        updateHierarchicalCheckBoxes(k);
        updateHierarchicalPlotOptions;
    end

%----------------------------------------------------------------------
% Updates the plot option checkboxes for hierarchical topologies according
% to the plot option menu
    function updateHierarchicalCheckBoxes(k)
        switch k
            case 1
                set(hCheckLatency,'Value',~get(hCheckLatency,'Value'));
            case 2
                set(hCheckAssignment,'Value',~get(hCheckAssignment,'Value'));
            case 3
                set(hCheckIcons,'Value',~get(hCheckIcons,'Value'));
            case 4
                set(hCheckLinks,'Value',~get(hCheckLinks,'Value'));
            case 5
                set(hCheckBaseStations,'Value',~get(hCheckBaseStations,'Value'));
            case 6
                set(hCheckAccessNodes,'Value',~get(hCheckAccessNodes,'Value'));
            case 7
                set(hCheckSGWlocations,'Value',~get(hCheckSGWlocations,'Value'));
            case 8
                set(hCheckSGWs,'Value',~get(hCheckSGWs,'Value'));
            case 9
                set(hCheckVirtualSGWs,'Value',~get(hCheckVirtualSGWs,'Value'));
            case 10
                set(hCheckMegaEvents,'Value',~get(hCheckMegaEvents,'Value'));
            case 11
                set(hCheckMegaEventResources,'Value',~get(hCheckMegaEventResources,'Value'));
            case 12
                set(hCheckNeplus,'Value',~get(hCheckNeplus,'Value'));
            case 13
                set(hCheckLatency,'Value',0);
                set(hCheckAssignment,'Value',1);
                set(hCheckLinks,'Value',1);
                set(hCheckBaseStations,'Value',1);
                set(hCheckAccessNodes,'Value',1);
                set(hCheckSGWlocations,'Value',0);
                set(hCheckSGWs,'Value',1);
                set(hCheckVirtualSGWs,'Value',0);
                set(hCheckMegaEvents,'Value',0);
                set(hCheckMegaEventResources,'Value',0);
                set(hCheckNeplus,'Value',0);
                set(hCheckIcons,'Value',1);
            case 14
                set(hCheckLatency,'Value',0);
                set(hCheckAssignment,'Value',1);
                set(hCheckLinks,'Value',1);
                set(hCheckBaseStations,'Value',0);
                set(hCheckAccessNodes,'Value',1);
                set(hCheckSGWlocations,'Value',0);
                set(hCheckSGWs,'Value',1);
                set(hCheckVirtualSGWs,'Value',0);
                set(hCheckMegaEvents,'Value',0);
                set(hCheckMegaEventResources,'Value',0);
                set(hCheckNeplus,'Value',0);
                set(hCheckIcons,'Value',1);
            case 15
                set(hCheckLatency,'Value',0);
                set(hCheckAssignment,'Value',0);
                set(hCheckLinks,'Value',1);
                set(hCheckBaseStations,'Value',0);
                set(hCheckAccessNodes,'Value',0);
                set(hCheckSGWlocations,'Value',0);
                set(hCheckSGWs,'Value',1);
                set(hCheckVirtualSGWs,'Value',0);
                set(hCheckMegaEvents,'Value',1);
                set(hCheckMegaEventResources,'Value',0);
                set(hCheckNeplus,'Value',0);
                set(hCheckIcons,'Value',1);
            case 16
                set(hCheckLatency,'Value',0);
                set(hCheckAssignment,'Value',0);
                set(hCheckLinks,'Value',1);
                set(hCheckBaseStations,'Value',0);
                set(hCheckAccessNodes,'Value',0);
                set(hCheckSGWlocations,'Value',0);
                set(hCheckSGWs,'Value',1);
                set(hCheckVirtualSGWs,'Value',0);
                set(hCheckMegaEvents,'Value',1);
                set(hCheckMegaEventResources,'Value',1);
                set(hCheckNeplus,'Value',0);
                set(hCheckIcons,'Value',1);
            case 17
                set(hCheckLatency,'Value',1);
                set(hCheckAssignment,'Value',0);
                set(hCheckLinks,'Value',1);
                set(hCheckBaseStations,'Value',1);
                set(hCheckAccessNodes,'Value',1);
                set(hCheckSGWlocations,'Value',0);
                set(hCheckSGWs,'Value',1);
                set(hCheckVirtualSGWs,'Value',0);
                set(hCheckMegaEvents,'Value',0);
                set(hCheckMegaEventResources,'Value',0);
                set(hCheckNeplus,'Value',0);
            case 18
                set(hCheckLatency,'Value',0);
                set(hCheckAssignment,'Value',1);
                set(hCheckLinks,'Value',1);
                set(hCheckBaseStations,'Value',1);
                set(hCheckAccessNodes,'Value',1);
                set(hCheckSGWlocations,'Value',0);
                set(hCheckSGWs,'Value',1);
                set(hCheckVirtualSGWs,'Value',0);
                set(hCheckMegaEvents,'Value',0);
                set(hCheckMegaEventResources,'Value',0);
                set(hCheckNeplus,'Value',0);
            case 19
                set(hCheckLatency,'Value',1);
                set(hCheckAssignment,'Value',0);
                set(hCheckLinks,'Value',1);
                set(hCheckBaseStations,'Value',0);
                set(hCheckAccessNodes,'Value',0);
                set(hCheckSGWlocations,'Value',0);
                set(hCheckSGWs,'Value',0);
                set(hCheckVirtualSGWs,'Value',1);
                set(hCheckMegaEvents,'Value',1);
                set(hCheckMegaEventResources,'Value',1);
                set(hCheckNeplus,'Value',0);
            case 20
                set(hCheckLatency,'Value',0);
                set(hCheckAssignment,'Value',1);
                set(hCheckLinks,'Value',1);
                set(hCheckBaseStations,'Value',0);
                set(hCheckAccessNodes,'Value',0);
                set(hCheckSGWlocations,'Value',0);
                set(hCheckSGWs,'Value',1);
                set(hCheckVirtualSGWs,'Value',1);
                set(hCheckMegaEvents,'Value',1);
                set(hCheckMegaEventResources,'Value',1);
                set(hCheckNeplus,'Value',0);
        end
        updatePlotAxes1;
    end

%----------------------------------------------------------------------
% Disables or enables the plot option controls during the plot is being
% updated
    function disableOptions(bool)
        value={'on','off'};
        set(hCheckLatency,'Enable',value{bool+1});
        set(hEditLatency,'Enable',value{bool+1});
        set(hCheckAssignment,'Enable',value{bool+1});
        set(hCheckIcons,'Enable',value{bool+1});
        set(hCheckLinks,'Enable',value{bool+1});
        set(hCheckBaseStations,'Enable',value{bool+1});
        set(hCheckAccessNodes,'Enable',value{bool+1});
        set(hCheckSGWlocations,'Enable',value{bool+1});
        set(hCheckSGWs,'Enable',value{bool+1});
        if ~isempty(locX)
            if planned
                set(hCheckVirtualSGWs,'Enable',value{bool+1});
            end
            set(hCheckMegaEvents,'Enable',value{bool+1});
            set(hCheckMegaEventResources,'Enable',value{bool+1});
        end
        set(hCheckNeplus,'Enable',value{bool+1});
    end

%----------------------------------------------------------------------
% Updates the topology plot according to the set plot options

    function updatePlotAxes1Callback(hObject, eventdata)
        updatePlotAxes1;
    end

    function updatePlotAxes1
        disableOptions(1);
        isBusy(1);
        axes(hPlotAxes1);
        cla;
        box off;
        hold on;
        latency=get(hCheckLatency,'Value');
        assignment=get(hCheckAssignment,'Value');
        showIcons=get(hCheckIcons,'Value');
        showLinks=get(hCheckLinks,'Value');
        showBaseStations=get(hCheckBaseStations,'Value');
        showAccessNodes=get(hCheckAccessNodes,'Value');
        showSGWlocations=get(hCheckSGWlocations,'Value');
        showSGWs=get(hCheckSGWs,'Value');
        showVirtualSGWs=get(hCheckVirtualSGWs,'Value');
        showMegaEvents=get(hCheckMegaEvents,'Value');
        showMegaEventResources=get(hCheckMegaEventResources,'Value');
        showNEplus=get(hCheckNeplus,'Value');
        set(gcf,'Pointer','watch');
        if showLinks
            plotLinks;
        end
        if showBaseStations
            plotBaseStations(assignment);
        end
        if showAccessNodes
            plotAccessNodes(assignment,latency);
        end
        if showSGWlocations
            plotSGWlocations;
        end
        if showNEplus
            plotNeplus(showIcons);
        end
        if showVirtualSGWs
            plotVirtualSGWs(nk,showIcons);
        end
        if showMegaEventResources
            plotMegaEventResources(assignment,latency);
        end
        if showSGWs
            plotSGWs(assignment,showIcons);
        end
        if showMegaEvents
            plotMegaEvents;
        end
        set(gcf,'Pointer','arrow');
        isBusy(0);
        disableOptions(0);
    end

%----------------------------------------------------------------------
% Sets a label to show the user the programm is busy
    function isBusy(value)
        if value
            set(hBusyLabel,'String','Working...');
        else
            set(hBusyLabel,'String','');
        end
    end

%----------------------------------------------------------------------
% Deletes all currently placed Mega Events
    function resetMegaEvents
        isBusy(1);
        axes(hPlotAxes1);
        cla;
        box off;
        hold on;
        locX=[];
        locY=[];
        planned=0;
        set(hCheckVirtualSGWs,'Enable','off');
        set(hCheckVirtualSGWs,'Value',0);
        set(hCheckMegaEvents,'Enable','off');
        set(hCheckMegaEvents,'Value',0);
        set(hCheckMegaEventResources,'Value',0);
        set(hCheckMegaEventResources,'Enable','off');
        set(hHierarchicalShowMegaEventResourcesMenuitem,'Enable','off');
        set(hHierarchicalShowMegaEventResourcesMenuitem,'Checked','off');
        set(hHierarchicalShowMegaEventsMenuitem,'Enable','off');
        set(hHierarchicalShowMegaEventsMenuitem,'Checked','off');
        set(hHierarchicalShowVirtualSGWsMenuitem,'Checked','off');
        set(hHierarchicalShowVirtualSGWsMenuitem,'Enable','off');
        updatePlotAxes1;
        set(hXAxisLabel,'Visible','off');
        set(hYAxisLabel,'Visible','off');
        set(hYAxisPopupMenuHierarchical,'Visible','off');
        set(hXAxisPopupMenuHierarchical,'Visible','off');
        set(hYAxisPopupMenuHierarchical,'String','');
        set(hXAxisPopupMenuHierarchical,'String','');
        planned=0;
        set(hCheckVirtualSGWs,'Enable','off');
        set(hCheckVirtualSGWs,'Value',0);
        set(hCheckMegaEvents,'Enable','off');
        set(hCheckMegaEvents,'Value',0);
        set(hCheckMegaEventResources,'Value',0);
        set(hCheckMegaEventResources,'Enable','off');
        set(hHierarchicalShowMegaEventResourcesMenuitem,'Enable','off');
        set(hHierarchicalShowMegaEventResourcesMenuitem,'Checked','off');
        set(hHierarchicalShowMegaEventsMenuitem,'Enable','off');
        set(hHierarchicalShowMegaEventsMenuitem,'Checked','off');
        set(hHierarchicalShowVirtualSGWsMenuitem,'Checked','off');
        set(hHierarchicalShowVirtualSGWsMenuitem,'Enable','off');
        isBusy(0);
    end

%----------------------------------------------------------------------
% Places ten Mega Events randomly on the topology
    function placeRandomMegaEvents(hObject, event)
        planned=0;
        set(hPlanningButton,'Enable','on');
        resetMegaEvents;
        set(hPlanningMenuitem,'Enable','on');
        numMegaEvents=5;
        xmin=min(coordinates(:,1))
        xmax=max(coordinates(:,1))
        ymin=min(coordinates(:,2))
        ymax=max(coordinates(:,2))
        locX=rand(1,numMegaEvents*3)*(xmax-xmin)+xmin;
        locY=rand(1,numMegaEvents*3)*(ymax-ymin)+ymin;
        [locX,locY]=advancedFilterPoints(coordinates,locX,locY,1000,30);
        locX=locX(1:min(numMegaEvents,length(locX)));
        locY=locY(1:min(numMegaEvents,length(locY)));
        [newBSX,newBSY]=createBaseStations([locX;locY],4000,10);
        [newBSX,newBSY]=advancedFilterPoints(coordinates,newBSX,newBSY,2000,5);
        set(hCheckMegaEventResources,'Enable','on');
        set(hCheckMegaEventResources,'Value',1);
        plotMegaEvents;
        plotMegaEventResourcesBeforePlanning;
    end

%----------------------------------------------------------------------
% Saves the currently places Mega Events.

    function saveMegaEventsCallback(hObject, eventdata)
        if ~isempty(numMegaEvents)
            file = uiputfile('*.megaevents.mat');
            saveMegaEvents(file);
            set(hMainFigure,'Name',sprintf('POCO - %s',file));
        end
    end

    function saveMegaEvents(file)
        save(file, '-mat','numMegaEvents','newBSX','newBSY','locX','locY')
    end

%----------------------------------------------------------------------
% Loads a file containing a predefined Mega Event placement
    function loadPredefinedMegaEventsCallback(hObject, eventdata)
        [filename, pathname] = uigetfile({'*.megaevents.mat','Mega Event placements (*.megaevents.mat)'},'Please select a valid Mega Event placements file');
        file = fullfile(pathname, filename);
        if ~isequal(filename, 0)
            loadPredefinedMegaEvents(file);
        else
            return;
        end
    end

    function loadPredefinedMegaEvents(file)
        planned=0;
        resetMegaEvents;
        set(hPlanningMenuitem,'Enable','on');
        set(hPlanningButton,'Enable','on');
        [locX,locY,newBSX,newBSY,numMegaEvents] = loadMegaEvents(file);
        set(hCheckMegaEventResources,'Enable','on');
%         set(hCheckMegaEventResources,'Value',1);
        updateHierarchicalCheckBoxes(16);
        plotMegaEvents;
        plotMegaEventResourcesBeforePlanning;
    end

    function [locX,locY,newBSX,newBSY,numMegaEvents] = loadMegaEvents(filename)
        if exist(filename,'file')
            load(filename);
        end
    end

%----------------------------------------------------------------------
% Loads the hierarchical topology
    function [coordinates, topology, citynodes, sgwnodesstatic, neplusnodes, neplusnodesNOSGW, baseX, baseY, corenodes, distanceMatrix] = loadHierarchical(filename)
        if exist(filename,'file')
            load(filename);
        end
    end

%----------------------------------------------------------------------
% Lets the user choose places for Mega Events in the network area
    function placeMegaEventsManual(hObject, eventdata)
        planned=0;
        resetMegaEvents;
        axes(hPlotAxes1);
        hold on;
        uiwait(helpdlg('Please choose the places for the Mega Events on the map. If done, please click anywhere outside the map.','Place Mega Events manual'));
        set(hCheckMegaEventResources,'Enable','on');
        set(hCheckMegaEventResources,'Value',1);
        baseXn={};
        baseYn={};
        insideX=inf;
        i=1;
        while ~isempty(insideX)
            [locXtmp locYtmp] = ginput(1);
            insideX=advancedFilterPoints(coordinates,locXtmp,locYtmp,2000,5);
            if isempty(insideX)
                continue;
            else
                locX(i)=locXtmp;
                locY(i)=locYtmp;
                [baseXn{i},baseYn{i}]=createBaseStations([locX(i);locY(i)],4000,10);
                plotMegaEvents;
                newBSX=[baseXn{:}];
                newBSY=[baseYn{:}];
                [newBSX,newBSY]=advancedFilterPoints(coordinates,newBSX,newBSY,2000,5);
                plotMegaEventResourcesBeforePlanning;
                i=i+1;
            end
        end
        if ~isempty(locX)
            set(hPlanningButton,'Enable','on');
        end
    end


%----------------------------------------------------------------------
% Initiates the calculation of the Mega Event resources
    function startPlanningCallback(hObject, eventdata)
        if ~isempty(str2num(get(hEditLatency,'String')))
            highLatency=str2num(get(hEditLatency,'String'));
        end
        calculateMegaEventResources;
        planned=1;
        set(hXAxisPopupMenuHierarchical,'String',mValues2(1:3,1));
        set(hYAxisPopupMenuHierarchical,'String',mValues2(1:3,1));
        set(hXAxisPopupMenuHierarchical,'Value',1);
        set(hYAxisPopupMenuHierarchical,'Value',2);
        panelAxis1Pos = get(hPanelAxes1,'Position');
        if panelAxis1Pos(4) < 0.8
            set(hXAxisLabel,'Visible','on');
            set(hYAxisLabel,'Visible','on');
            set(hXAxisPopupMenuHierarchical,'Visible','on');
            set(hYAxisPopupMenuHierarchical,'Visible','on');
        end
        valuex=char(mValues2{get(hXAxisPopupMenuHierarchical,'Value'),2});
        valuey=char(mValues2{get(hYAxisPopupMenuHierarchical,'Value'),2});
        updateHierarchicalCheckBoxes(20);
        updatePlotAxes1;
        plotVirtualSGWs(nk,get(hCheckIcons,'Value'));
        start(plotParetoTimer);
    end

%----------------------------------------------------------------------
% Plots the new Virtual SGWs
    function plotVirtualSGWs(idx,icons)
        isBusy(1);
        axes(hPlotAxes1);
        set(hHierarchicalShowVirtualSGWsMenuitem,'Enable','on');
        set(hCheckVirtualSGWs,'Enable','on');
        set(hLabelLatency,'Enable','on');
        set(hCheckLatency,'Enable','on');
        set(hEditLatency,'Enable','on');
        set(hCheckVirtualSGWs,'Value',1);
        set(hHierarchicalViewLatDyn,'Visible','on');
        set(hHierarchicalViewBalDyn,'Visible','on');
        set(hCheckMegaEventResources,'Value',1);
        sgwnodes=neplusnodesNOSGW(idx);
        [imgH, imgW, tildevar] = size(sgwVirtual);
        if icons
            for i=1:length(sgwnodes)
                image([(coordinates(sgwnodes(i),1)-(imgW*10)/2 +500) (coordinates(sgwnodes(i),1)+(imgW*10)/2 - 500)],[coordinates(sgwnodes(i),2)+(imgH*10)/2 coordinates(sgwnodes(i),2)-(imgH*10)/2],sgwVirtual,'Parent',gca);
            end
        end
        mycolors=repmat(hsv(4),ceil(length(sgwnodes)/4),1);
        for i=1:length(sgwnodes)
            plot(coordinates(sgwnodes(i),1),coordinates(sgwnodes(i),2),'o','MarkerFaceColor',mycolors(i,:),'MarkerSize',14,'Color',darken(mycolors(i,:)),'LineWidth',2,'LineSmoothing','off','Parent',gca)
        end
        isBusy(0);
    end

%----------------------------------------------------------------------
% Determines the Access Nodes which are affected by the new Base Stations
% and the new Virtual SGWs which are needed
    function calculateMegaEventResources
        assignmentIdx=calculateBaseStationAssignment(coordinates,citynodes,newBSX,newBSY);
        mycolors=repmat(hsv(10),ceil(length(citynodes)/10),1);
        if matlabVersion < 2013
            dist=distanceMatrix(citynodes(unique(assignmentIdx)),neplusnodesNOSGW);
        else
            dist=distanceMatrix(citynodes(unique(assignmentIdx,'legacy')),neplusnodesNOSGW);
        end
        a=1;
        k=0;
        solutionAll=repmat(struct('numberOfControllers',[],'failureType','','nk',[],'maxNumberOfControllerlessNodes',[],'avgLatencyN2C',[],'maxLatencyN2C',[],'avgLatencyC2C',[],'maxLatencyC2C',[],'controllerImbalance',[]),1,4);
        solutionTmp=inf;
        while a*max(max(dist)) > highLatency && ~isempty(solutionTmp)
            k=k+1;
            solutionTmp=evaluateSingleInstanceHierarchical(dist,k);
            if ~isempty(solutionTmp)
                solution=solutionTmp;
                solutionAll(k)=solution;
                solutionAll(k).numberOfControllers= k*ones(size(solution.maxLatencyN2C));
                [a,b]=min(solution.maxLatencyN2C);
            else
                continue;
            end
        end
        currPlacement = length([solutionAll(1:(k-1)).maxLatencyN2C])+b;
        nk=solution.nk(b,:); 
        plotMegaEventResources(get(hCheckAssignment,'Value'),get(hCheckLatency,'Value'));
    end

%----------------------------------------------------------------------
% Plots the Mega Event Resources before planning
    function plotMegaEventResourcesBeforePlanning
        x=newBSX;
        y=newBSY;
        assignmentIdx=unique(calculateBaseStationAssignment(coordinates,citynodes,x,y));        
        set(hHierarchicalShowMegaEventResourcesMenuitem,'Enable','on');
        set(hHierarchicalShowMegaEventResourcesMenuitem,'Checked','on');
        plot(x,y,'.','Color','y','MarkerFaceColor','y','LineSmoothing','off','Parent',hPlotAxes1);
        plot(coordinates(citynodes(assignmentIdx),1),coordinates(citynodes(assignmentIdx),2),'dk','MarkerFaceColor','y','LineSmoothing','off','Parent',hPlotAxes1)
    end

%----------------------------------------------------------------------
% Plots the Mega Event Resources
    function plotMegaEventResources(assignment, latency)
        if ~isempty(str2num(get(hEditLatency,'String')))
            highLatency=str2num(get(hEditLatency,'String'));
        else
            set(hEditLatency,'String','300');
        end
        if ~planned
            plotMegaEventResourcesBeforePlanning;
        else
            x=newBSX;
            y=newBSY;
            set(hHierarchicalShowMegaEventResourcesMenuitem,'Enable','on');
            set(hHierarchicalShowMegaEventResourcesMenuitem,'Checked','on');
            sgwnodes=neplusnodesNOSGW(nk);
            assignmentIdx=calculateBaseStationAssignment(coordinates,citynodes,x,y);
            [mindiff assignmentIdxNESGW]=calculateBaseStationAssignmentTransport(distanceMatrix,citynodes,sgwnodes);
            mycolors=repmat('y',length(sgwnodes),1);
            mycolorsstatic=[0.6 0.6 0.6];
            mycolorsstatic=repmat(mycolorsstatic,ceil(length(sgwnodesstatic)/size(mycolorsstatic,1)),1);
            if assignment
                mycolors=repmat(hsv(4),ceil(length(sgwnodes)/3),1);
            end
            for i=1:length(sgwnodes)
                neplusAssignedToThisSGW=find(assignmentIdxNESGW==i);
                if latency
                    diffNESGW=mindiff(find(assignmentIdxNESGW==i));
                end
                for j=1:length(neplusAssignedToThisSGW)
                    if ~isempty(find(assignmentIdx==neplusAssignedToThisSGW(j),1))
                        if latency
                            color=repmat('k',length(sgwnodes),1);
                            color2=mycolorsstatic;
                            if assignment
                                color=mycolors;
                                color2=mycolors;
                            end
                            plot(x(assignmentIdx==neplusAssignedToThisSGW(j)),y(assignmentIdx==neplusAssignedToThisSGW(j)),'.','Color',color2(i,:),'MarkerFaceColor',color2(i,:),'LineSmoothing','off','Parent',hPlotAxes1);
                            plot(coordinates(citynodes(neplusAssignedToThisSGW(j)),1),coordinates(citynodes(neplusAssignedToThisSGW(j)),2),'d','Color',color(i,:),'MarkerFaceColor',getgreenyellowred(diffNESGW(j)/(highLatency)),'LineSmoothing','off','Parent',hPlotAxes1)
                        else
                            plot(x(assignmentIdx==neplusAssignedToThisSGW(j)),y(assignmentIdx==neplusAssignedToThisSGW(j)),'.','Color',mycolors(i,:),'MarkerFaceColor',mycolors(i,:),'LineSmoothing','off','Parent',hPlotAxes1);
                            plot(coordinates(citynodes(neplusAssignedToThisSGW(j)),1),coordinates(citynodes(neplusAssignedToThisSGW(j)),2),'dk','MarkerFaceColor',mycolors(i,:),'LineSmoothing','off','Parent',hPlotAxes1)
                        end
                    end
                end
            end
        end
    end

%----------------------------------------------------------------------
% Plots the pareto plot for hierarchical topologies

    function plotParetoHierarchicalCallback(hObject, eventdata)
        plotParetoHierarchical;
    end

    function plotParetoHierarchical
        axes(hPlotAxes2);
        cla;
        set(gca,'Visible','on');
        hold on;
        plotPareto([solutionAll.(valuex)],[solutionAll.(valuey)],'ShowSelectedIdx',currPlacement,'Parent',hPlotAxes2,'ShowMeanValues','off');
        xlabel(char(mValues2(get(hXAxisPopupMenuHierarchical,'Value'),3)));
        ylabel(char(mValues2(get(hYAxisPopupMenuHierarchical,'Value'),3)));
    end

    function hAxisPopupMenuHierarchicalCallback(hObject, eventdata)
        valuex=char(mValues2{get(hXAxisPopupMenuHierarchical,'Value'),2});
        valuey=char(mValues2{get(hYAxisPopupMenuHierarchical,'Value'),2});
        plotParetoHierarchical;
    end

%----------------------------------------------------------------------
% Plots the links of the hierarchical topology

    function plotLinks
        axes(hPlotAxes1);
        box off;
        hold on;
        if strcmp(get(hThemesClassicMenuitem,'Checked'),'on')
            gplot(topology~=inf,coordinates,'k-');
        else
            gplot(topology~=inf,coordinates,'w-');
        end        
        set(hCheckLinks,'Value',1);
        set(hHierarchicalShowLinksMenuitem,'Checked','on');
        set(gca,'Visible','off');
        xlim([-0.04e5 .7e5])
        ylim([-0.03e5 1e5])
    end

%----------------------------------------------------------------------
% Plots the access nodes of the hierarchical topology

    function plotAccessNodes(assignment,latency)
        if ~isempty(str2num(get(hEditLatency,'String')))
            highLatency=str2num(get(hEditLatency,'String'));
        else
            set(hEditLatency,'String','300');
        end
        k=1;
        mycolorsstatic=[0.6 0.6 0.6];
        if assignment || latency
            k=length(sgwnodesstatic);
            [mindiff assignmentIdxNESGW]=calculateBaseStationAssignmentTransport(distanceMatrix,citynodes,sgwnodesstatic);
            if assignment
                colorsNew=hsv(k);
                mycolorsstatic(1:k,:)=colorsNew(1:k,:);
            else
                mycolorsstatic(1:k,:)=repmat(mycolorsstatic,k,1);
            end
        end
        for i=1:k
            neplusAssignedToThisSGW=[1:length(citynodes)];
            color=mycolorsstatic(i,:);
            if assignment || latency
                neplusAssignedToThisSGW=find(assignmentIdxNESGW==i);
            end
            if latency
                diffNESGW=mindiff(find(assignmentIdxNESGW==i));
                for j=1:length(neplusAssignedToThisSGW);
                    plot(coordinates(citynodes(neplusAssignedToThisSGW(j)),1),coordinates(citynodes(neplusAssignedToThisSGW(j)),2),'d','Color',color,'MarkerSize',8,'MarkerFaceColor',getgreenyellowred(diffNESGW(j)/(highLatency)),'LineSmoothing','off','Parent',hPlotAxes1);
                end
            else
                plot(coordinates(citynodes(neplusAssignedToThisSGW)',1),coordinates(citynodes(neplusAssignedToThisSGW)',2),'d','Color',darken(color),'MarkerSize',8,'MarkerFaceColor',color,'LineSmoothing','off','Parent',hPlotAxes1)
            end
        end
        set(hCheckAccessNodes,'Value',1);
        set(hHierarchicalShowAccessNodesMenuitem,'Checked','on');
        set(hEditLatency,'Enable','on');
    end

%----------------------------------------------------------------------
% Plots the base stations of the hierarchical topology

    function plotBaseStations(assignment)
        k=1;
        mycolorsstatic=[0.6 0.6 0.6];
        set(hCheckBaseStations,'Value',1);
        set(hHierarchicalShowBaseStationsMenuitem,'Checked','on');
        if assignment
            k = length(sgwnodesstatic);
            assignmentIdxStatic=calculateBaseStationAssignment(coordinates,citynodes,baseX,baseY);
            [mindiff assignmentIdxNESGW]=calculateBaseStationAssignmentTransport(distanceMatrix,citynodes,sgwnodesstatic);
            colorsNew=hsv(k);
            mycolorsstatic(1:length(sgwnodesstatic),:)=colorsNew(1:length(sgwnodesstatic),:);
        end
        for i=1:k
            if assignment
                neplusAssignedToThisSGW=find(assignmentIdxNESGW==i);
                plot(baseX(find(ismember(assignmentIdxStatic,neplusAssignedToThisSGW)))',baseY(find(ismember(assignmentIdxStatic,neplusAssignedToThisSGW)))','.','Color',mycolorsstatic(i,:),'MarkerSize',6,'LineSmoothing','off','Parent',hPlotAxes1);
            else
                plot(baseX',baseY','.','Color',mycolorsstatic,'MarkerFaceColor',mycolorsstatic,'MarkerSize',6,'LineWidth',1,'LineSmoothing','off','Parent',hPlotAxes1);
            end
        end
    end

%----------------------------------------------------------------------
% Plots the SGW locations of the hierarchical topology

    function plotSGWlocations
        set(hCheckSGWlocations,'Value',1);
        set(hHierarchicalShowSGWlocationsMenuitem,'Checked','on');
        mycolorsstatic=[0.6 0.6 0.6];
        plot(coordinates(corenodes,1),coordinates(corenodes,2),'o','Color',darken(mycolorsstatic),'MarkerFaceColor','w','MarkerSize',14,'LineSmoothing','off','Parent',hPlotAxes1);
    end

%----------------------------------------------------------------------
% Plots the SGWs of the hierarchical topology

    function plotSGWs(assignment,icons)
        set(hCheckSGWs,'Value',1);
        set(hHierarchicalShowSGWsMenuitem,'Checked','on');
        mycolorsstatic=[0.6 0.6 0.6];
        if icons
            [imgH, imgW, tildevar] = size(sgwImg);
            img='';
            if ~planned
                img=sgwImg;
            else
                img=sgwLight;
            end
            for i=1:length(sgwnodesstatic)
                image([(coordinates(sgwnodesstatic(i),1)-(imgW*10)/2 +500) (coordinates(sgwnodesstatic(i),1)+(imgW*10)/2 -500)],[coordinates(sgwnodesstatic(i),2)+(imgH*10)/2 coordinates(sgwnodesstatic(i),2)-(imgH*10)/2],img,'Parent',gca);
            end
            assignment=1;
        end
        if assignment
            colorsNew=hsv(length(sgwnodesstatic));
            mycolorsstatic(1:length(sgwnodesstatic),:)=colorsNew(1:length(sgwnodesstatic),:);
            for i=1:length(sgwnodesstatic)
                plot(coordinates(sgwnodesstatic(i),1),coordinates(sgwnodesstatic(i),2),'ko','MarkerFaceColor',mycolorsstatic(i,:),'MarkerSize',12,'LineSmoothing','off','Parent',hPlotAxes1)
            end
        else
            plot(coordinates(sgwnodesstatic,1),coordinates(sgwnodesstatic,2),'ko','MarkerFaceColor',mycolorsstatic,'MarkerSize',12,'LineSmoothing','off','Parent',hPlotAxes1)
        end
    end

%----------------------------------------------------------------------
% Plots the NE+ of the hierarchical topology

    function plotNeplus(icons)
        set(hCheckNeplus,'Value',1);
        set(hHierarchicalShowNeplusMenuitem,'Checked','on');
        mycolorsstatic=[0.6 0.6 0.6];
        if icons
            [imgH, imgW, tildevar] = size(neplusImg);
            img='';
            if ~planned
                img=neplusImg;
            else
                img=neplusLight;
            end
            for i=1:length(neplusnodesNOSGW)
                image([(coordinates(neplusnodesNOSGW(i),1)-(imgW*10)/2 + 500) (coordinates(neplusnodesNOSGW(i),1)+(imgW*10)/2 - 500)],[coordinates(neplusnodesNOSGW(i),2)+(imgH*10)/2 coordinates(neplusnodesNOSGW(i),2)-(imgH*10)/2],img,'Parent',hPlotAxes1);
            end
        else
            plot(coordinates(neplusnodesNOSGW,1),coordinates(neplusnodesNOSGW,2),'o','MarkerFaceColor','w','MarkerSize',11,'Color',darken(mycolorsstatic),'LineWidth',1,'LineSmoothing','off','Parent',hPlotAxes1);
        end
    end

%----------------------------------------------------------------------
% Plots the Mega Event placements

    function plotMegaEvents
        set(hHierarchicalView3,'Visible','on');
        set(hHierarchicalView4,'Visible','on');
        set(hresetHierarchicalMenuitem,'Enable','on');
        set(hSaveMegaEventsMenuitem,'Enable','on');
        hold on;
        plot3(locX,locY,ones(size(locX)),'kp','MarkerFaceColor',[1 200/255 0],'MarkerSize',24,'LineWidth',1.5,'Color',darken([1 200/255 0]),'LineSmoothing','off','Parent',hPlotAxes1);
        set(hCheckMegaEvents,'Enable','on');
        set(hHierarchicalShowMegaEventsMenuitem,'Enable','on');
        set(hHierarchicalShowMegaEventsMenuitem,'Checked','on');
        set(hCheckMegaEvents,'Value',1);
    end


%----------------------------------------------------------------------
% Loads a topology
    function OpenTopologyCallback(hObject, eventdata)
        [filename, pathname] = uigetfile({'*.topo.mat;*.graphml;*.xml','Graph topology (*.topo.mat, *.graphml, *.xml)';'*.topo.mat','POCO topology (*.topo.mat)';'*.graphml','GraphML / GephiGraphML topology (*.graphml)';'*.xml','SNDlib topology (*.xml)'},'Please select a valid topology file');
        file = fullfile(pathname, filename);
        if ~isequal(filename, 0)
            if isHierarchic
                stopHierarchical;
            end
            reset;
            if ~isempty(strfind(filename,'.topo.mat'))
                [topology,coordinates,tm,nodenames,distanceMatrix]=loadMatFile(file);
            elseif ~isempty(strfind(filename,'.graphml'))
                [topology,coordinates,nodenames,distanceMatrix]=importGraphML(file);
                if isempty(topology)
                    [topology,coordinates,nodenames,distanceMatrix]=importGephiGraphML(file);
                end
            elseif ~isempty(strfind(filename,'.xml'))
                [topology,coordinates,nodenames,distanceMatrix]=importSNDlibXML(file);
            else
                topology = [];
            end
        else
            return
        end

        topologyName = filename(1:find(filename=='.')-1);
        if isempty(topology)
            errordlg('The selected file is not a valid topology.','File Error');
            return
        end
        if ~isempty(tm)
            set(hNodeWeightsMenuItem,'Visible','on','Enable','on');
            set(hCheckBoxTM,'Visible','on','Value',0);
        end
        set(hEditControllerFailureIDs,'Enable','on');
        set(hEditNodeFailureIDs,'Enable','on');
        set(hNMenuitem.base,'Enable','on');
        set(hCMenuitem.base,'Enable','on');
        set(hCheckBoxMenuHeatmap,'Enable','on');
        set(hCheckBoxHeatmap,'Visible','on');
        set(hPlotOptionsMenu,'Enable','on');
        set(hPredefinedViewsMenu,'Enable','on');
        set(hThemesMenu,'Enable','on');
        set(hExtractMenuitem,'Enable','on');
        distanceMatrix_org = allToAllShortestPathMatrix(topology);
        topology_org = topology;
        tm_org = tm;
        updateCheckBoxMenu;
        plotFigures;
    end

%----------------------------------------------------------------------
% Starts Planetlab
    function InitPOCOPLC(hObject, eventdata)
        reset;
        [topology,coordinates,tm,nodenames]=loadNewPLCfile(plcFileCounter);
        if ~isempty(topology)
            set(hStartPlanetlabPlotLoopMenuitem,'Visible','on');
            set(hStopPlanetlabPlotLoopMenuitem,'Visible','on');
            set(hStartPlanetlabCalcLoopMenuitem,'Visible','on');
            set(hStopPlanetlabCalcLoopMenuitem,'Visible','on');
            set(hFetchPlanetlabDataMenuitem,'Visible','on');
            set(hInitPLCMenuitem,'Visible','off');
            set(hStopPLCMenuitem,'Visible','on');
            set(hLoadHistPLCMenuitem,'Visible','on');
            set(hSaveHistPLCMenuitem,'Visible','on');
            if strcmp(get(hThemesClassicMenuitem,'Checked'),'off')
                changeTheme([1 1 1],[0 0 0]);
            end
            set(hThemesMenu,'Enable','off');
            if ishandle(hFigurePLC)
                set(hFigurePLC,'Visible','on');
            else
                openPLFig;
            end
            plcTopo = 1;
            topologyName = 'POCO PLC';

            if ~isempty(tm)
                set(hNodeWeightsMenuItem,'Visible','on','Enable','on');
                set(hCheckBoxTM,'Visible','on','Value',0);
            end
            set(hEditControllerFailureIDs,'Enable','on');
            set(hEditNodeFailureIDs,'Enable','on');
            set(hCheckBoxTM,'Value',1);
            set(hNMenuitem.base,'Enable','on');
            set(hCMenuitem.base,'Enable','on');
            set(hCheckBoxMenuHeatmap,'Enable','on');
            set(hCheckBoxHeatmap,'Visible','on');
            set(hLatenciesMenu,'Visible','off');
            set(hNodeWeightsMenu,'Visible','off');
            set(hEdgeOptionsMenu,'Visible','off');
            tmbool=1;
            set(hNodeWeightsMenuItem,'Checked','on');
            topology_org = topology;
            tm_org = tm;
            updateCheckBoxMenu;
            plotFigures;
        else
            errordlg('The selected file is not a valid topology.','File Error');
            return
        end
    end

%----------------------------------------------------------------------
% Stops Planetlab
    function StopPOCOPLC(hObject, eventdata)
        stop(plcPlotTimer);
        stop(plcCalcTimer);
        reset;
        plotFigures;
        reset;
        if ishandle(hFigurePLC)
            delete(hFigurePLC);
        end
    end

%----------------------------------------------------------------------
% Starts the plot loop for Planetlab

    function startPLCLoopCallback(hObject, eventdata)
        if ~ishandle(hFigurePLC)
            openPLFig;
        end
        set(hSaveHistPLCMenuitem,'Enable','on');
        start(plcPlotTimer);
    end

    function PLCPlotLoop(hObject, eventdata)
        % Transfer current controllers by saving names
        controllerplacesOriginal=str2num(get(hEditControllerIDs,'String'));
        controllernamesOriginal=nodenames(controllerplacesOriginal);
        failedControllersOriginal=str2num(get(hEditControllerFailureIDs,'String'));
        failedControllerNamesOriginal=nodenames(failedControllersOriginal);
        [topologyPLC,coordinatesPLC,tmPLC,nodenamesPLC]=loadNewPLCfile(plcFileCounter);
        plcFileCounter=plcFileCounter+1;
        if plcFileCounter>11199
            plcFileCounter=11100;
        end
        if ~isempty(topologyPLC)
            controllerplacesPLC=[];
            for m=1:length(controllernamesOriginal)
                controllerplacesPLC=[controllerplacesPLC find(~cellfun(@isempty,strfind(nodenamesPLC,controllernamesOriginal{m})))];
            end
            failedControllersPLC=[];
            for m=1:length(failedControllersOriginal)
                failedControllersPLC=[failedControllersPLC find(~cellfun(@isempty,strfind(nodenamesPLC,failedControllersOriginal{m})))];
            end
            failedNodesPLC=find(nansum(topology,1)==0);

            drawnow
            plotAxesPLC;
        end
    end

%----------------------------------------------------------------------
% Stops the plot loop for Planetlab
    function stopPLCLoopCallback(hObject, eventdata)
        stop(plcPlotTimer);
    end

%----------------------------------------------------------------------
% Starts the calculation loop for Planetlab

    function startPLCCalcCallback(hObject, eventdata)
        if ~ishandle(hFigurePLC)
            openPLFig;
        end
        set(hSaveHistPLCMenuitem,'Enable','on');
        start(plcCalcTimer);
    end

    function PLCCalcLoop(hObject, eventdata)
        controllerplacesOriginal=str2num(get(hEditControllerIDs,'String')); % just to check if figure still open
        if ~isempty(topologyPLC)
            [tildevar,maxarrayPLC,uncoveredarrayPLC,balancearrayPLC,balancevalsPLCNew]=evaluatePlacementsFast(topologyPLC,nk,tmPLC);
            plcCounter=plcCounter+1;
            if isempty(maxmaxarrayPLC)
                maxmaxarrayPLC=maxarrayPLC;
            else
                maxmaxarrayPLC=nanmax([maxarrayPLC;maxmaxarrayPLC]);
            end
            if isempty(sumuncoveredarrayPLC)
                sumuncoveredarrayPLC=uncoveredarrayPLC;
            else
                sumuncoveredarrayPLC=nansum([uncoveredarrayPLC;sumuncoveredarrayPLC]);
            end
            if isempty(sumbalancearrayPLC)
                sumbalancearrayPLC=balancearrayPLC;
            else
                sumbalancearrayPLC=nansum([balancearrayPLC;sumbalancearrayPLC]);
            end
            if isempty(changesPLC)
                changesPLC=zeros(size(sumbalancearrayPLC));
            else
                changesPLC=nansum([nansum((balancevalsPLCNew-balancevalsPLC)~=0);changesPLC]);
            end
            balancevalsPLC=balancevalsPLCNew;
            newPLCCalc=1;
        end
    end

%----------------------------------------------------------------------
% Stops the calculation loop for Planetlab
    function stopPLCCalcCallback(hObject, eventdata)
        stop(plcCalcTimer);
    end

%----------------------------------------------------------------------
% Fetches the data from the Planetlab live view and assignes it to POCO
    function fetchPLCdataCallback(hObject, eventdata)
        fetchPLCdata;
    end

    function fetchPLCdata
        set(hEditControllerIDs,'String',num2str(controllerplacesPLC))
        set(hEditControllerFailureIDs,'String',num2str(failedControllersPLC))
        set(hEditNodeFailureIDs,'String',num2str(failedNodesPLC))
        set(hStartPlanetlabPlotLoopMenuitem,'Enable','on');
        set(hStopPlanetlabPlotLoopMenuitem,'Enable','on');
        set(hStartPlanetlabCalcLoopMenuitem,'Enable','on');
        set(hStopPlanetlabCalcLoopMenuitem,'Enable','on');
        topology=topologyPLC;
        tm=tmPLC;
        coordinates=coordinatesPLC;
        nodenames=nodenamesPLC;
        if ~isempty(topology)
            plotFigures;
        end
    end

%----------------------------------------------------------------------
% Saves the current topology as .topo.mat file
    function SaveAsTopologyCallback(hObject, eventdata)
        [filename, pathname] = uiputfile({'*.topo.mat','POCO topology (*.topo.mat)'},'Save topology as...');
        file = fullfile(pathname, filename);
        if ~isequal(filename, 0)
            saveTopology(file);
        end
    end

    function saveTopology(file)
        save(file, '-mat','coordinates','nodenames','tm','topology');
    end

%----------------------------------------------------------------------
    function inputMainFigureCallback(hObject, eventdata)
        set(hResultPopupMenu,'Value',1);
        set(hScenarioPopupMenu,'Value',1);
        plotFigures;
        updateCheckBoxMenu;
    end

%----------------------------------------------------------------------
% Calls the functions for plotting the topology and pareto-plot, and for
% updating the checkbox-menu
    function plotFiguresCallback(hObject, eventdata)
        plotFigures;
        updateCheckBoxMenu;
    end

%----------------------------------------------------------------------
% Calls the functions for plotting the topology and pareto-plot, and for
% updating the checkboxes
    function plotFiguresCallbackMenu(hObject, eventdata,k)
        updateCheckBoxFromMenu(k);
        plotFigures;
    end

%----------------------------------------------------------------------
% Updates the pareto-plot according to the selected values for x-axis and
% y-axis
    function hAxisPopupMenuCallback(hObject, eventdata)
        valuex=char(mValues{get(hXAxisPopupMenu,'Value'),2});
        valuey=char(mValues{get(hYAxisPopupMenu,'Value'),2});
        plotAxes2;
        fixAxes2PlotTextColor;
    end

%----------------------------------------------------------------------
% Updates the plots according to the selected best placement
    function hResultPopupMenuCallback(hObject, eventdata)
        if ~isempty(solution)
            switch get(hResultPopupMenu,'Value')
                case 2
                    val1=min(solution.maxLatencyN2C);
                    val2=min(solution.controllerImbalance(solution.maxLatencyN2C==val1));
                    idx=find(solution.maxLatencyN2C==val1 & solution.controllerImbalance==val2,1,'last');
                    currPlacement=idx;
                    checkScenarioSelection;
                    set(hEditControllerIDs,'String',num2str(nk(idx,:)));
                    plotFigures;
                case 3
                    val1=min(solution.controllerImbalance);
                    val2=min(solution.maxLatencyN2C(solution.controllerImbalance==val1));
                    idx=find(solution.controllerImbalance==val1 & solution.maxLatencyN2C==val2,1,'last');
                    currPlacement = idx;
                    checkScenarioSelection;
                    set(hEditControllerIDs,'String',num2str(nk(idx,:)));
                    plotFigures;
                case 4
                    val1=min(solution.maxLatencyC2C);
                    val2=min(solution.controllerImbalance(solution.maxLatencyC2C==val1));
                    idx=find(solution.maxLatencyC2C==val1 & solution.controllerImbalance==val2,1,'last');
                    currPlacement = idx;
                    checkScenarioSelection;
                    set(hEditControllerIDs,'String',num2str(nk(idx,:)));
                    plotFigures;
                case 5
                    if (strcmpi(optType,'N') || strcmpi(optType,'N2'))
                        maxLatencyN2CAllFailures=solution.maxLatencyN2CAllNodeFailures;
                    else
                        maxLatencyN2CAllFailures=solution.maxLatencyN2CAllControllerFailures;
                    end
                    val1=min(maxLatencyN2CAllFailures);
                    val2=min(solution.maxLatencyN2C(maxLatencyN2CAllFailures==val1));
                    idx=find(solution.maxLatencyN2C==val2 & maxLatencyN2CAllFailures==val1,1,'last');
                    currPlacement = idx;
                    checkScenarioSelection;
                    set(hEditControllerIDs,'String',num2str(nk(idx,:)));
                    plotFigures;
                case 6
                    if (strcmpi(optType,'N') || strcmpi(optType,'N2'))
                        controllerImbalanceAllFailures = solution.controllerImbalanceAllNodeFailures;
                    else
                        controllerImbalanceAllFailures = solution.controllerImbalanceAllControllerFailures;
                    end
                    val1=min(controllerImbalanceAllFailures);
                    val2=min(solution.maxLatencyN2C(controllerImbalanceAllFailures==val1));
                    idx=find(solution.maxLatencyN2C==val2 & controllerImbalanceAllFailures==val1,1,'last');
                    currPlacement = idx;
                    checkScenarioSelection;
                    set(hEditControllerIDs,'String',num2str(nk(idx,:)));
                    plotFigures;
                case 7
                    if (strcmpi(optType,'N') || strcmpi(optType,'N2'))
                        maxLatencyC2CAllFailures = solution.maxLatencyC2CAllNodeFailures;
                    else
                        maxLatencyC2CAllFailures = solution.maxLatencyC2CAllControllerFailures;
                    end
                    val1=min(maxLatencyC2CAllFailures);
                    val2=min(solution.maxLatencyN2C(maxLatencyC2CAllFailures==val1));
                    idx=find(solution.maxLatencyN2C==val2 & maxLatencyC2CAllFailures==val1,1,'last');
                    currPlacement = idx;
                    checkScenarioSelection;
                    set(hEditControllerIDs,'String',num2str(nk(idx,:)));
                    plotFigures;
                case 8
                    val1=min(solution.maxNumberOfControllerlessNodes);
                    val2=min(solution.maxLatencyN2C(solution.maxNumberOfControllerlessNodes==val1));
                    idx=find(solution.maxLatencyN2C==val2 & solution.maxNumberOfControllerlessNodes==val1,1,'last');
                    currPlacement = idx;
                    checkScenarioSelection;
                    set(hEditControllerIDs,'String',num2str(nk(idx,:)));
                    plotFigures;
            end
        end
    end

%----------------------------------------------------------------------
% Updates the placement according to the selected scenaro
    function hScenarioPopupMenuCallback(hObject, eventdata)
        checkScenarioSelection;
        if ~isempty(topology) && ~isempty(solution) && ~~isempty(strfind(optType,'F'))
            plotFigures;
        end
    end


    function checkScenarioSelection
        if ~isempty(topology) && ~isempty(solution) && ~~isempty(strfind(optType,'F'))
            k=active_k;
            idx=floor(currPlacement);
            switch get(hScenarioPopupMenu,'Value')
                case 2
                    set(hEditControllerFailureIDs,'String','');
                    set(hEditNodeFailureIDs,'String','');
                case 3
                    [tildevar,worst_number]=max(solution.maxLatencyN2CForNFailures(:,idx));
                    nodesFailed=[];
                    controllersFailed=[];
                    if ~isempty(strfind(optType,'N'))
                        failurepatterns=combnk(1:size(topology),worst_number);
                        if ~isnan(solution.failurePatternIndexOfMaxLatencyN2CForNFailures(worst_number,idx))
                            nodesFailed=failurepatterns(solution.failurePatternIndexOfMaxLatencyN2CForNFailures(worst_number,idx),:);
                        else
                            nodesFailed=[];
                        end
                    elseif ~isempty(strfind(optType,'C'))
                        nk=combnk(1:size(topology,1),k);
                        failurepatterns=combnk(1:k,k-worst_number);
                        if ~isnan(solution.failurePatternIndexOfMaxLatencyN2CForNFailures(worst_number,idx))
                            if matlabVersion <2013
                                controllersFailed=nk(idx,setdiff(1:size(nk,2),failurepatterns(solution.failurePatternIndexOfMaxLatencyN2CForNFailures(worst_number,idx),:)));
                            else
                                controllersFailed=nk(idx,setdiff(1:size(nk,2),failurepatterns(solution.failurePatternIndexOfMaxLatencyN2CForNFailures(worst_number,idx),:),'legacy'));
                            end
                        else
                            controllersFailed=[];
                        end
                    end
                    set(hEditNodeFailureIDs,'String',num2str(nodesFailed));
                    set(hEditControllerFailureIDs,'String',num2str(controllersFailed));
                case 4
                    [tildevar,worst_number]=max(solution.controllerImbalanceForNFailures(:,idx));
                    nodesFailed=[];
                    controllersFailed=[];
                    if ~isempty(strfind(optType,'N'))
                        failurepatterns=combnk(1:size(topology),worst_number);
                        if ~isnan(solution.failurePatternIndexOfControllerImbalanceForNFailures(worst_number,idx))
                            nodesFailed=failurepatterns(solution.failurePatternIndexOfControllerImbalanceForNFailures(worst_number,idx),:);
                        else
                            nodesFailed=[];
                        end
                    elseif ~isempty(strfind(optType,'C'))
                        nk=combnk(1:size(topology,1),k);
                        failurepatterns=combnk(1:k,k-worst_number);
                        if ~isnan(solution.failurePatternIndexOfControllerImbalanceForNFailures(worst_number,idx))
                            if matlabVersion < 2013
                                controllersFailed=nk(idx,setdiff(1:size(nk,2),failurepatterns(solution.failurePatternIndexOfControllerImbalanceForNFailures(worst_number,idx),:)));
                            else
                                controllersFailed=nk(idx,setdiff(1:size(nk,2),failurepatterns(solution.failurePatternIndexOfControllerImbalanceForNFailures(worst_number,idx),:),'legacy'));
                            end
                        else
                            controllersFailed=[];
                        end
                    end
                    set(hEditNodeFailureIDs,'String',num2str(nodesFailed));
                    set(hEditControllerFailureIDs,'String',num2str(controllersFailed));
                case 6
                    [tildevar,worst_number]=max(solution.maxNumberOfControllerlessNodesForNFailures(:,idx));
                    nodesFailed=[];
                    controllersFailed=[];
                    if ~isempty(strfind(optType,'N'))
                        failurepatterns=combnk(1:size(topology),worst_number);
                        if ~isnan(solution.failurePatternIndexOfMaxNumberOfControllerlessNodesForNFailures(worst_number,idx))
                            nodesFailed=failurepatterns(solution.failurePatternIndexOfMaxNumberOfControllerlessNodesForNFailures(worst_number,idx),:);
                        else
                            nodesFailed=[];
                        end
                    elseif ~isempty(strfind(optType,'C'))
                        nk=combnk(1:size(topology,1),k);
                        failurepatterns=combnk(1:k,k-worst_number);
                        if ~isnan(solution.failurePatternIndexOfMaxNumberOfControllerlessNodesForNFailures(worst_number,idx))
                            if matlabVersion < 2013
                                controllersFailed=nk(idx,setdiff(1:size(nk,2),failurepatterns(solution.failurePatternIndexOfMaxNumberOfControllerlessNodesForNFailures(worst_number,idx),:)));
                            else
                                controllersFailed=nk(idx,setdiff(1:size(nk,2),failurepatterns(solution.failurePatternIndexOfMaxNumberOfControllerlessNodesForNFailures(worst_number,idx),:),'legacy'));
                            end
                        else
                            controllersFailed=[];
                        end
                    end
                    set(hEditNodeFailureIDs,'String',num2str(nodesFailed));
                    set(hEditControllerFailureIDs,'String',num2str(controllersFailed));
                case 5
                    [tildevar,worst_number]=max(solution.maxLatencyC2CForNFailures(:,idx));
                    nodesFailed=[];
                    controllersFailed=[];
                    if ~isempty(strfind(optType,'N'))
                        failurepatterns=combnk(1:size(topology),worst_number);
                        if ~isnan(solution.failurePatternIndexOfMaxLatencyC2CForNFailures(worst_number,idx))
                            nodesFailed=failurepatterns(solution.failurePatternIndexOfMaxLatencyC2CForNFailures(worst_number,idx),:);
                        else
                            nodesFailed=[];
                        end
                    elseif ~isempty(strfind(optType,'C'))
                        nk=combnk(1:size(topology,1),k);
                        failurepatterns=combnk(1:k,k-worst_number);
                        if ~isnan(solution.failurePatternIndexOfMaxLatencyC2CForNFailures(worst_number,idx))
                            if matlabVersion < 2013
                                controllersFailed=nk(idx,setdiff(1:size(nk,2),failurepatterns(solution.failurePatternIndexOfMaxLatencyC2CForNFailures(worst_number,idx),:)));
                            else
                                controllersFailed=nk(idx,setdiff(1:size(nk,2),failurepatterns(solution.failurePatternIndexOfMaxLatencyC2CForNFailures(worst_number,idx),:),'legacy'));
                            end
                        else
                            controllersFailed=[];
                        end
                    end
                    set(hEditNodeFailureIDs,'String',num2str(nodesFailed));
                    set(hEditControllerFailureIDs,'String',num2str(controllersFailed));
            end
        end
    end


%----------------------------------------------------------------------
% Calculates different controller placements for k controller considering a
% failure free case
    function optimizeFailureFree(hObject,eventdata,k)
        if ~isempty(topology)
            set(hScenarioLabel,'Visible','off');
            set(hScenarioPopupMenu,'Visible','off');
            set(hMainFigure,'Pointer','watch');
            set(hStatusLabel,'String','Calculating placements - please wait...');
            drawnow;
            tmstring='';
            if ~tmbool % tm not activated
                set(hCheckBoxTM,'Value',0);
                tmtemp=ones(1,size(topology,1));
            else
                set(hCheckBoxTM,'Value',1);
                tmtemp=tm(tmindex,:);
                optTm=1;
                tmstring='with node weights';
            end
            tic;
            if ~plcTopo
                solution=evaluateSingleInstance(distanceMatrix,k,tmtemp);
            else
                solution=evaluateSingleInstance(allToAllShortestPathMatrix(topology),k,tmtemp);
            end
            calcToc=toc;
            nksize=nchoosek(size(topology,1),k);
            nk=combnk(1:size(topology,1),k);
            currPlacement = 1;
            if k < 2
                set(hResultPopupMenu,'Visible','on','String',pValuesF(1,1:3));
            else
                set(hResultPopupMenu,'Visible','on','String',pValuesF);
            end
            set(hResultLabel,'Visible','on');
            optType='F';
            active_k=k;
            mValues=mValuesF;
            set(hEditControllerIDs,'String',num2str(nk(1,:)));
            set(hXAxisPopupMenu,'String',mValues(1:3,1));
            set(hYAxisPopupMenu,'String',mValues(1:3,1));
            panelAxis1Pos = get(hPanelAxes1,'Position');
            if panelAxis1Pos(4) < 0.8
                set(hXAxisPopupMenu,'Visible','on');
                set(hYAxisPopupMenu,'Visible','on');
                set(hXAxisLabel,'Visible','on');
                set(hYAxisLabel,'Visible','on');
            end
            valuex=char(mValues{1,2});
            valuey=char(mValues{2,2});
            set(hYAxisPopupMenu,'Value',2);

            val1=min(solution.maxLatencyN2C);
            val2=min(solution.controllerImbalance(solution.maxLatencyN2C==val1));
            idx=find(solution.maxLatencyN2C==val1 & solution.controllerImbalance==val2,1,'last');
            currPlacement = idx;
            set(hResultPopupMenu,'Value',2);
            checkScenarioSelection;
            set(hEditControllerIDs,'String',num2str(nk(idx,:)));
            set(hEditNodeFailureIDs,'String','');
            set(hEditControllerFailureIDs,'String','');

            plotFigures;
            set(hMainFigure,'Pointer','arrow');
            set(hStatusLabel,'String',sprintf('Current placements: %s considering only failure free case with k=%d controllers - %d placements, calculated in %.2f seconds',tmstring,k,nksize,calcToc));
            set(hSavePlacementsMenuitem,'Enable','on');
            set(hEditControllerIDs,'Visible','on');
            set(hEditControllerFailureIDs,'Visible','on');
            set(hEditNodeFailureIDs,'Visible','on');
            set(hLabelControllerIDs,'Visible','on');
            set(hLabelControllerFailureIDs,'Visible','on');
            set(hLabelNodeFailureIDs,'Visible','on');
            set(hCheckBoxDistNC,'Visible','on');
            set(hCheckBoxBalance,'Visible','on');
            set(hCheckBoxDistCC,'Visible','on');
            set(hStartPlanetlabPlotLoopMenuitem,'Enable','on');
            set(hStopPlanetlabPlotLoopMenuitem,'Enable','on');
            set(hStartPlanetlabCalcLoopMenuitem,'Enable','on');
            set(hStopPlanetlabCalcLoopMenuitem,'Enable','on');
        end
    end

%----------------------------------------------------------------------
% Calculates different controller placements for k controller considering
% up to two node failures
    function optimizeNodeFailure(hObject,eventdata,k)
        if ~isempty(topology)
            set(hMainFigure,'Pointer','watch');
            set(hStatusLabel,'String','Calculating placements - please wait...');
            drawnow;
            tmstring='';
            if ~tmbool % tm not activated
                set(hCheckBoxTM,'Value',0);
                tmtemp=ones(1,size(topology,1));
            else
                set(hCheckBoxTM,'Value',1);
                tmtemp=tm(tmindex,:);
                optTm=1;
                tmstring='with node weights';
            end
            tic;
            solution=evaluateNodeFailure(topology,k,tmtemp);
            calcToc=toc;
            nksize=nchoosek(size(topology,1),k);
            nk=combnk(1:size(topology,1),k);
            set(hCheckBoxHeatmap,'Visible','on');

            currPlacement = 1;
            set(hResultPopupMenu,'Visible','on','String',pValuesN);
            set(hResultLabel,'Visible','on');
            set(hScenarioPopupMenu,'Visible','on','String',rbValuesN);
            set(hScenarioLabel,'Visible','on');
            optType='N';
            active_k=k;
            mValues=mValuesN;
            set(hEditControllerIDs,'String',num2str(nk(1,:)));
            set(hXAxisPopupMenu,'String',mValues(:,1));
            set(hYAxisPopupMenu,'String',mValues(:,1));
            panelAxis1Pos = get(hPanelAxes1,'Position');
            if panelAxis1Pos(4) < 0.8
                set(hXAxisPopupMenu,'Visible','on');
                set(hYAxisPopupMenu,'Visible','on');
                set(hXAxisLabel,'Visible','on');
                set(hYAxisLabel,'Visible','on');
            end
            set(hYAxisPopupMenu,'Value',7);
            valuex=char(mValues{1,2});
            valuey=char(mValues{7,2});

            val1=min(solution.maxLatencyN2C);
            val2=min(solution.controllerImbalance(solution.maxLatencyN2C==val1));
            idx=find(solution.maxLatencyN2C==val1 & solution.controllerImbalance==val2,1,'last');
            currPlacement = idx;
            set(hResultPopupMenu,'Value',2);
            set(hScenarioPopupMenu,'Value',2);
            checkScenarioSelection;
            set(hEditControllerIDs,'String',num2str(nk(idx,:)));

            plotFigures;
            set(hMainFigure,'Pointer','arrow');
            set(hStatusLabel,'String',sprintf('Current placements: %s considering up to two node failures with k=%d controllers - %d placements, calculated in %.2f seconds',tmstring,k,nksize,calcToc));
            set(hSavePlacementsMenuitem,'Enable','on');
            set(hEditControllerIDs,'Visible','on');
            set(hEditControllerFailureIDs,'Visible','on');
            set(hEditNodeFailureIDs,'Visible','on');
            set(hLabelControllerIDs,'Visible','on');
            set(hLabelControllerFailureIDs,'Visible','on');
            set(hLabelNodeFailureIDs,'Visible','on');
            set(hCheckBoxDistNC,'Visible','on');
            set(hCheckBoxBalance,'Visible','on');
            set(hCheckBoxDistCC,'Visible','on');
        end
    end

%----------------------------------------------------------------------
% Calculates different controller placements considering up to k-1
% controller failures
    function optimizeControllerFailure(hObject,eventdata,k)
        if ~isempty(topology)
            set(hMainFigure,'Pointer','watch');
            set(hStatusLabel,'String','Calculating placements - please wait...');
            drawnow;
            tmstring='';
            if ~tmbool % tm not activated
                set(hCheckBoxTM,'Value',0);
                tmtemp=ones(1,size(topology,1));
            else
                set(hCheckBoxTM,'Value',1);
                tmtemp=tm(tmindex,:);
                optTm=1;
                tmstring='with node weights';
            end
            tic;
            solution=evaluateControllerFailure(topology,k,tmtemp,plcTopo);
            calcToc = toc;
            nksize=nchoosek(size(topology,1),k);
            nk=combnk(1:size(topology,1),k);

            currPlacement = 1;
            set(hResultPopupMenu,'Visible','on','String',pValuesC);
            set(hResultLabel,'Visible','on');
            if k < 3
                set(hScenarioPopupMenu,'Visible','on','String',rbValuesC(1,1:3));
            else
                set(hScenarioPopupMenu,'Visible','on','String',rbValuesC);
            end
            set(hScenarioLabel,'Visible','on');
            optType='C';
            active_k=k;
            mValues=mValuesC;
            set(hEditControllerIDs,'String',num2str(nk(1,:)));
            set(hXAxisPopupMenu,'String',mValues(1:5,1));
            set(hYAxisPopupMenu,'String',mValues(1:5,1));
            panelAxis1Pos = get(hPanelAxes1,'Position');
            if panelAxis1Pos(4) < 0.8
                set(hXAxisPopupMenu,'Visible','on');
                set(hYAxisPopupMenu,'Visible','on');
                set(hXAxisLabel,'Visible','on');
                set(hYAxisLabel,'Visible','on');
            end
            set(hYAxisPopupMenu,'Value',4);
            valuex=char(mValues{1,2});
            valuey=char(mValues{4,2});

            val1=min(solution.maxLatencyN2C);
            val2=min(solution.controllerImbalance(solution.maxLatencyN2C==val1));
            idx=find(solution.maxLatencyN2C==val1 & solution.controllerImbalance==val2,1,'last');
            currPlacement = idx;
            set(hResultPopupMenu,'Value',2);
            set(hScenarioPopupMenu,'Value',2);
            checkScenarioSelection;
            set(hEditControllerIDs,'String',num2str(nk(idx,:)));

            plotFigures;
            set(hMainFigure,'Pointer','arrow');
            set(hStatusLabel,'String',sprintf('Current placements: %s considering up to k-1 controller failures with k=%d controllers - %d placements, calculated in %.2f seconds',tmstring,k,nksize,calcToc));
            set(hSavePlacementsMenuitem,'Enable','on');
            set(hEditControllerIDs,'Visible','on');
            set(hEditControllerFailureIDs,'Visible','on');
            set(hEditNodeFailureIDs,'Visible','on');
            set(hLabelControllerIDs,'Visible','on');
            set(hLabelControllerFailureIDs,'Visible','on');
            set(hLabelNodeFailureIDs,'Visible','on');
            set(hCheckBoxDistNC,'Visible','on');
            set(hCheckBoxBalance,'Visible','on');
            set(hCheckBoxDistCC,'Visible','on');
            set(hStartPlanetlabPlotLoopMenuitem,'Enable','on');
            set(hStopPlanetlabPlotLoopMenuitem,'Enable','on');
            set(hStartPlanetlabCalcLoopMenuitem,'Enable','on');
            set(hStopPlanetlabCalcLoopMenuitem,'Enable','on');
        end
    end

%----------------------------------------------------------------------
%
    function findMinimumK(hObject,eventdata)
        if ~isempty(topology)
            set(hMainFigure,'Pointer','watch');
            set(hStatusLabel,'String','Calculating placements - please wait...');
            drawnow;
            tmstring='';
            if ~tmbool % tm not activated
                set(hCheckBoxTM,'Value',0);
                tmtemp=ones(1,size(topology,1));
            else
                set(hCheckBoxTM,'Value',1);
                tmtemp=tm(tmindex,:);
                optTm=1;
                tmstring='with node weights';
            end
            tic;
            [nk,active_k]=findFullCoveragePlacements(topology);
            solution=evaluateNodeFailure(topology,active_k,tmtemp,2,nk);
            calcToc=toc;
            nksize=size(nk,1);

            currPlacement = 1;
            set(hResultPopupMenu,'Visible','on','String',pValuesN);
            set(hResultLabel,'Visible','on');
            set(hScenarioPopupMenu,'Visible','on','String',rbValuesN);
            set(hScenarioLabel,'Visible','on');
            optType='N2';
            mValues=mValuesN;
            set(hEditControllerIDs,'String',num2str(nk(1,:)));
            set(hXAxisPopupMenu,'String',mValues(1:6,1));
            set(hYAxisPopupMenu,'String',mValues(1:6,1));
            panelAxis1Pos = get(hPanelAxes1,'Position');
            if panelAxis1Pos(4) < 0.8
                set(hXAxisPopupMenu,'Visible','on');
                set(hYAxisPopupMenu,'Visible','on');
                set(hXAxisLabel,'Visible','on');
                set(hYAxisLabel,'Visible','on');
            end
            set(hYAxisPopupMenu,'Value',4);
            valuex=char(mValues{1,2});
            valuey=char(mValues{4,2});

            val1=min(solution.maxLatencyN2C);
            val2=min(solution.controllerImbalance(solution.maxLatencyN2C==val1));
            idx=find(solution.maxLatencyN2C==val1 & solution.controllerImbalance==val2,1,'last');
            currPlacement = idx;
            set(hResultPopupMenu,'Value',2);
            set(hScenarioPopupMenu,'Value',2);
            checkScenarioSelection;
            set(hEditControllerIDs,'String',num2str(nk(idx,:)));

            plotFigures;
            set(hMainFigure,'Pointer','arrow');
            set(hStatusLabel,'String',sprintf('Current placements: %s only placements being resilient against up to two node failures: k=%d controllers - %d placements, calculated in %.2f seconds',tmstring,active_k,nksize,calcToc));
            set(hSavePlacementsMenuitem,'Enable','on');
            set(hEditControllerIDs,'Visible','on');
            set(hEditControllerFailureIDs,'Visible','on');
            set(hEditNodeFailureIDs,'Visible','on');
            set(hLabelControllerIDs,'Visible','on');
            set(hLabelControllerFailureIDs,'Visible','on');
            set(hLabelNodeFailureIDs,'Visible','on');
            set(hCheckBoxDistNC,'Visible','on');
            set(hCheckBoxBalance,'Visible','on');
            set(hCheckBoxDistCC,'Visible','on');
            set(hStartPlanetlabPlotLoopMenuitem,'Enable','on');
            set(hStopPlanetlabPlotLoopMenuitem,'Enable','on');
            set(hStartPlanetlabCalcLoopMenuitem,'Enable','on');
            set(hStopPlanetlabCalcLoopMenuitem,'Enable','on');
        end
    end


%----------------------------------------------------------------------
% Loads placements from a .placements.mat file
    function loadPlacementsCallback(hObject, eventdata)
        if ~isempty(topology)
            [filename, pathname] = uigetfile({'*.placements.mat','controller placements (*.placements.mat)'},'Please select a valid placement.');
            file = fullfile(pathname, filename);
            if ~isequal(filename, 0)
                set(hMainFigure,'Pointer','watch');
                set(hStatusLabel,'String','Loading placements - please wait...');
                drawnow;
                [solution,nk,optType,active_k,optTm]=loadPlacements(file);
                if ~isempty(solution)
                    tmstring='';
                    if optTm==1
                        tmstring='with node weights';
                    end
                    nksize=size(nk,1);
                    currPlacement = 1;
                    k=active_k;
                    if ~isempty(strfind(optType,'F'))
                        mValues=mValuesF;
                        set(hEditControllerIDs,'String',num2str(nk(1,:)));
                        set(hXAxisPopupMenu,'String',mValues(1:3,1));
                        set(hXAxisPopupMenu,'Visible','on');
                        set(hYAxisPopupMenu,'String',mValues(1:3,1));
                        set(hYAxisPopupMenu,'Visible','on');
                        set(hXAxisLabel,'Visible','on');
                        set(hYAxisLabel,'Visible','on');
                        valuex=char(mValues{1,2});
                        valuey=char(mValues{2,2});
                        set(hYAxisPopupMenu,'Value',2);
                        set(hStatusLabel,'String',sprintf('Current placements: %s considering only failure free case with k=%d controllers - %d placements',tmstring,k,nksize));
                        set(hResultPopupMenu,'Visible','on','String',pValuesF);
                        set(hResultLabel,'Visible','on');
                    elseif ~isempty(strfind(optType,'C'))
                        mValues=mValuesC;
                        set(hEditControllerIDs,'String',num2str(nk(1,:)));
                        set(hXAxisPopupMenu,'String',mValues(1:6,1));
                        set(hXAxisPopupMenu,'Visible','on');
                        set(hYAxisPopupMenu,'String',mValues(1:6,1));
                        set(hYAxisPopupMenu,'Visible','on');
                        set(hYAxisPopupMenu,'Value',4);
                        set(hXAxisLabel,'Visible','on');
                        set(hYAxisLabel,'Visible','on');
                        valuex=char(mValues{1,2});
                        valuey=char(mValues{4,2});
                        set(hStatusLabel,'String',sprintf('Current placements: %s considering up to k-1 controller failures with k=%d controllers - %d placements',tmstring,k,nksize));
                        set(hResultPopupMenu,'Visible','on','String',pValuesC);
                        set(hResultLabel,'Visible','on');
                        set(hScenarioPopupMenu,'Visible','on','String',rbValuesC);
                        set(hScenarioLabel,'Visible','on');
                    elseif ~isempty(strfind(optType,'N'))
                        mValues=mValuesN;
                        set(hCheckBoxHeatmap,'Visible','on');
                        set(hEditControllerIDs,'String',num2str(nk(1,:)));
                        set(hXAxisPopupMenu,'String',mValues(:,1));
                        set(hXAxisPopupMenu,'Visible','on');
                        set(hYAxisPopupMenu,'String',mValues(:,1));
                        set(hYAxisPopupMenu,'Visible','on');
                        set(hYAxisPopupMenu,'Value',7);
                        set(hXAxisLabel,'Visible','on');
                        set(hYAxisLabel,'Visible','on');
                        valuex=char(mValues{1,2});
                        valuey=char(mValues{7,2});
                        set(hStatusLabel,'String',sprintf('Current placements: %s considering up to two node failures with k=%d controllers - %d placements',tmstring,k,nksize));
                        set(hResultPopupMenu,'Visible','on','String',pValuesN);
                        set(hResultLabel,'Visible','on');
                        set(hScenarioPopupMenu,'Visible','on','String',rbValuesN);
                        set(hScenarioLabel,'Visible','on');
                    end
                    if strcmp(optType,'N2')
                        set(hStatusLabel,'String',sprintf('Current placements: %s only placements being resilient against up to two node failures: k=%d controllers - %d placements',tmstring,k,nksize));
                    end
                    set(hMainFigure,'Name',sprintf('POCO - %s',file));
                    plotFigures;
                    set(hSavePlacementsMenuitem,'Enable','off');
                    set(hEditControllerIDs,'Visible','on');
                    set(hEditControllerFailureIDs,'Visible','on');
                    set(hEditNodeFailureIDs,'Visible','on');
                    set(hLabelControllerIDs,'Visible','on');
                    set(hLabelControllerFailureIDs,'Visible','on');
                    set(hLabelNodeFailureIDs,'Visible','on');
                    set(hCheckBoxDistNC,'Visible','on');
                    set(hCheckBoxBalance,'Visible','on');
                    set(hCheckBoxDistCC,'Visible','on');
                    set(hMainFigure,'Pointer','arrow');
                    set(hStartPlanetlabPlotLoopMenuitem,'Enable','on');
                    set(hStopPlanetlabPlotLoopMenuitem,'Enable','on');
                    set(hStartPlanetlabCalcLoopMenuitem,'Enable','on');
                    set(hStopPlanetlabCalcLoopMenuitem,'Enable','on');
                end
            else
                return;
            end
        end
    end


    function [solution,nk,optType,active_k,optTm]=loadPlacements(file)
        load(file, '-mat');
        if ~exist('solution','var') || ~exist('nk','var')|| ~exist('optType','var')|| ~exist('active_k','var') || ~exist('optTm','var')
            errordlg('The selected file is not a valid placements file.','File Error');
            solution=[];
            nk=[];
            optType='';
            active_k=0;
            optTm=0;
        end
    end

%----------------------------------------------------------------------
% Saves the current placements as .placements.mat file
    function savePlacementsCallback(hObject, eventdata)
        if ~isempty(solution)
            file = uiputfile('*.placements.mat');
            savePlacements(file);
            set(hMainFigure,'Name',sprintf('POCO - %s',file));
        end
    end


    function savePlacements(file)
        save(file, '-mat','solution','nk','optType','active_k','optTm');
    end


%----------------------------------------------------------------------
% Disables / enables the other plot options if controller-less nodes
% heatmap is selected / deselected, and plots the heatmap
    function heatmapCheckCallback(hObject,eventdata)
        heatmapCheck;
        plotFigures;
        updateCheckBoxMenu;
    end

    function heatmapCheckCallbackMenu(hObject,eventdata)
        updateCheckBoxFromMenu(5);
        heatmapCheck;
        plotFigures;
    end

    function heatmapCheck
        if ~get(hCheckBoxHeatmap,'Value')
            set(hEditControllerFailureIDs,'Enable','on');
            set(hEditNodeFailureIDs,'Enable','on');
            set(hLabelControllerFailureIDs,'Enable','on');
            set(hLabelNodeFailureIDs,'Enable','on');
        else
            set(hEditControllerFailureIDs,'Enable','off');
            set(hEditNodeFailureIDs,'Enable','off');
            set(hLabelControllerFailureIDs,'Enable','off');
            set(hLabelNodeFailureIDs,'Enable','off');
        end

    end


%----------------------------------------------------------------------
% Includes/excludues the node weights for the placement calculations
% according to the selection
    function toggleNodeWeights(hObject, eventdata)
        if strcmp(get(hNodeWeightsMenuItem,'Checked'),'off')
            set(hNodeWeightsMenuItem,'Checked','on');
            tmbool=1;
        else
            set(hNodeWeightsMenuItem,'Checked','off');
            tmbool=0;
        end

    end


%----------------------------------------------------------------------
% Loads a topology from a .topo.mat file
    function [topology,coordinates,tm,nodenames,distanceMatrix]=loadMatFile(filename)
        if exist(filename,'file')
            load(filename);
        end
        if ~exist('topology','var') || ~exist('coordinates','var')
            errordlg('The selected file is not a topology file.','File Error');
            topology=[];
            coordinates=[];
            tm=[];
            distanceMatrix=[];
        end
        if ~exist('tm','var')
            tm=[];
        end
        if ~exist('nodenames','var')
            nodenames=[];
        end
        if ~exist('distanceMatrix','var')
            distanceMatrix=allToAllShortestPathMatrix(topology);
        end
    end


%----------------------------------------------------------------------
% Plots the topology
    function plotted=plotAxes1(colorscheme)
        plotted=0;
        if ~plcTopo
            axes(hPlotAxes1);
            cla
        end
        set(hEditMenu,'Enable','off');
        plotids=get(hCheckBoxIDs,'Value');
        plotdistnc=get(hCheckBoxDistNC,'Value');
        plotbal=get(hCheckBoxBalance,'Value');
        plotdistcc=get(hCheckBoxDistCC,'Value');
        plotheatmap=get(hCheckBoxHeatmap,'Value');
        plottm=get(hCheckBoxTM,'Value');

        if isempty(regexp(get(hEditControllerIDs,'String'),'[^0-9 \:]'))
            controllerplaces=str2num(get(hEditControllerIDs,'String'));
            if ~isempty(find(controllerplaces>length(topology)))
                uiwait(errordlg('Some of the input IDs are not invalid.','Invalid input'));
                controllerplaces=controllerplaces(find(controllerplaces<length(topology)));
                set(hEditControllerIDs,'String',strrep(num2str(controllerplaces),'  ', ' '));
            end
        else
            controllerplaces=[];
            set(hEditControllerIDs,'String','');
            uiwait(errordlg('The input IDs are not valid','Invalid input'));
        end
        if isempty(regexp(get(hEditControllerFailureIDs,'String'),'[^0-9 \:]'))
            controllersfailed=str2num(get(hEditControllerFailureIDs,'String'));
            if ~isempty(find(controllersfailed>length(topology)))
                uiwait(errordlg('Some of the input IDs are not invalid.','Invalid input'));
                controllersfailed=controllersfailed(find(controllersfailed<length(topology)));
                set(hEditControllerFailureIDs,'String',strrep(num2str(controllersfailed),'  ', ' '));
            end
        else
            controllersfailed = [];
            set(hEditControllerFailureIDs,'String','');
            uiwait(errordlg('The input IDs are not valid','Invalid input'));
        end
        if isempty(regexp(get(hEditNodeFailureIDs,'String'),'[^0-9 \:]'))
            nodesfailed=str2num(get(hEditNodeFailureIDs,'String'));
            if ~isempty(find(nodesfailed>length(topology)))
                uiwait(errordlg('Some of the input IDs are not invalid.','Invalid input'));
                nodesfailed=nodesfailed(find(nodesfailed<length(topology)));
                set(hEditNodeFailureIDs,'String',strrep(num2str(nodesfailed),'  ',' '));
            end
        else
            nodesfailed=[];
            set(hEditNodeFailureIDs,'String','');
            uiwait(errordlg('The input IDs are not valid','Invalid input'));
        end

        showIds = 'off';
        showNodeToControllerLatency = 'off';
        showControllerToControllerLatency = 'off';
        showControllerlessHeatmap = 'off';
        showControllerImbalance = 'off';
        showNodeWeights = 'off';

        if plotids
            showIds = 'on';
        end

        if plotdistnc
            showNodeToControllerLatency = 'on';
        end

        if plotbal
            showControllerImbalance = 'on';
        end

        if plotdistcc
            showControllerToControllerLatency = 'on';
        end

        if plotheatmap
            showControllerlessHeatmap = 'on';
        end

        if plottm && ~isempty(tm)
            showNodeWeights = 'on';
        end

        if isempty(tm)
            tm=ones(1,size(topology,1));
        end
        position = get(hMainFigure,'Position');

        if isempty(tmPLC)
            tmPLC=ones(1,size(topologyPLC,1));
        end
        if isempty(topology)
        else
            if (plotdistnc+plotdistcc+plotbal)>0 && isempty(controllerplaces)
            end
            weights = log(1+tm(tmindex,:)/max(tm(tmindex,:))*10)';
            if exist('colorscheme','var')
                distanceMatrixTmp(distanceMatrix==inf)=nan;
                referenceDiameter=nanmax(nanmax(distanceMatrixTmp));
                plotTopology(topology,coordinates,controllerplaces,'FailedControllers',controllersfailed,'FailedNodes',nodesfailed,'Parent',hPlotAxes1,'nodeWeights',weights,'ReferenceDiameter',referenceDiameter,'Colors',colorscheme,'ShowIds',showIds,'ShowNodeToControllerLatency',showNodeToControllerLatency,'ShowControllerToControllerLatency',showControllerToControllerLatency,'ShowControllerlessHeatmap',showControllerlessHeatmap,'ShowControllerImbalance',showControllerImbalance,'ShowNodeWeights',showNodeWeights,'Markers', 'o','Position',position);
            else
                if ~plcTopo
                    plotTopology(topology,coordinates,controllerplaces,'FailedControllers',controllersfailed,'FailedNodes',nodesfailed,'Parent',hPlotAxes1,'nodeWeights',weights,'ShowIds',showIds,'ShowNodeToControllerLatency',showNodeToControllerLatency,'ShowControllerToControllerLatency',showControllerToControllerLatency,'ShowControllerlessHeatmap',showControllerlessHeatmap,'ShowControllerImbalance',showControllerImbalance,'ShowNodeWeights',showNodeWeights,'Markers', 'o','Position',position,'DistanceMatrix',distanceMatrix);
                else
                    plotTopologyPLC(topology,coordinates,controllerplaces,'FailedControllers',controllersfailed,'FailedNodes',nodesfailed,'Parent',hMainFigure,'CurrentAxis',hPlotAxes1,'nodeWeights',log(1+tm(tmindex,:)/max(tm(tmindex,:))*10),'ReferenceDiameter',1,'ShowMap','on','ShowIds',showIds,'ShowNodeToControllerLatency',showNodeToControllerLatency,'ShowControllerToControllerLatency',showControllerToControllerLatency,'ShowControllerlessHeatmap',showControllerlessHeatmap,'ShowControllerImbalance',showControllerImbalance,'ShowNodeWeights',showNodeWeights,'Markers', 'o','Position',position);
                end
            end
            plotted=1;
        end

    end


%----------------------------------------------------------------------
% Plots the Planetlab live view statistics
    function plotted=plotAxesPLC
        plotted=0;
        plotids=get(hCheckBoxIDs,'Value');
        plotdistnc=get(hCheckBoxDistNC,'Value');
        plotbal=get(hCheckBoxBalance,'Value');
        plotdistcc=get(hCheckBoxDistCC,'Value');
        plotheatmap=get(hCheckBoxHeatmap,'Value');
        plottm=get(hCheckBoxTM,'Value');

        controllerplaces=controllerplacesPLC;

        controllersfailed=failedControllersPLC;

        nodesfailed=failedNodesPLC;

        showIds = 'off';
        showNodeToControllerLatency = 'off';
        showControllerToControllerLatency = 'off';
        showControllerlessHeatmap = 'off';
        showControllerImbalance = 'off';
        showNodeWeights = 'off';

        if plotids
            showIds = 'on';
        end

        if plotdistnc
            showNodeToControllerLatency = 'on';
        end

        if plotbal
            showControllerImbalance = 'on';
        end

        if plotdistcc
            showControllerToControllerLatency = 'on';
        end

        if plotheatmap
            showControllerlessHeatmap = 'on';
        end

        if plottm && ~isempty(tm)
            showNodeWeights = 'on';
        end

        if isempty(tmPLC)
            tmPLC=ones(1,size(topologyPLC,1));
        end

        if ~isempty(topologyPLC)
            [tmvals,latencyvals,mycolors,meanlatencyvals,assignmentsNew]=plotTopologyPLC(topologyPLC,coordinatesPLC,controllerplaces,'FailedControllers',controllersfailed,'FailedNodes',nodesfailed,'Parent',hFigurePLC,'CurrentAxis',hPlotAxesPLC,'nodeWeights',tmPLC(tmindex,:),'ReferenceDiameter',1,'ShowMap','on','ShowIds',showIds,'ShowNodeToControllerLatency',showNodeToControllerLatency,'ShowControllerToControllerLatency',showControllerToControllerLatency,'ShowControllerlessHeatmap',showControllerlessHeatmap,'ShowControllerImbalance',showControllerImbalance,'ShowNodeWeights',showNodeWeights,'Markers', 'o');
            set(hPlotAxesPLC,'Position',[0.03 0.57 0.94 0.43])
            timeArray(end+1)=now;
            avgLatencyArray(end+1)=nanmean(latencyvals);
            avgTMArray(end+1)=nansum(tmvals);
            imbalance(end+1)=nanmax(tmvals)-nanmin(tmvals);
            if isempty(assignments)
                changes(end+1)=0;
            else
                changes(end+1)=sum(assignments~=assignmentsNew);
            end
            assignments=assignmentsNew;
            maxnumvals=60*15; % 60 per minute, 60*60 per hour, save last 12 hours
            if length(avgLatencyArray)>maxnumvals
                avgLatencyArray=avgLatencyArray((end-maxnumvals):end);
            end
            if length(avgTMArray)>maxnumvals
                avgTMArray=avgTMArray((end-maxnumvals):end);
            end
            if length(changes)>maxnumvals
                changes=changes((end-maxnumvals):end);
            end
            if length(imbalance)>maxnumvals
                imbalance=imbalance((end-maxnumvals):end);
            end
            if length(timeArray)>maxnumvals
                timeArray=timeArray((end-maxnumvals):end);
            end
            myidx=floor(currPlacement);
            if ~isempty(maxarrayPLC)
                [tildevar,bestmaxidx]=min(maxmaxarrayPLC);
                [tildevar,currentmaxidx]=min(maxarrayPLC);
                currentmaxidxHist(end+1)=currentmaxidx;
                if length(currentmaxidxHist)>10
                    currentmaxidxHist=currentmaxidxHist((end-10):end);
                end
            else
                bestmaxidx=[];
            end
            plotBarsPLC(timeArray,tmvals,nodenamesPLC(controllerplacesPLC),latencyvals,changes,imbalance,mycolors,hFigurePLC,hPlotAxesPLCbar1,hPlotAxesPLCbar2,hPlotAxesPLCbar2b,hPlotAxesPLCbar3,hPlotAxesPLCbar3b,meanlatencyvals,avgLatencyArray,avgTMArray,changesPLC,sumbalancearrayPLC/plcCounter,myidx,newPLCCalc,bestmaxidx,currentmaxidxHist,controllerplacesPLC)
            if newPLCCalc
                newPLCCalc=0; % do not plot the pareto plot everytime, but only when changes appeared
            end
            set(0,'CurrentFigure',hMainFigure)
            plotted=1;
        end
    end


%----------------------------------------------------------------------
% Plots the solution space for the values valuex and valuey, including the
% pareto-optimal values.
    function plotAxes2
        if ~isempty(solution) && ~isempty(valuex)
            set(hPlotAxes2,'Visible','on');
            axes(hPlotAxes2);
            cla
            myidx=floor(currPlacement);
            if ~plcTopo
                [paretoidx textXaxis textYaxis]=plotPareto(solution.(valuex),solution.(valuey),'ShowSelectedidx',myidx,'Parent',hPlotAxes2);
            else
                paretoidx=plotParetoPLC(solution.(valuex),solution.(valuey),'ShowSelectedidx',myidx,'Parent',hPlotAxes2);
            end
            xlabel(char(mValues(get(hXAxisPopupMenu,'Value'),3)));
            ylabel(char(mValues(get(hYAxisPopupMenu,'Value'),3)));
            controllerplaces=str2num(get(hEditControllerIDs,'String'));
            if ~isempty(controllerplaces) && (length(controllerplaces)~=size(nk,2) || min(sort(controllerplaces)==nk(myidx,:))==0)
                if ~tmbool % tm not activated
                    tmtemp=ones(1,size(topology,1));
                else
                    tmtemp=tm(tmindex,:);
                end
                k=active_k;
                if ~isempty(strfind(optType,'F'))
                    if ~plcTopo
                        solutionTemp=evaluateSingleInstance(distanceMatrix,k,tmtemp,1:length(controllerplaces),controllerplaces);
                    else
                        solutionTemp=evaluateSingleInstance(allToAllShortestPathMatrix(topology),k,tmtemp,1:length(controllerplaces),controllerplaces);
                    end
                elseif ~isempty(strfind(optType,'C'))
                    solutionTemp=evaluateControllerFailure(topology,k,tmtemp,plcTopo,controllerplaces);
                elseif ~isempty(strfind(optType,'N'))
                    solutionTemp=evaluateNodeFailure(topology,k,tmtemp,2,controllerplaces);
                end
                mycolors=hsv(5);
                plot(solutionTemp.(valuex),solutionTemp.(valuey),'go','MarkerSize',9,'MarkerFaceColor',mycolors(3,:),'Color',darken(mycolors(3,:)),'LineWidth',2);
            end
        end
    end


%----------------------------------------------------------------------
% Calls the plotFiguresToggle function
    function plotFigures
        plotFiguresToggle(1);
    end


%----------------------------------------------------------------------
% Updates the checkbox-menu according to the checkboxes
    function updateCheckBoxMenu
        checkValue={'off','on'};
        set(hCheckBoxMenuBalance,'Visible',get(hCheckBoxBalance,'Visible'));
        set(hCheckBoxMenuDistCC,'Visible',get(hCheckBoxDistCC,'Visible'));
        set(hCheckBoxMenuDistNC,'Visible',get(hCheckBoxDistNC,'Visible'));
        set(hCheckBoxMenuHeatmap,'Visible',get(hCheckBoxHeatmap,'Visible'));
        set(hCheckBoxMenuIDs,'Visible',get(hCheckBoxIDs,'Visible'));
        set(hCheckBoxMenuTM,'Visible',get(hCheckBoxTM,'Visible'));
        set(hCheckBoxMenuBalance,'Checked',checkValue{get(hCheckBoxBalance,'Value')+1});
        set(hCheckBoxMenuDistCC,'Checked',checkValue{get(hCheckBoxDistCC,'Value')+1});
        set(hCheckBoxMenuDistNC,'Checked',checkValue{get(hCheckBoxDistNC,'Value')+1});
        set(hCheckBoxMenuHeatmap,'Checked',checkValue{get(hCheckBoxHeatmap,'Value')+1});
        set(hCheckBoxMenuIDs,'Checked',checkValue{get(hCheckBoxIDs,'Value')+1});
        set(hCheckBoxMenuTM,'Checked',checkValue{get(hCheckBoxTM,'Value')+1});
    end


%----------------------------------------------------------------------
% Updates the checkboxes according to the checkbox-menu
    function updateCheckBoxFromMenu(k)
        switch k
            case 1
                set(hCheckBoxDistNC,'Value',~get(hCheckBoxDistNC,'Value'));
            case 2
                set(hCheckBoxBalance,'Value',~get(hCheckBoxBalance,'Value'));
            case 3
                set(hCheckBoxDistCC,'Value',~get(hCheckBoxDistCC,'Value'));
            case 4
                set(hCheckBoxIDs,'Value',~get(hCheckBoxIDs,'Value'));
            case 5
                set(hCheckBoxHeatmap,'Value',~get(hCheckBoxHeatmap,'Value'));
            case 6
                set(hCheckBoxTM,'Value',~get(hCheckBoxTM,'Value'));
            case 7
                set(hCheckBoxDistNC,'Value',1);
                set(hCheckBoxBalance,'Value',0);
                set(hCheckBoxDistCC,'Value',0);
                set(hCheckBoxHeatmap,'Value',0);
            case 8
                set(hCheckBoxDistNC,'Value',0);
                set(hCheckBoxBalance,'Value',1);
                set(hCheckBoxDistCC,'Value',0);
                set(hCheckBoxHeatmap,'Value',0);
            case 9
                set(hCheckBoxDistNC,'Value',0);
                set(hCheckBoxBalance,'Value',0);
                set(hCheckBoxDistCC,'Value',1);
                set(hCheckBoxHeatmap,'Value',0);
            case 0
                set(hCheckBoxDistNC,'Value',0);
                set(hCheckBoxBalance,'Value',0);
                set(hCheckBoxDistCC,'Value',0);
                set(hCheckBoxHeatmap,'Value',1);
        end
        drawnow;
        updateCheckBoxMenu;
    end


%----------------------------------------------------------------------
% Calls the functions to plot the topology and the pareto-plot, and enables
% diveres functions which should only be accessable after loading a
% topology
    function plotFiguresToggle(savePlot)
        set(hMainFigure,'Pointer','watch');
        drawnow;
        plotted=plotAxes1;
        plotAxes2;
        if savePlot&&plotted
            savePlotSettings;
        end
        set(hEditMenu,'Enable','on');
        set(hViewMenu,'Enable','on');
        set(hResetAllMenu,'Enable','on');
        set(hSaveAsMenu,'Enable','on');
        set(hExportMenu,'Enable','on');
        set(hImportMenu,'Enable','on');
        set(hMainFigure,'Pointer','arrow');
        set(hPlacementsMenu,'Enable','on');
        set(hNodeOptionsMenu,'Enable','off');
        if plcTopo
            if ishandle(hFigurePLC)
                set(hFigurePLC,'Visible','on');
            else
                openPLFig;
                set(hFigurePLC,'Visible','on');
            end
            set(hNMenuitem.base,'Visible','off');
        else
            if ishandle(hFigurePLC)
                set(hFigurePLC,'Visible','off');
            end
            set(hNMenuitem.base,'Visible','on');
            fixAxes2PlotTextColor;
        end
    end


%----------------------------------------------------------------------
% Undoes the last plot
    function undoPlot(hObject,eventdata)
        if last20plotsidx>1
            set(hRedoMenuitem,'Enable','on');
            last20plotsidx=last20plotsidx-1;
            restorePlotSettings;
            plotFiguresToggle(0);
        end
        if last20plotsidx<2
            set(hUndoMenuitem,'Enable','off');
        end
    end

%----------------------------------------------------------------------
% Redoes the last plot
    function redoPlot(hObject,eventdata)
        if last20plotsidx<length(last20plots)
            set(hUndoMenuitem,'Enable','on');
            last20plotsidx=last20plotsidx+1;
            restorePlotSettings;
            plotFiguresToggle(0);
        end
        if last20plotsidx==length(last20plots)
            set(hRedoMenuitem,'Enable','off');
        end
    end


%----------------------------------------------------------------------
% Duplicates the topology plot and shows it in an extra figure
    function duplicatePlot(hObject,eventdata)
        pnew=figure('MenuBar','none','Toolbar','none','Resize','on','NumberTitle','off');
        hnew=copyobj(hPlotAxes1,pnew);
        set(hnew,'Units', 'normalized','Position',[0.05 0.05 0.9 0.9]);
        set(pnew,'Position',[0 0 600 450],'Color','w');
    end


%----------------------------------------------------------------------
% Saves the topology plot as an image file
    function exportPlotCallback(hObject,eventdata,tag)
        pnew=figure('MenuBar','none','Toolbar','none','Resize','on','NumberTitle','off');
        hnew=copyobj(hPlotAxes1,pnew);
        set(hnew,'Units', 'normalized','Position',[0.05 0.05 0.9 0.9]);
        set(pnew,'Position',[0 0 1024 768],'Color','w');
        plotpattern(1)=get(hCheckBoxDistNC,'Value');
        plotpattern(2)=get(hCheckBoxBalance,'Value');
        plotpattern(3)=get(hCheckBoxDistCC,'Value');
        plotpattern(4)=get(hCheckBoxIDs,'Value');
        plotpattern(5)=get(hCheckBoxHeatmap,'Value');
        plotpattern(6)=get(hCheckBoxTM,'Value');

        controllerplaces=get(hEditControllerIDs,'String');
        controllersfailed=get(hEditControllerFailureIDs,'String');
        nodesfailed=get(hEditNodeFailureIDs,'String');
        if ~isempty(tag)
            default = [sprintf('V%d_E%d_(%s)_(%s)_(%s)_(%s)_(%s)',size(topology,1),length(find(topology~=inf & topology>0)),...
                regexprep(controllerplaces,'\s+','-'),regexprep(controllersfailed,'\s+','-'),...
                regexprep(nodesfailed,'\s+','-'),...
                regexprep(num2str(plotpattern),'\s','')), '_' tag];
        else
            default = [sprintf('V%d_E%d_(%s)_(%s)_(%s)_(%s)',size(topology,1),length(find(topology~=inf & topology>0)),...
                regexprep(controllerplaces,'\s+','-'),regexprep(controllersfailed,'\s+','-'),...
                regexprep(nodesfailed,'\s+','-'),...
                regexprep(num2str(plotpattern),'\s',''))];
        end
        [filename, pathname] = uiputfile({'*.jpg','JPEG (*.jpg)';'*.png','Portable Network Graphics (*.png)';'*.pdf','Portable Document Format (*.pdf)';'*.emf','Windows Enhanced Metafile (*.emf)';},'Please choose a filename',default);
        file = fullfile(pathname, filename);
        if ~isequal(filename, 0)
            if ~isempty(strfind(filename,'.pdf'))
                set(findall(pnew,'type','line'),'LineSmoothing','off');
            end
            exportPlot(pnew,file);
        end

        close(pnew);
    end

    function exportPlot(plot,file)
        saveas(plot,file);
    end
%----------------------------------------------------------------------
% Sets a selected node as controller
    function toggleController(hObject,eventdata)
        controllerplaces=str2num(get(hEditControllerIDs,'String'));
        if isempty(selectednode)
            inputFig = figure('MenuBar','none','Toolbar','none','HandleVisibility','on','Name', 'Toggle controller','NumberTitle','off','Position', [(screensize(3)/2 - 200), (screensize(4)/2 - 300), 400, 200],'Resize','on','Color','w');
            hLabelControllerIDs = uicontrol('Parent',inputFig,'Units','pixel','HorizontalAlignment','right','Position',[0 150 200 50],...
                'String','Controller IDs','Style','text','BackgroundColor',get(hMainFigure,'Color'),'Visible','on','FontWeight','bold');
            hEditControllerFailureIDs = uicontrol('Parent',inputFig,'Units','pixel','HorizontalAlignment','left','Position',[200 150 200 50],...
                'Style','edit','BackgroundColor','w','HandleVisibility','on','Visible','on','Callback',@plotFiguresCallback);
        end
        if ~isempty(find(controllerplaces==selectednode))
            if matlabVersion < 2013
                controllerplaces=setdiff(controllerplaces,selectednode);
            else
                controllerplaces=setdiff(controllerplaces,selectednode,'legacy');
            end
        else
            controllerplaces=sort([controllerplaces selectednode]);
        end
        set(hEditControllerIDs,'String',num2str(controllerplaces));
        % Synchronously update controller failures
        controllerfailureplaces=str2num(get(hEditControllerFailureIDs,'String'));
        if matlabVersion < 2013
            controllerfailureplaces=intersect(controllerfailureplaces,controllerplaces);
        else
            controllerfailureplaces=intersect(controllerfailureplaces,controllerplaces,'legacy');
        end
        set(hEditControllerFailureIDs,'String',num2str(controllerfailureplaces));
        plotFigures;
        selectednode=[];
    end


%----------------------------------------------------------------------
% Sets a selected controller as failed controller
    function toggleControllerFailure(hObject,eventdata)
        controllerplaces=str2num(get(hEditControllerIDs,'String'));
        controllerfailureplaces=str2num(get(hEditControllerFailureIDs,'String'));
        if ~isempty(find(controllerfailureplaces==selectednode))
            if matlabVersion < 2013
                controllerfailureplaces=setdiff(controllerfailureplaces,selectednode);
            else
                controllerfailureplaces=setdiff(controllerfailureplaces,selectednode,'legacy');
            end
        else
            controllerfailureplaces=sort([controllerfailureplaces selectednode]);
        end
        if matlabVersion < 2013
            controllerfailureplaces=intersect(controllerfailureplaces,controllerplaces);
        else
            controllerfailureplaces=intersect(controllerfailureplaces,controllerplaces,'legacy');
        end
        set(hEditControllerFailureIDs,'String',num2str(controllerfailureplaces));
        plotFigures;
    end


%----------------------------------------------------------------------
% Resets the GUI
    function resetAllHandle(hObject,eventdata)
        reset;
        plotFigures;
        reset;
    end


%----------------------------------------------------------------------
% Clears the input fields for controller, controller failures and node
% failures
    function resetFieldsHandle(hObject,eventdata)
        set(hEditControllerIDs,'String','');
        set(hEditControllerFailureIDs,'String','');
        set(hEditNodeFailureIDs,'String','');
        plotFigures;
    end


%----------------------------------------------------------------------
% Sets a selected node as failed node
    function toggleNodeFailure(hObject,eventdata)
        nodefailureplaces=str2num(get(hEditNodeFailureIDs,'String'));
        if ~isempty(find(nodefailureplaces==selectednode))
            if matlabVersion < 2013
                nodefailureplaces=setdiff(nodefailureplaces,selectednode);
            else
                nodefailureplaces=setdiff(nodefailureplaces,selectednode,'legacy');
            end
        else
            nodefailureplaces=sort([nodefailureplaces selectednode]);
        end
        set(hEditNodeFailureIDs,'String',num2str(nodefailureplaces));
        plotFigures;
    end


%----------------------------------------------------------------------
% Stores the current plot settings
    function savePlotSettings
        if isempty(last20plots)
            last20plots=struct;
            iz=1;
        else
            iz=last20plotsidx+1;
            % New plot overrides old redo options
            last20plots=last20plots(1:iz-1);
        end
        set(hRedoMenuitem,'Enable','off');
        if iz>1
            set(hUndoMenuitem,'Enable','on');
        end

        last20plots(iz).stp=storePlot;

        if length(last20plots)>20
            last20plots=last20plots(end-20:end);
        end
        last20plotsidx=length(last20plots);
    end

    function stp=storePlot
        stp.hCheckBoxIDs=get(hCheckBoxIDs,'Value');
        stp.hCheckBoxDistNC=get(hCheckBoxDistNC,'Value');
        stp.hCheckBoxBalance=get(hCheckBoxBalance,'Value');
        stp.hCheckBoxDistCC=get(hCheckBoxDistCC,'Value');
        stp.hCheckBoxHeatmap=get(hCheckBoxHeatmap,'Value');
        stp.hCheckBoxTM=get(hCheckBoxTM,'Value');

        stp.hEditControllerIDs=get(hEditControllerIDs,'String');
        stp.hEditControllerFailureIDs=get(hEditControllerFailureIDs,'String');
        stp.hEditNodeFailureIDs=get(hEditNodeFailureIDs,'String');

        stp.hCurrPlacement=currPlacement;
        stp.hScenarioPopupMenu=get(hScenarioPopupMenu,'Value');
        stp.hResultPopupMenu=get(hResultPopupMenu,'Value');

        stp.hXAxisPopupMenu=get(hXAxisPopupMenu,'Value');
        stp.hYAxisPopupMenu=get(hYAxisPopupMenu,'Value');
    end


%----------------------------------------------------------------------
% Loads the stored plot settings
    function restorePlotSettings
        if ~isempty(last20plots)
            iz=last20plotsidx;
            loadPlot(last20plots(iz).stp);
        end
    end

    function loadPlot(stp)
        set(hCheckBoxIDs,'Value',stp.hCheckBoxIDs);
        set(hCheckBoxDistNC,'Value',stp.hCheckBoxDistNC);
        set(hCheckBoxBalance,'Value',stp.hCheckBoxBalance);
        set(hCheckBoxDistCC,'Value',stp.hCheckBoxDistCC);
        set(hCheckBoxHeatmap,'Value',stp.hCheckBoxHeatmap);
        heatmapCheck;
        set(hCheckBoxTM,'Value',stp.hCheckBoxTM);

        set(hEditControllerIDs,'String',stp.hEditControllerIDs);
        set(hEditControllerFailureIDs,'String',stp.hEditControllerFailureIDs);
        set(hEditNodeFailureIDs,'String',stp.hEditNodeFailureIDs);

        currPlacement = stp.hCurrPlacement;
        set(hScenarioPopupMenu,'Value',stp.hScenarioPopupMenu);
        set(hResultPopupMenu,'Value',stp.hResultPopupMenu);

        set(hXAxisPopupMenu,'Value',stp.hXAxisPopupMenu);
        set(hYAxisPopupMenu,'Value',stp.hYAxisPopupMenu);
    end


%----------------------------------------------------------------------
% Resets all variables and plots
    function reset
        axes(hPlotAxes1);
        cla;
        axes(hPlotAxes2);
        cla;
        topology=[];
        coordinates=[];
        tm=[];
        solution=[];
        tmbool=0;
        nk=[];
        active_k=0;
        optType='';
        paretoidx=[];
        valuex='';
        valuey='';
        tmindex=1;
        last20plots=[];
        last20plotsidx=1;
        optTm=0;
        nodenames={};
        selectednode=[];
        topology_org=[];
        distanceMatrix=[];
        distanceMatrix_org=[];
        tm_org=[];
        topologyName = '';
        plcTopo = 0;

        topologyPLC=[];
        coordinatesPLC=[];
        tmPLC=[];
        nodenamesPLC={};


        controllerplacesOriginal=[];
        controllernamesOriginal={};
        controllerplacesPLC=[];
        failedControllersPLC=[];
        failedControllersOriginal=[];
        failedControllerNamesOriginal={};
        failedNodesPLC=[];

        timeArray=[];
        avgLatencyArray=[];
        avgTMArray=[];
        changes=[];
        imbalance=[];
        assignments=[];
        maxmaxarrayPLC=[];
        sumuncoveredarrayPLC=[];
        sumbalancearrayPLC=[];
        changesPLC=[];
        balancevalsPLC=[];
        balancevalsPLCNew=[];
        maxarrayPLC=[];
        uncoveredarrayPLC=[];
        balancearrayPLC=[];
        plcCounter=0;
        plcFileCounter=11100;
        newPLCCalc=0;
        currentmaxidxHist=[];
        mValues={};
        currPlacement = 0;
        textXaxis = '';
        textYaxis = '';

        % Variables to save the PLC history
        tmvals=[];
        latencyvals=[];
        myidx='';
        mycolors=[];
        meanlatencyvals=[];
        bestmaxidx='';

        set(hPlacementsMenu,'Enable','off');
        set(hPlotAxes1,'Visible','off');
        set(hPlotAxes2,'Visible','off');
        set(hUndoMenuitem,'Enable','off');
        set(hRedoMenuitem,'Enable','off');
        set(hSaveAsMenu,'Enable','off');
        set(hResetAllMenu,'Enable','off');
        set(hImportMenu,'Enable','off');
        set(hExportMenu,'Enable','off');
        set(hEditMenu,'Enable','off');
        set(hViewMenu,'Enable','off');
        set(hNodeWeightsMenuItem,'Visible','off');
        if ishandle(hFigurePLC)
            delete(hPlotAxesPLC);
            delete(hPlotAxesPLCbar1);
            delete(hPlotAxesPLCbar2);
            delete(hPlotAxesPLCbar2b);
            delete(hPlotAxesPLCbar3);
            delete(hPlotAxesPLCbar3b);
            hPlotAxesPLC = axes('Parent', hFigurePLC,'Units', 'normalized','HandleVisibility','on','Position',[0.03 0.57 0.94 0.43],'Visible','off');
            hPlotAxesPLCbar1 = axes('Parent', hFigurePLC,'Units', 'normalized','HandleVisibility','on','Position',[0.072 0.03 0.9 0.13],'Visible','off');
            hPlotAxesPLCbar2      =   axes('Parent', hFigurePLC,'Units', 'normalized','HandleVisibility','on','Position',[0.07 0.21 0.38 0.13],'Visible','off');
            hPlotAxesPLCbar2b      =   axes('Parent', hFigurePLC,'Units', 'normalized','HandleVisibility','on','Position',[0.57 0.21 0.38 0.13],'Visible','off');
            hPlotAxesPLCbar3     =   axes('Parent', hFigurePLC,'Units', 'normalized','HandleVisibility','on','Position',[0.07 0.39 0.38 0.13],'Visible','off');
            hPlotAxesPLCbar3b     =   axes('Parent', hFigurePLC,'Units', 'normalized','HandleVisibility','on','Position',[0.57 0.39 0.38 0.13],'Visible','off');
        end
        set(hNMenuitem.base,'Enable','on');
        set(hLatenciesMenu,'Visible','on');
        set(hEdgeOptionsMenu,'Visible','on');
        set(hNodeWeightsMenu,'Visible','on');

        set(hStartPlanetlabPlotLoopMenuitem,'Enable','off');
        set(hStopPlanetlabPlotLoopMenuitem,'Enable','off');
        set(hStartPlanetlabCalcLoopMenuitem,'Enable','off');
        set(hStopPlanetlabCalcLoopMenuitem,'Enable','off');
        set(hStartPlanetlabPlotLoopMenuitem,'Visible','off');
        set(hStopPlanetlabPlotLoopMenuitem,'Visible','off');
        set(hStartPlanetlabCalcLoopMenuitem,'Visible','off');
        set(hStopPlanetlabCalcLoopMenuitem,'Visible','off');
        set(hFetchPlanetlabDataMenuitem,'Visible','off');
        set(hInitPLCMenuitem,'Visible','on');
        set(hStopPLCMenuitem,'Visible','off');
        set(hSaveHistPLCMenuitem,'Visible','off');
        set(hLoadHistPLCMenuitem,'Visible','off');
        set(hSaveHistPLCMenuitem,'Enable','off');

        set(hCheckBoxIDs,'Value',1,'Visible','on');
        set(hLabelPlotOptions,'Visible','on');
        set(hCheckBoxTM,'Visible','off','Value',0);

        set(hResultPopupMenu,'Visible','off')
        set(hResultLabel,'Visible','off');


        set(hScenarioPopupMenu,'Visible','off');
        set(hScenarioLabel,'Visible','off');

        set(hXAxisLabel,'Visible','off');
        set(hYAxisLabel,'Visible','off');
        set(hXAxisPopupMenu,'Visible','off');
        set(hYAxisPopupMenu,'Visible','off');
        set(hEditControllerIDs,'String','');
        set(hEditControllerFailureIDs,'String','');
        set(hEditNodeFailureIDs,'String','');

        set(hPlotOptionsMenu,'Enable','off');
        set(hPredefinedViewsMenu,'Enable','off');

        set(hViewMaxLatencyMenuitem,'Visible','on');
        set(hViewImbalanceMenuitem,'Visible','on');
        set(hViewMaxLatencyCCMenuitem,'Visible','on');
        set(hViewControllerlessMenuitem,'Visible','on');
        set(hHierarchicalView1,'Visible','off');
        set(hHierarchicalView2,'Visible','off');
        set(hHierarchicalView3,'Visible','off');
        set(hHierarchicalView4,'Visible','off');
        set(hHierarchicalViewLatStat,'Visible','off');
        set(hHierarchicalViewBalStat,'Visible','off');
        set(hHierarchicalViewLatDyn,'Visible','off');
        set(hHierarchicalViewBalDyn,'Visible','off');
        % Controls should be always visible

        set(hEditControllerIDs,'Visible','on');
        set(hEditControllerFailureIDs,'Visible','on');
        set(hEditNodeFailureIDs,'Visible','on');
        set(hLabelControllerIDs,'Visible','on');
        set(hLabelControllerFailureIDs,'Visible','on');
        set(hLabelNodeFailureIDs,'Visible','on');
        set(hCheckBoxDistNC,'Visible','on','Value',0);
        set(hCheckBoxBalance,'Visible','on','Value',0);
        set(hCheckBoxDistCC,'Visible','on','Value',0);
        set(hCheckBoxHeatmap,'Visible','on','Value',0);

        set(hStatusLabel,'String','Topology loaded - Select placements to continue');
        set(hSavePlacementsMenuitem,'Enable','off');

    end


%----------------------------------------------------------------------
% Data cursor update function
    function txt=datacursorUpdateFcn(hObject, eventdata)
        pos=eventdata.Position;
        myaxes=ancestor(eventdata.Target,'axes','toplevel');
        switch myaxes
            case hPlotAxes1
                if plcTopo
                    [x,y] = mercatorProjection(coordinates(:,1), coordinates(:,2), 2400, 2543);
                    coordinatesPLC=[x y];
                    idxnode=find(coordinatesPLC(:,1)==pos(1) & coordinatesPLC(:,2)==pos(2));
                else
                    idxnode=find(coordinates(:,1)==pos(1) & coordinates(:,2)==pos(2));
                end
                selectednode=idxnode;
                set(hNodeOptionsMenu,'Enable','on');

                % Configure check boxes
                controllerplaces=str2num(get(hEditControllerIDs,'String'));
                controllerfailureplaces=str2num(get(hEditControllerFailureIDs,'String'));
                nodefailureplaces=str2num(get(hEditNodeFailureIDs,'String'));
                if ~isempty(find(controllerplaces==selectednode))
                    set(hToggleControllerItem,'Checked','on');
                else
                    set(hToggleControllerItem,'Checked','off');
                end
                if ~isempty(find(controllerfailureplaces==selectednode))
                    set(hToggleControllerFailureItem,'Checked','on');
                else
                    set(hToggleControllerFailureItem,'Checked','off');
                end
                if ~isempty(find(nodefailureplaces==selectednode))
                    set(hToggleNodeFailureItem,'Checked','on');
                else
                    set(hToggleNodeFailureItem,'Checked','off');
                end

                if exist('nodenames','var') && ~isempty(nodenames)
                    nodename=sprintf('%s',regexprep(nodenames{idxnode},'#',' '));
                else
                    nodename=sprintf('Node %d',idxnode);
                end
                if exist('tm','var') && ~isempty(tm) && ~max(tm(tmindex)==1)
                    popunumberin=sprintf('%.0f',tm(tmindex,idxnode));
                    popunumber='';
                    for i=0:length(popunumberin)-1
                        if i>0 && mod(i,3)==0
                            popunumber=[',' popunumber];
                        end
                        popunumber=[popunumberin(end-i) popunumber];
                    end
                    regexprep(popunumber,'^,','');
                    popustring=sprintf('Weight: %s',popunumber) ;
                else
                    popustring=sprintf('Weight: N/A');
                end
                txt=sprintf('%s\nLongitude:%.2f\nLatitude:%.2f\n%s',nodename,pos(1),pos(2),popustring);

            case hPlotAxes2
                if ~isHierarchic
                    idxhit=find(solution.(valuex)==pos(1) & solution.(valuey)==pos(2));
                    txt=sprintf('Result selected with:\n%s:%.2f\n%s:%.2f\n%d results\nDisplaying in 5 seconds.',mValues{get(hXAxisPopupMenu,'Value'),2},pos(1),mValues{get(hYAxisPopupMenu,'Value'),2},pos(2),length(idxhit));
                    currPlacement = idxhit(1);
                    set(hEditControllerIDs,'String',num2str(nk(idxhit(1),:)));
                    checkScenarioSelection;
                    start(plotTimer);
                else
                    indx =find([solutionAll.(valuex)]==pos(1) & [solutionAll.(valuey)]==pos(2));
                    indyTmp0=indx(1);
                    indyTmp=indx(1);
                    for i=1:length(solutionAll)
                        if indyTmp > length([solutionAll(1:i).(valuex)])
                            indyTmp=indyTmp0-length([solutionAll(1:i).(valuex)]);
                        else
                            tmp=solutionAll(i).nk(indyTmp,:);
                            break;
                        end
                    end
                    idxhit = tmp;
                    currPlacement = find([solutionAll.(valuey)]==pos(2) & [solutionAll.(valuex)]==pos(1),1);
                    txt=sprintf('Result selected with:\n%s:%.2f\n%s:%.2f\n%d results\nDisplaying in 5 seconds.',mValues2{get(hXAxisPopupMenuHierarchical,'Value'),2},pos(1),mValues2{get(hYAxisPopupMenuHierarchical,'Value'),2},pos(2),length(idxhit));
                    nk=idxhit;
                    start(plotTimer2);
                    start(plotParetoTimer)
                    datacursormode 'on';
                end
            case hPlotAxesPLCbar2b
                idxhit=find(changesPLC==pos(1) & sumbalancearrayPLC==(pos(2)*plcCounter));
                txt=sprintf('Result selected with:\nNumber of changes:%.2f\nAverage imbalance:%.2f\n%d results\nDisplaying in 5 seconds.',pos(1),pos(2),length(idxhit));
                currPlacement = idxhit(1);
                set(hEditControllerIDs,'String',num2str(nk(idxhit(1),:)));
                start(plotTimer);
                start(plcCalcNowTimer);
            otherwise
                txt='';
        end
    end


%----------------------------------------------------------------------
% Opens a online help
    function openOnlineHelp(hObject,eventdata)
        if matlabVersion < 2013
            web 'http://www3.informatik.uni-wuerzburg.de/research/projects/saser/poco/';
        else
            web('http://www3.informatik.uni-wuerzburg.de/research/projects/saser/poco/','-browser');
        end
    end
%----------------------------------------------------------------------
% Opens a figure containing information about POCO
    function openAbout(hObject, eventdata)
        hAboutFig = figure('MenuBar','none','Toolbar','none','HandleVisibility','on','Name', 'About','NumberTitle','off','Position', [(screensize(3)/2 - 250), (screensize(4)/2 - 300), 500, 600],'Resize','of','Color','w');
        imgsrc = strcat('file:/',pwd,'/images/pocologocollage.png');
        text = strcat('<html><center><img src="',imgsrc,'" border="0"><br><br><font family="verdana"><span style="font-size:20pt;">POCO: A framework for Pareto-Optimal Resilient Controller Placement</span><br><br>&copy; 2012-2014<br><br>David Hock, Stefan Gei&szlig;ler, Fabian Helmschrott, Steffen Gebert<br><br>Chair of Communication Networks, University of W&uuml;rzburg, Germany<br><br>http://www3.informatik.uni-wuerzburg.de/poco<br>https://github.com/lsinfo3/poco</center></html>');
        je = javax.swing.JEditorPane( 'text/html', text );
        je.setEditable(false);
        [hcomponent, hcontainer] = javacomponent( je, [], hAboutFig );
        set( hcontainer, 'units', 'pixel', 'Position', [0 0 500 600] );
        hCloseButton = uicontrol('Parent',hAboutFig,'Units','pixel','Position',[200 25 100 30],'HandleVisibility','on','Visible','on','String','Ok','Style','pushbutton','HorizontalAlignment','right','Callback',{@closeFig,hAboutFig});
    end


%----------------------------------------------------------------------
% Closes the GUI after asking for permission
    function closeGUI(hObject, eventdata)
        decision = questdlg('Do you really want to close POCO?','Exit POCO','Yes','No','No');
        if strcmp(decision,'Yes')
            if ishandle(hMainFigure)
                delete(hMainFigure);
            end
            if ishandle(hFigurePLC)
                delete(hFigurePLC);
            end
            if ishandle(inputFig)
                delete(inputFig);
            end
        end
    end


    function closePLCFig(hObject, eventdata)
        stop(plcPlotTimer);
        stop(plcCalcTimer);
        dcobj='';
        delete(hFigurePLC);
    end

%----------------------------------------------------------------------
% Creates a new edge between two nodes
    function createEdgeInput(hObject, eventdata)
        inputFig = figure('MenuBar','none','Toolbar','none','HandleVisibility','on','Name', 'Create edge','NumberTitle','off','Position', [(screensize(3)/2 - 150), (screensize(4)/2 - 70), 300, 150],'Resize','on','Color','w');
        hLabelHead = uicontrol('Parent',inputFig,'Units','pixel','HorizontalAlignment','left','Position',[0 100 300 50],...
            'String','Please select the source and the destination for creating an edge between them.','Style','text','BackgroundColor',get(hMainFigure,'Color'),'Visible','on','FontWeight','bold');
        hLabelSourceID = uicontrol('Parent',inputFig,'Units','pixel','HorizontalAlignment','left','Position',[0 80 150 30],...
            'String','Source node ID:','Style','text','BackgroundColor',get(hMainFigure,'Color'),'Visible','on','FontWeight','bold');
        hEditSourceID = uicontrol('Parent',inputFig,'Units','pixel','HorizontalAlignment','left','Position',[150 90 150 20],...
            'Style','edit','BackgroundColor','w','HandleVisibility','on','Visible','on');
        hLabelDestID = uicontrol('Parent',inputFig,'Units','pixel','HorizontalAlignment','left','Position',[0 50 150 30],...
            'String','Destination node ID:','Style','text','BackgroundColor',get(hMainFigure,'Color'),'Visible','on','FontWeight','bold');
        hEditDestID = uicontrol('Parent',inputFig,'Units','pixel','HorizontalAlignment','left','Position',[150 60 150 20],...
            'Style','edit','BackgroundColor','w','HandleVisibility','on','Visible','on');
        hButtonSave = uicontrol('Parent',inputFig,'Units','pixel','Position',[40 10 100 30],'HandleVisibility','on','Visible','on','String','Create edge','Style','pushbutton','HorizontalAlignment','right','Callback',@createEdge);
        hButtonCancel = uicontrol('Parent',inputFig,'Units','pixel','Position',[160 10 100 30],'HandleVisibility','on','Visible','on','String','Cancel','Style','pushbutton','HorizontalAlignment','right','Callback',{@closeFig,inputFig});

        function createEdge(hObject, eventdata)
            if (~isempty(str2num(get(hEditSourceID,'String'))) && ~isempty(str2num(get(hEditDestID,'String'))))
                if (length(str2num(get(hEditSourceID,'String')))== 1 && length(str2num(get(hEditDestID,'String'))) == 1)
                    if (str2num(get(hEditSourceID,'String')) <= length(topology) && str2num(get(hEditDestID,'String')) <= length(topology))
                        source = coordinates(str2num(get(hEditSourceID,'String')),:);
                        dest= coordinates(str2num(get(hEditDestID,'String')),:);
                        if (topology(str2num(get(hEditSourceID,'String')),str2num(get(hEditDestID,'String'))) == Inf)
                            dist = distFrom(source,dest);
                            topology(str2num(get(hEditSourceID,'String')),str2num(get(hEditDestID,'String'))) = dist;
                            topology(str2num(get(hEditDestID,'String')),str2num(get(hEditSourceID,'String'))) = dist;
                            distanceMatrix=allToAllShortestPathMatrix(topology);
                            updateCheckBoxMenu;
                            plotFigures;
                            close(inputFig);
                        else
                            errordlg('The selected edge does already exist.','Error! Edge already exists');
                        end
                    else
                        errordlg('At least one of the selected nodes does not exist.','Error! Node does not exist');
                    end
                else
                    errordlg('Too many IDs! An edge has only one source and one destination.','Error! Too many nodes');
                end
            end
        end
    end


%----------------------------------------------------------------------
% Deletes a edge between two nodes
    function deleteEdgeInput(hObject, eventdata)
        inputFig = figure('MenuBar','none','Toolbar','none','HandleVisibility','on','Name', 'Delete edge','NumberTitle','off','Position', [(screensize(3)/2 - 150), (screensize(4)/2 - 70), 300, 150],'Resize','on','Color','w');
        hLabelHead = uicontrol('Parent',inputFig,'Units','pixel','HorizontalAlignment','left','Position',[0 100 300 50],...
            'String','Please select the source and the destination for deleting the edge between them.','Style','text','BackgroundColor',get(hMainFigure,'Color'),'Visible','on','FontWeight','bold');
        hLabelSourceID = uicontrol('Parent',inputFig,'Units','pixel','HorizontalAlignment','left','Position',[0 80 150 30],...
            'String','Source node ID:','Style','text','BackgroundColor',get(hMainFigure,'Color'),'Visible','on','FontWeight','bold');
        hEditSourceID = uicontrol('Parent',inputFig,'Units','pixel','HorizontalAlignment','left','Position',[150 90 150 20],...
            'Style','edit','BackgroundColor','w','HandleVisibility','on','Visible','on');
        hLabelDestID = uicontrol('Parent',inputFig,'Units','pixel','HorizontalAlignment','left','Position',[0 50 150 30],...
            'String','Destination node ID:','Style','text','BackgroundColor',get(hMainFigure,'Color'),'Visible','on','FontWeight','bold');
        hEditDestID = uicontrol('Parent',inputFig,'Units','pixel','HorizontalAlignment','left','Position',[150 60 150 20],...
            'Style','edit','BackgroundColor','w','HandleVisibility','on','Visible','on');
        hButtonSave = uicontrol('Parent',inputFig,'Units','pixel','Position',[40 10 100 30],'HandleVisibility','on','Visible','on','String','Delete edge','Style','pushbutton','HorizontalAlignment','right','Callback',@deleteEdge);
        hButtonCancel = uicontrol('Parent',inputFig,'Units','pixel','Position',[160 10 100 30],'HandleVisibility','on','Visible','on','String','Cancel','Style','pushbutton','HorizontalAlignment','right','Callback',{@closeFig,inputFig});

        function deleteEdge(hObject, eventdata)
            if (~isempty(str2num(get(hEditSourceID,'String'))) && ~isempty(str2num(get(hEditDestID,'String'))))
                if (length(str2num(get(hEditSourceID,'String')))== 1 && length(str2num(get(hEditDestID,'String'))) == 1)
                    if (str2num(get(hEditSourceID,'String')) <= length(topology) && str2num(get(hEditDestID,'String')) <= length(topology))
                        source = coordinates(str2num(get(hEditSourceID,'String')),:);
                        dest= coordinates(str2num(get(hEditDestID,'String')),:);
                        if (topology(str2num(get(hEditSourceID,'String')),str2num(get(hEditDestID,'String'))) ~= Inf)
                            topology(str2num(get(hEditSourceID,'String')),str2num(get(hEditDestID,'String'))) = Inf;
                            topology(str2num(get(hEditDestID,'String')),str2num(get(hEditSourceID,'String'))) = Inf;
                            distanceMatrix=allToAllShortestPathMatrix(topology);
                            updateCheckBoxMenu;
                            plotFigures;
                            close(inputFig);
                        else
                            errordlg('The selected edge does not exist.','Error! Edge does not exist');
                        end
                    else
                        errordlg('The selected edge does not exist.','Error! Edge does not exist');
                    end
                else
                    errordlg('Too many IDs! An edge has only one source and one destination.','Error! Too many nodes');
                end
            end
        end
    end


%----------------------------------------------------------------------
% Resets the edges of the original topology
    function resetEdges(hObject, eventdata)
        topology = topology_org;
        distanceMatrix=distanceMatrix_org;
        updateCheckBoxMenu;
        plotFigures;
    end


%----------------------------------------------------------------------
% Closes a figure
    function closeFig(hObject, eventdata, fig)
        close(fig);
    end


%----------------------------------------------------------------------
% Edits the weight of a node
    function editNodeWeightsInput(hObject, eventdata)
        inputFig = figure('MenuBar','none','Toolbar','none','HandleVisibility','on','Name', 'Edit node weights','NumberTitle','off','Position', [(screensize(3)/2 - 400), (screensize(4)/2 - 300), 800, 600],'Resize','off','Color','w');
        parent = inputFig;
        rows = ceil(length(topology)/4);
        verticalPos = 550;
        if (rows*50 +50) > 600
            hcontainer=uipanel('parent',inputFig,'units','pixels','position',[0 0 800 (rows*50 - 550)],'Bordertype','none','BackgroundColor','w');
            uicontrol('style','slider','parent',inputFig,'position',[781 1 20 600],'Min',0,'max',(rows*50 - 550),'value',(rows*50-550),'callback',{@slider_Callback,rows});
            parent=hcontainer;
        end
        node=1;
        nodeTMs = [];
        for row=1:rows
            horizontalPos = 5;
            for column=1:4
                if node <= length(topology)
                    hLabelNodeTM = uicontrol('Parent',parent,'Units','pixel','HorizontalAlignment','left','Position',[horizontalPos verticalPos 80 30],...
                        'String',strcat('Node ID',num2str(node)),'Style','text','BackgroundColor',get(hMainFigure,'Color'),'Visible','on','FontWeight','bold');
                    hEditNodeTM = uicontrol('Parent',parent,'Units','pixel','HorizontalAlignment','left','Position',[(horizontalPos + 85) (verticalPos + 12) 80 20],...
                        'Style','edit','BackgroundColor','w','HandleVisibility','on','Visible','on','String',tm(node));
                    horizontalPos = horizontalPos + 200;
                    node = node + 1;
                    nodeTMs = [nodeTMs hEditNodeTM];
                end
            end
            verticalPos = verticalPos - 50;
        end
        hButtonSave = uicontrol('Parent',parent,'Units','pixel','Position',[290 (verticalPos+10) 100 30],'HandleVisibility','on','Visible','on','String','Save node weights','Style','pushbutton','HorizontalAlignment','right','Callback',@editNodeWeights);
        hButtonCancel = uicontrol('Parent',parent,'Units','pixel','Position',[410 (verticalPos+10) 100 30],'HandleVisibility','on','Visible','on','String','Cancel','Style','pushbutton','HorizontalAlignment','right','Callback',{@closeFig,inputFig});


        function slider_Callback(hObject,eventdata, rows)
            set(hcontainer,'Position',[0 (rows*50-550)-get(hObject,'Value') 800 (rows*50-550)])
        end

        function editNodeWeights(hObject, eventdata)
            if (size(tm)==size(nodeTMs))
                for node = 1:length(tm)
                    tm(node) = str2num(get(nodeTMs(node),'String'));
                end
                set(hCheckBoxMenuTM,'Visible','on');
                set(hCheckBoxMenuTM,'Checked','on');
                set(hCheckBoxTM,'Visible','on');
                set(hCheckBoxTM,'Value',1);
                updateCheckBoxMenu;
                plotFigures;
                close(inputFig);
            end
        end
    end


%----------------------------------------------------------------------
% Resets the node weights of the original topology
    function resetNodeWeights(hObject, eventdata)
        tm=tm_org;
        updateCheckBoxMenu;
        plotFigures;
    end


%----------------------------------------------------------------------
% Loads node weights from a weights.mat file
    function importNodeWeights(hObject, eventdata)
        [filename, pathname] = uigetfile({'*.weights.mat','Node weights (*.weights.mat)'},'Please select a valid node weights file');
        file = fullfile(pathname, filename);
        if ~isequal(filename, 0)
            newTM = load(file);
            if (isfield(newTM,'tm'))
                if (size(newTM.tm) == size(tm))
                    tm=newTM.tm;
                    set(hCheckBoxMenuTM,'Visible','on');
                    set(hCheckBoxMenuTM,'Checked','on');
                    set(hCheckBoxTM,'Visible','on');
                    set(hCheckBoxTM,'Value',1);
                    updateCheckBoxMenu;
                    plotFigures;
                else
                    errordlg('The selected file does not fit the current topology.','Error! Wrong number of node weights');
                end
            else
                errordlg('The selected file does not fit the current topology.','Error! Wrong number of node weights');
            end
        end
    end


%----------------------------------------------------------------------
% Exports the current topology as a .csv file for Gephi
    function exportGephiCSV (hObject, eventdata)
        fileNameNodes = strcat(topologyName,'_nodes.gephi.csv');
        fidNodes = fopen (fileNameNodes,'w');
        if ~isempty(nodenames)
            fprintf(fidNodes,'Label;Latitude;Longitude;Weights\n');
        else
            fprintf(fidNodes,'Latitude;Longitude;Weights;\n');
        end
        for j=1:length(coordinates)
            if ~isempty(nodenames) && length(nodenames) == length(coordinates)
                fprintf(fidNodes,'%s;%f;%f;%f;\n',nodenames{j},coordinates(j,1),coordinates(j,2),tm(j));
            else
                fprintf(fidNodes,'%f;%f;%f;\n',coordinates(j,1),coordinates(j,2),tm(j));
            end
        end
        fclose(fidNodes);

        fileNameEdges = strcat(topologyName,'_edges.gephi.csv');
        fidEdges = fopen (fileNameEdges,'w');
        fprintf(fidEdges,'Source;Target;Weight;\n');
        [rows,cols] = find(topology~=Inf);
        for j=1:length(rows)
            if cols(j)<rows(j)
                fprintf(fidEdges,'%d;%d;%f;\n',rows(j),cols(j),topology(rows(j),cols(j)));
            end
        end
        fclose(fidEdges);
    end


%----------------------------------------------------------------------
% Opens the planetlab live view figure
    function openPLFig
        hFigurePLC =  figure('MenuBar','none','Toolbar','none','HandleVisibility','on','Name', 'PLC Live View','NumberTitle','off','Position',[0 0 400 300],'Resize','on','Color','w','Visible','off');
        hPlotAxesPLC = axes('Parent', hFigurePLC,'Units', 'normalized','HandleVisibility','on','Position',[0.03 0.57 0.94 0.43],'Visible','off');
        hPlotAxesPLCbar1 = axes('Parent', hFigurePLC,'Units', 'normalized','HandleVisibility','on','Position',[0.072 0.03 0.9 0.13],'Visible','off');
        hPlotAxesPLCbar2 = axes('Parent', hFigurePLC,'Units', 'normalized','HandleVisibility','on','Position',[0.07 0.21 0.38 0.13],'Visible','off');
        hPlotAxesPLCbar2b = axes('Parent', hFigurePLC,'Units', 'normalized','HandleVisibility','on','Position',[0.57 0.21 0.38 0.13],'Visible','off');
        hPlotAxesPLCbar3 = axes('Parent', hFigurePLC,'Units', 'normalized','HandleVisibility','on','Position',[0.07 0.39 0.38 0.13],'Visible','off');
        hPlotAxesPLCbar3b = axes('Parent', hFigurePLC,'Units', 'normalized','HandleVisibility','on','Position',[0.57 0.39 0.38 0.13],'Visible','off');
        dcobjPLC=datacursormode(hFigurePLC);
        set(dcobjPLC,'Enable','on','SnapToDataVertex','on','UpdateFcn', @datacursorUpdateFcn);
    end


%----------------------------------------------------------------------
% Saves the current Planetlab history
    function savePLCHistoryCallback(hObject, eventdata)
        [filename, pathname] = uiputfile({'*.hist.mat','Planetlab history (*.hist.mat)'},'Save Planetlab history as...');
        file = fullfile(pathname, filename);
        if ~isequal(filename, 0)
            savePLCHistory(file);
        end
    end

    function savePLCHistory(file)
        tmp = newPLCCalc;
        newPLCCalc = 1;
        save(file, '-mat','topologyPLC','tmPLC','coordinatesPLC','solution','valuex','valuey','mValues','optType','nk','timeArray','tmvals','nodenamesPLC','controllerplacesPLC','latencyvals','changes','imbalance','mycolors','meanlatencyvals','avgLatencyArray','avgTMArray','changesPLC','sumbalancearrayPLC','plcCounter','myidx','currPlacement','newPLCCalc','bestmaxidx','currentmaxidxHist','maxarrayPLC','maxmaxarrayPLC');
        newPLCCalc = tmp;
    end


%----------------------------------------------------------------------
% Loads a Planetlab history
    function loadPLCHistory(hObject, eventdata)
        [filename, pathname] = uigetfile({'*.hist.mat','Planetlab history (*.hist.mat)'},'Please select a valid Planetlab history file');
        file = fullfile(pathname, filename);
        if ~isequal(filename, 0)
            %            reset;
            if ~isempty(strfind(filename,'.hist.mat'))
                [topologyPLC,tmPLC,coordinatesPLC,solution,valuex,valuey,mValues,optType,nk,timeArray,tmvals,nodenamesPLC,controllerplacesPLC,latencyvals,changes,imbalance,mycolors,meanlatencyvals,avgLatencyArray,avgTMArray,changesPLC,sumbalancearrayPLC,plcCounter,myidx,currPlacement,newPLCCalc,bestmaxidx,currentmaxidxHist,maxarrayPLC,maxmaxarrayPLC]=loadHistFile(file);
            end
        else
            return
        end
        if isempty(topologyPLC)
            errordlg('The selected file is not a valid topology.','File Error');
            return
        end
        set(hResultLabel,'Visible','on');
        if optType == 'F'
            set(hResultPopupMenu,'Visible','on','String',pValuesF);
        else
            set(hResultPopupMenu,'Visible','on','String',pValuesC);
        end
        if optType == 'C'
            set(hScenarioLabel,'Visible','on');
            set(hScenarioPopupMenu,'Visible','on','String',rbValuesC);
        end
        drawnow
        plotAxesPLC;
        fetchPLCdata;
        plotAxes2;
        updateCheckBoxMenu;
    end

    function [topologyPLC,tmPLC,coordinatesPLC,solution,valuex,valuey,mValues,optType,nk,timeArray,tmvals,nodenamesPLC,controllerplacesPLC,latencyvals,changes,imbalance,mycolors,meanlatencyvals,avgLatencyArray,avgTMArray,changesPLC,sumbalancearrayPLC,plcCounter,myidx,currPlacement,newPLCCalc,bestmaxidx,currentmaxidxHist,maxarrayPLC,maxmaxarrayPLC]=loadHistFile(filename)
        if exist(filename,'file')
            load(filename);
        end
        if ~exist('timeArray','var') || ~exist('tmvals','var') || ~exist('nodenamesPLC','var') || ~exist('controllerplacesPLC','var') || ~exist('latencyvals','var') || ~exist('changes','var') || ~exist('imbalance','var') || ~exist('mycolors','var') || ~exist('meanlatencyvals','var') || ~exist('avgLatencyArray','var') || ~exist('avgTMArray','var') || ~exist('changesPLC','var') || ~exist('sumbalancearrayPLC','var') || ~exist('plcCounter','var') || ~exist('myidx','var') || ~exist('newPLCCalc','var') || ~exist('bestmaxidx','var') || ~exist('currentmaxidxHist','var')
            errordlg('The selected file is not a topology file.','File Error');
            timeArray=[];
        end
    end


%----------------------------------------------------------------------
% Changes the theme of the GUI
    function changeThemeCallback(hObject, eventdata, backgroundColor, foregroundColor)
        if strcmp(get(hObject,'Checked'),'off')
            changeTheme(backgroundColor, foregroundColor);
        end
    end

    function changeTheme(backgroundColor, foregroundColor)
        if strcmp(get(hThemesClassicMenuitem,'Checked'),'off')
            checkedClassic = 'on';
            checkedDark = 'off';
            set(hThemesClassicMenuitem, 'Accelerator','');
            set(hThemesDarkMenuitem, 'Accelerator','K');
            set(hPlotAxes2,'Color','w');
            set(get(hPlotAxes2,'XLabel'),'Color','k');
            set(hPlotAxes2,'XColor','k','YColor','k');
            set(hEditControllerIDs,'ForegroundColor',foregroundColor,'BackgroundColor',backgroundColor);
            set(hEditControllerFailureIDs,'ForegroundColor',foregroundColor,'BackgroundColor',backgroundColor);
            set(hEditNodeFailureIDs,'ForegroundColor',foregroundColor,'BackgroundColor',backgroundColor);
            set(hResultPopupMenu,'ForegroundColor',foregroundColor,'BackgroundColor',backgroundColor);
            set(hScenarioPopupMenu,'ForegroundColor',foregroundColor,'BackgroundColor',backgroundColor');
            set(hXAxisPopupMenu,'ForegroundColor',foregroundColor,'BackgroundColor',backgroundColor);
            set(hYAxisPopupMenu,'ForegroundColor',foregroundColor,'BackgroundColor',backgroundColor);
        else
            checkedClassic = 'off';
            checkedDark = 'on';
            set(hThemesClassicMenuitem, 'Accelerator','K');
            set(hThemesDarkMenuitem, 'Accelerator','');
            set(get(hPlotAxes2,'XLabel'),'Color','w');
            set(hPlotAxes2,'XColor','w','YColor','w');
            set(hEditControllerIDs,'ForegroundColor','w','BackgroundColor',[0.4 0.4 0.4]);
            set(hEditControllerFailureIDs,'ForegroundColor','w','BackgroundColor',[0.4 0.4 0.4]);
            set(hEditNodeFailureIDs,'ForegroundColor','w','BackgroundColor',[0.4 0.4 0.4]);
            set(hResultPopupMenu,'ForegroundColor','w','BackgroundColor',[0.4 0.4 0.4]);
            set(hScenarioPopupMenu,'ForegroundColor','w','BackgroundColor',[0.4 0.4 0.4]);
            set(hXAxisPopupMenu,'ForegroundColor','w','BackgroundColor',[0.4 0.4 0.4]);
            set(hYAxisPopupMenu,'ForegroundColor','w','BackgroundColor',[0.4 0.4 0.4]);
        end
        set(hThemesClassicMenuitem,'Checked',checkedClassic);
        set(hThemesDarkMenuitem,'Checked',checkedDark);
        set(hMainFigure,'Color',backgroundColor);
        set(hPanelAxes2,'BackgroundColor',get(hMainFigure,'Color'));
        set(hPlotAxes2,'Color',get(hMainFigure,'Color'));
        set(hCheckBoxBalance,'BackgroundColor',get(hMainFigure,'Color'),'ForegroundColor',foregroundColor);
        set(hCheckBoxDistCC,'BackgroundColor',get(hMainFigure,'Color'),'ForegroundColor',foregroundColor);
        set(hCheckBoxDistNC,'BackgroundColor',get(hMainFigure,'Color'),'ForegroundColor',foregroundColor);
        set(hCheckBoxHeatmap,'BackgroundColor',get(hMainFigure,'Color'),'ForegroundColor',foregroundColor);
        set(hCheckBoxIDs,'BackgroundColor',get(hMainFigure,'Color'),'ForegroundColor',foregroundColor);
        set(hCheckBoxTM,'BackgroundColor',get(hMainFigure,'Color'),'ForegroundColor',foregroundColor);
        set(hLabelControllerIDs,'BackgroundColor',get(hMainFigure,'Color'),'ForegroundColor',foregroundColor);
        set(hLabelControllerFailureIDs,'BackgroundColor',get(hMainFigure,'Color'),'ForegroundColor',foregroundColor);
        set(hLabelNodeFailureIDs,'BackgroundColor',get(hMainFigure,'Color'),'ForegroundColor',foregroundColor);
        set(hResultLabel,'BackgroundColor',get(hMainFigure,'Color'),'ForegroundColor',foregroundColor);
        set(hScenarioLabel,'BackgroundColor',get(hMainFigure,'Color'),'ForegroundColor',foregroundColor);
        set(hXAxisLabel,'BackgroundColor',get(hMainFigure,'Color'),'ForegroundColor',foregroundColor);
        set(hYAxisLabel,'BackgroundColor',get(hMainFigure,'Color'),'ForegroundColor',foregroundColor);
        set(hLabelPlotOptions,'BackgroundColor',get(hMainFigure,'Color'),'ForegroundColor',foregroundColor);
        set(hCheckLinks,'BackgroundColor',get(hMainFigure,'Color'),'ForegroundColor',foregroundColor);
        set(hCheckBaseStations,'BackgroundColor',get(hMainFigure,'Color'),'ForegroundColor',foregroundColor);
        set(hCheckAccessNodes,'BackgroundColor',get(hMainFigure,'Color'),'ForegroundColor',foregroundColor);
        set(hCheckMegaEvents,'BackgroundColor',get(hMainFigure,'Color'),'ForegroundColor',foregroundColor);
        set(hCheckAssignment,'BackgroundColor',get(hMainFigure,'Color'),'ForegroundColor',foregroundColor);
        set(hCheckSGWs,'BackgroundColor',get(hMainFigure,'Color'),'ForegroundColor',foregroundColor);
        set(hCheckNeplus,'BackgroundColor',get(hMainFigure,'Color'),'ForegroundColor',foregroundColor);
        set(hCheckIcons,'BackgroundColor',get(hMainFigure,'Color'),'ForegroundColor',foregroundColor);
        set(hLabelLatency,'BackgroundColor',get(hMainFigure,'Color'),'ForegroundColor',foregroundColor);
        set(hCheckLatency,'BackgroundColor',get(hMainFigure,'Color'),'ForegroundColor',foregroundColor);
        set(hCheckVirtualSGWs,'BackgroundColor',get(hMainFigure,'Color'),'ForegroundColor',foregroundColor);
        set(hCheckMegaEventResources,'BackgroundColor',get(hMainFigure,'Color'),'ForegroundColor',foregroundColor);
        set(hMetricsLabel,'BackgroundColor',get(hMainFigure,'Color'),'ForegroundColor',foregroundColor);
        set(hCheckSGWlocations,'BackgroundColor',get(hMainFigure,'Color'),'ForegroundColor',foregroundColor);
        set(hBusyLabel,'BackgroundColor',get(hMainFigure,'Color'),'ForegroundColor',foregroundColor);
        set(hLayerLabel,'BackgroundColor',get(hMainFigure,'Color'),'ForegroundColor',foregroundColor);
        fixAxes2PlotTextColor;
        if isHierarchic
            updatePlotAxes1;
        end

    end


%----------------------------------------------------------------------
% Switches the view to compact mode, which only shows the plotted topology

    function compactViewCallback(hObject, eventdata)
        compactView;
    end

    function compactView
        set(hCompactViewMenuitem,'Checked','on');
        set(hFullViewMenuitem,'Checked','off');
        set(hCompactViewMenuitem, 'Accelerator','');
        set(hFullViewMenuitem, 'Accelerator','T');
        set(hPanelAxes2,'Visible','off');
        set(hPanelAxes1,'Position',compactViewSize);
        set(hYAxisLabel,'Visible','off');
        set(hYAxisPopupMenu,'Visible','off');
        set(hXAxisLabel,'Visible','off');
        set(hXAxisPopupMenu,'Visible','off');
        set(hYAxisPopupMenuHierarchical,'Visible','off');
        set(hXAxisPopupMenuHierarchical,'Visible','off');
    end


%----------------------------------------------------------------------
% Switches the view to full mode, which shows the plotted topology and the
% pareto-plot

    function fullViewCallback(hObject, eventdata)
        fullView;
    end

    function fullView
        set(hCompactViewMenuitem,'Checked','off');
        set(hFullViewMenuitem,'Checked','on');
        set(hCompactViewMenuitem, 'Accelerator','T');
        set(hFullViewMenuitem, 'Accelerator','');
        set(hPanelAxes2,'Visible','on');
        set(hPanelAxes1,'Position',fullViewSize);
        if ~isempty(get(hYAxisPopupMenu,'String'))
            set(hYAxisLabel,'Visible','on');
            set(hYAxisPopupMenu,'Visible','on');
            set(hXAxisLabel,'Visible','on');
            set(hXAxisPopupMenu,'Visible','on');
        end
        if ~isempty(get(hYAxisPopupMenuHierarchical,'String'))
            set(hYAxisLabel,'Visible','on');
            set(hYAxisPopupMenuHierarchical,'Visible','on');
            set(hXAxisLabel,'Visible','on');
            set(hXAxisPopupMenuHierarchical,'Visible','on');
        end
    end


%----------------------------------------------------------------------
% Switches the color of the pareto-plot text according to the selected
% theme
    function fixAxes2PlotTextColor
        if ~plcTopo
            if ~isempty(textXaxis) && ~isempty(textYaxis)
                if strcmp(get(hThemesClassicMenuitem,'Checked'),'off')
                    set(textXaxis,'Color','w');
                    set(textYaxis,'Color','w');
                    set(hPlotAxes2,'Color',get(hMainFigure,'Color'));
                else
                    set(textXaxis,'Color','k');
                    set(textYaxis,'Color','k');
                    set(hPlotAxes2,'Color',get(hMainFigure,'Color'));
                end
            end
        end
    end
end
