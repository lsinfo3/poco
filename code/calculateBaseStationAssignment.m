function assignmentIdx=calculateBaseStationAssignment(coordinates,neplusnodes,x,y)

% Initial calculation
xdiff=repmat(x,length(neplusnodes),1)-repmat(coordinates(neplusnodes,1),1,size(x,2));
ydiff=repmat(y,length(neplusnodes),1)-repmat(coordinates(neplusnodes,2),1,size(y,2));

% Distance to all nodes
pythagoras=sqrt(xdiff.^2+ydiff.^2);
[mindiff,assignmentIdx]=min(pythagoras,[],1);
end

