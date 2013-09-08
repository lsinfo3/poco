% ALLTOALLASHORTESTPATHMATRIX Calculates an all to all shortest path matrix 
% between any nodes of a given topology.
%
%   X = ALLTOALLASHORTESTPATHMATRIX(A) calculates an all to all shortest 
% path matrix between any nodes of the topology A given as matrix
% indicating the distance between the different nodes.
%
% The function adopts the function allspath published by Michael Kleder on 
% Matlab Exchange 
% http://www.mathworks.com/matlabcentral/fileexchange/8808-all-pairs-shortest-path-graph-solver
%
% Comments have been added and variables renamed to simplify the under-
% standing in context of controller placement. Furthermore, slight changes 
% have been conducted to the original code to allow for non-symmetric 
% matrices. By previously permutating the matrices adequately, the squeeze 
% command could be removed.
%
%   For example use cases, see also EVALUATESINGLEINSTANCE.

%   Copyright 2012-2013 David Hock, Stefan Geißler, Fabian Helmschrott,
%                       Steffen Gebert
%                       Chair of Communication Networks, Uni Würzburg   

function distanceMatrix = allToAllShortestPathMatrix(topology)
distanceMatrix=full(topology);
distanceMatrix(distanceMatrix==0)=Inf;
changeMatrix=ones(size(distanceMatrix));
while any(changeMatrix(:))
    distanceMatrixOld=distanceMatrix;
    distanceMatrix=min(distanceMatrix,... % current distanceMatrix --> min checks on triangle inequality
                min(... % new distanceMatrix containing all values dist_b(a,c)=dist(a,b)+dist(b,c) for any nodes a,b,c --> keep only shortest dist_b(a,c)
                        repmat(permute(distanceMatrix,[1 3 2]),[1 length(distanceMatrix) 1])+...
                        repmat(permute(distanceMatrix,[3 2 1]),[length(distanceMatrix) 1 1])...
                    ,[],3)...
            );
    changeMatrix=distanceMatrix-distanceMatrixOld; % if any changes, continue else stop
end
distanceMatrix(logical(eye(length(distanceMatrix))))=0;
end