function [mindiff assignmentIdx]=calculateBaseStationAssignmentTransport(distanceMatrix,citynodes,sgwnodes)

% Distance to all nodes
pythagoras=distanceMatrix(citynodes,sgwnodes)';
[mindiff,assignmentIdx]=min(pythagoras,[],1);
end

