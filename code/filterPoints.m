% Beispiel für einen Punkt
% min(sqrt((x(1)-STRONGEST.coordinates(:,1)).^2+(y(1)-STRONGEST.coordinates(:,2)).^2))
function [xfilter,yfilter]=filterPoints(STRONGEST,x,y,threshold)
xdiff=repmat(x,size(STRONGEST.coordinates,1),1)-repmat(STRONGEST.coordinates(:,1),1,size(x,2));
ydiff=repmat(y,size(STRONGEST.coordinates,1),1)-repmat(STRONGEST.coordinates(:,2),1,size(y,2));
pythagoras=sqrt(xdiff.^2+ydiff.^2);
mindiff=min(pythagoras,[],1);
filterIdx=find(mindiff<threshold);
xfilter=x(filterIdx);
yfilter=y(filterIdx);
end

