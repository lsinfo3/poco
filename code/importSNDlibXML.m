function [topology,coordinates,nodenames,distanceMatrix]=importSNDlibXML(filename)

% Read XML File into xDoc
xDoc=xmlread(filename);

% Read network and networkStructure in corresponding variables
xNet=xDoc.getElementsByTagName('network');
if (isempty(xNet.item(0)))
    topology=[];
    coordinates=[];
    nodenames=[];
    distanceMatrix=[];
    return
end
xNetStruct=xNet.item(0).getElementsByTagName('networkStructure');

% Read nodes
xNodes=xNetStruct.item(0).getElementsByTagName('nodes').item(0).getElementsByTagName('node');

nodes=struct;
coordinatess=struct;
coordinates=zeros(length(nodes),2);

for i=0:xNodes.getLength-1
    xNode=xNodes.item(i);
    nodes(i+1).id=i+1;
    nodes(i+1).label=xNode.getAttribute('id');
    xCoordinates=xNode.getElementsByTagName('coordinates').item(0);
    nodes(i+1).Longitude=xCoordinates.getElementsByTagName('x').item(0).getTextContent;
    nodes(i+1).Latitude=xCoordinates.getElementsByTagName('y').item(0).getTextContent;
    coordinatess.(['id' num2str(nodes(i+1).id)])=[str2double(nodes(i+1).Latitude) str2double(nodes(i+1).Longitude)];
    coordinates(i+1,:)=[str2double(nodes(i+1).Longitude) str2double(nodes(i+1).Latitude)];
end

% Read edges
xEdges=xNetStruct.item(0).getElementsByTagName('links').item(0).getElementsByTagName('link');

edges=struct;
for i=0:xEdges.getLength-1
    xEdge=xEdges.item(i);
    edges(i+1).id=i+1;
    edges(i+1).label=xEdge.getAttribute('id');
    edges(i+1).source=xEdge.getElementsByTagName('source').item(0).getTextContent;
    edges(i+1).target=xEdge.getElementsByTagName('target').item(0).getTextContent;
end

% Create topology matrix
topology=1-eye(length(nodes));
topology(topology==1)=Inf;

for i=1:length(edges);
    % Find edge endpoint indices
    for j=1:length(nodes)
        if strcmpi(nodes(j).label,edges(i).source)
            rowIndex=j;
        end
        if strcmpi(nodes(j).label,edges(i).target)
            colIndex=j;
        end
    end
    edges(i).coordinatesdistance=distFrom(coordinatess.(['id' num2str(rowIndex)]),coordinatess.(['id' num2str(colIndex)]));    
    topology(rowIndex,colIndex)=edges(i).coordinatesdistance;
    topology(colIndex,rowIndex)=edges(i).coordinatesdistance;
end

% Fix for several nodes on identical location
for j=1:size(topology,1)
    topology(j,coordinates(:,1)==coordinates(j,1) & coordinates(:,2)==coordinates(j,2))=eps;
    topology(coordinates(:,1)==coordinates(j,1) & coordinates(:,2)==coordinates(j,2),j)=eps;
end
nodenames=cell(1,size(topology,1));
for i=1:length(nodes)
    nodenames{i}=char(nodes(i).label);
end
%% filter nodes that have no connections at all
topology(isnan(topology))=Inf;
badIdx=find(sum(topology~=Inf,2)==1);
goodIdx=setdiff(1:length(topology),badIdx);
topology=topology(goodIdx,goodIdx);
coordinates=coordinates(goodIdx,:);
nodenames=nodenames(goodIdx);
distanceMatrix=allToAllShortestPathMatrix(topology);