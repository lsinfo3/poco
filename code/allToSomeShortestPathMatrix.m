% ALLTOSOMESHORTESTPATHMATRIX Calculates an all to some shortest path matrix 
% between any nodes of a given topology.
%
%   X = ALLTOSOMESHORTESTPATHMATRIX(A,SUB) calculates an all to some shortest 
% path matrix between any node of the topology A given as matrix
% indicating the distance between the different nodes and all of the nodes in the subset of A(SUB).
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

function distanceMatrix = allToSomeShortestPathMatrix(topology,SUB)
distanceMatrix=full(topology);
distanceMatrix(distanceMatrix==0)=Inf;
distanceMatrixOut=distanceMatrix(:,SUB);
changeMatrix=ones(size(distanceMatrixOut));
while any(changeMatrix(:))
    distanceMatrixOld=distanceMatrixOut;
    distanceMatrixOut=min(distanceMatrixOut,... % current distanceMatrix --> min checks on triangle inequality
                min(... % new distanceMatrix containing all values dist_b(a,c)=dist(a,b)+dist(b,c) for any nodes a,b,c --> keep only shortest dist_b(a,c)
                        repmat(permute(distanceMatrix,[1 3 2]),[1 length(SUB) 1])+...
                        repmat(permute(distanceMatrixOut,[3 2 1]),[length(distanceMatrix) 1 1])...
                    ,[],3)...
            );
    changeMatrix=distanceMatrixOut-distanceMatrixOld; % if any changes, continue else stop
end
distanceMatrixOut(sub2ind(size(distanceMatrixOut),SUB,1:length(SUB)))=0;
distanceMatrix=distanceMatrixOut;
end