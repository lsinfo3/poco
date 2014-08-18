function [x,y]=createBaseStations(center,radius,number)
xcenter=center(1,:);
ycenter=center(2,:);
radiusrand=rand(size(center,2),number)*radius;
anglerand=rand(size(center,2),number)*2*pi;
x=cos(anglerand).*radiusrand+repmat(xcenter',1,number);
y=sin(anglerand).*radiusrand+repmat(ycenter',1,number);
x=x(:)';
y=y(:)';
end
