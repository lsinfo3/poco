% IMPORTGRAPHML Utility function to import topologies given in GraphML format.
%   (has been exemplarily tested for the GraphML format used in the 
%   Internet Topology Zoo.
%
%   [X,Y,Z] = IMPORTGRAPHML(A) imports a GraphML file A and returns a 
%   topology matrix X, the geographical latitudes and longitudes of the 
%   nodes as matrix Y and the name of the nodes as cell array Z.
%
%   For example use cases, see also PLOTEXAMPLE.

%   Copyright 2012-2013 David Hock, Stefan Geißler, Fabian Helmschrott,
%                       Steffen Gebert
%                       Chair of Communication Networks, Uni Würzburg   
%

function [topology,latlong,nodenames,distanceMatrix]=importGraphML(filename)
% Check Matlab-version
matlabVersion=str2num(regexprep(version('-release'),'[^0-9]','')) ;

% Read XML File into xDoc
xDoc = xmlread(filename);

% Read keys
xKeys=xDoc.getElementsByTagName('key');

keys=struct;
for i=0:xKeys.getLength-1
    name=xKeys.item(i).getAttribute('attr.name');
    id=xKeys.item(i).getAttribute('id');
    tmp = strrep(char(id), ' ', '_');
    keys.(tmp)=char(name);
end

% Check if opened file is a Gephi GraphML
if isfield(keys, 'x')
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
        xKey=xData.item(j).getAttribute('key');
        nodes(i+1).(char(keys.(char(xKey))))=char(xData.item(j).getTextContent);
    end
    nodes(i+1).id=str2double(xNode.getAttribute('id'));
    latlongs.(['id' num2str(nodes(i+1).id)])=[str2double(nodes(i+1).Latitude) str2double(nodes(i+1).Longitude)];
    latlong(i+1,:)=[str2double(nodes(i+1).Longitude) str2double(nodes(i+1).Latitude)];
end

% Read edges
xEdges=xDoc.getElementsByTagName('edge');

edges=struct;
for i=0:xEdges.getLength-1
    xEdge=xEdges.item(i);
    edges(i+1).source=str2double(xEdge.getAttribute('source'));
    edges(i+1).target=str2double(xEdge.getAttribute('target'));
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
    for j=1:length(nodes)
        if nodes(j).id==edges(i).source
            rowIndex=j;
        end
        if nodes(j).id==edges(i).target
            colIndex=j;
        end
    end
    edges(i).latlongdistance=distFrom(latlongs.(['id' num2str(edges(i).source)]),latlongs.(['id' num2str(edges(i).target)]));
    topology(rowIndex,colIndex)=edges(i).latlongdistance;
    topology(colIndex,rowIndex)=edges(i).latlongdistance;
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
if matlabVersion < 2013
    goodIdx=setdiff(1:length(topology),badIdx);
else
    goodIdx=setdiff(1:length(topology),badIdx,'legacy');
end
topology=topology(goodIdx,goodIdx);
latlong=latlong(goodIdx,:);
nodenames=nodenames(goodIdx);
distanceMatrix=allToAllShortestPathMatrix(topology);

    % distFrom Implementation of Haversine formula.
    % 	 The Haversine formula was adopted from
    %    http://stackoverflow.com/questions/837872/calculate-distance-in-meters-when-you-know-longitude-and-latitude-in-java
    % 	 */
    function dist = distFrom(node1,node2)
        lat1 = node1(1);
        lng1 = node1(2);
        lat2 = node2(1);
        lng2 = node2(2);
        earthRadius = 3958.75;
        dLat = toRadians(lat2 - lat1);
        dLng = toRadians(lng2 - lng1);
        a = sin(dLat / 2) * sin(dLat / 2) + cos(toRadians(lat1)) * cos(toRadians(lat2))	* sin(dLng / 2) * sin(dLng / 2);
        c = 2 * atan2(sqrt(a), sqrt(1 - a));
        dist = earthRadius * c;
        meterConversion = 1/0.000621371192;
        dist=dist * meterConversion;
        
        function r=toRadians(d)
            r=d/180*pi;
        end
        
    end

end