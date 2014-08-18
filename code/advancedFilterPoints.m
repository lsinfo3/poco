function [xfilter,yfilter]=advancedFilterPoints(coordinates,x,y,threshold,centerdegree)

% Initial calculation
xdiff=repmat(x,size(coordinates,1),1)-repmat(coordinates(:,1),1,size(x,2));
ydiff=repmat(y,size(coordinates,1),1)-repmat(coordinates(:,2),1,size(y,2));

% Distance to all nodes
pythagoras=sqrt(xdiff.^2+ydiff.^2);
mindiff=min(pythagoras,[],1);

% Position to all nodes
east=xdiff>0;
north=ydiff>0;
% Check if node is in center (one node is on the upper left, on one the
% lower right, ...)
exnortheast=sum(east & north)>centerdegree;
exnorthwest=sum(~east & north)>centerdegree;
exsoutheast=sum(east & ~north)>centerdegree;
exsouthwest=sum(~east & ~north)>centerdegree;
iscenter=(exnortheast & exnorthwest & exsoutheast & exsouthwest);
acceptedIdx=find(mindiff<threshold | (iscenter==1));
xfilter=x(acceptedIdx);
yfilter=y(acceptedIdx);
end

