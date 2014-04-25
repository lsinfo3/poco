function [topology,latlong,nodenames,distanceMatrix]=importGephiGraphML(filename)

% Read XML File into xDoc
xDoc = xmlread(filename);

% Read keys
xKeys=xDoc.getElementsByTagName('key');

keys=struct;
for i=0:xKeys.getLength-1
    name=lower(regexprep(char(xKeys.item(i).getAttribute('attr.name')),'[^a-zA-Z0-9]',''));
    id=lower(regexprep(char(xKeys.item(i).getAttribute('id')),'[^a-zA-Z0-9]',''));
    keys.(char(id))=char(name);
end

% Check if opened file is not a Topology Zoo GraphML
if ~isfield(keys, 'x')
    topology=[];
    latlong=[];
    nodenames=[];
    distanceMatrix=[];
  return 
end

% Read nodes
xNodes=xDoc.getElementsByTagName('node');

nodes=struct;
latlongs=struct;
latlong=zeros(length(nodes),2);

for i=0:xNodes.getLength-1
    xNode=xNodes.item(i);
    xData=xNode.getElementsByTagName('data');
    for j=0:xData.getLength-1;
        xKey=lower(regexprep(char(xData.item(j).getAttribute('key')),'[^a-zA-Z0-9]',''));
        nodes(i+1).(char(keys.(char(xKey))))=char(xData.item(j).getTextContent);
    end
    nodes(i+1).id=str2double(regexprep(char(xNode.getAttribute('id')),'[^0-9]',''));
    latlongs.(['id' num2str(nodes(i+1).id)])=[str2double(nodes(i+1).x) str2double(nodes(i+1).y)];
    latlong(i+1,:)=[str2double(nodes(i+1).x) str2double(nodes(i+1).y)];
end

% Read edges
xEdges=xDoc.getElementsByTagName('edge');

edges=struct;
for i=0:xEdges.getLength-1
    xEdge=xEdges.item(i);
    edges(i+1).source=str2double(regexprep(char(xEdge.getAttribute('source')),'[^0-9]',''));
    edges(i+1).target=str2double(regexprep(char(xEdge.getAttribute('target')),'[^0-9]',''));
    xData=xEdge.getElementsByTagName('data');
    for j=0:xData.getLength-1;
        xKey=xData.item(j).getAttribute('key');
        edges(i+1).(char(keys.(char(xKey))))=char(xData.item(j).getTextContent);
    end
end

% Create topology matrix
topology=1-eye(length(nodes));
topology(topology==1)=Inf;

for i=1:length(edges);
    % Find edge endpoint indices
    rowIndex=[];
    colIndex=[];
    for j=1:length(nodes)     
        if nodes(j).id==edges(i).source
            rowIndex=j;
        end
        if nodes(j).id==edges(i).target
            colIndex=j;
        end
    end
    if ~isempty(rowIndex) && ~isempty(colIndex)
        edges(i).latlongdistance=1/str2num(edges(i).weight);%distFrom(latlongs.(['id' num2str(edges(i).source)]),latlongs.(['id' num2str(edges(i).target)]));
        topology(rowIndex,colIndex)=edges(i).latlongdistance;
        topology(colIndex,rowIndex)=edges(i).latlongdistance;
    end
end

% Fix for several nodes on identical location
for j=1:size(topology,1)
    topology(j,latlong(:,1)==latlong(j,1) & latlong(:,2)==latlong(j,2))=eps;
    topology(latlong(:,1)==latlong(j,1) & latlong(:,2)==latlong(j,2),j)=eps;
end
nodenames=cell(1,size(topology,1));
for i=1:length(nodes)
    nodenames{i}=nodes(i).label;
end

%% filter nodes that have no connections at all
topology(isnan(topology))=Inf;
badIdx=find(sum(topology~=Inf,2)==1);
goodIdx=setdiff(1:length(topology),badIdx);
if ~isempty(goodIdx)
topology=topology(goodIdx,goodIdx);
latlong=latlong(goodIdx,:);
nodenames=nodenames(goodIdx);
distanceMatrix=allToAllShortestPathMatrix(topology);
else topology=[];
    latlong=[];
    nodenames=[];
    distanceMatrix=[];
end