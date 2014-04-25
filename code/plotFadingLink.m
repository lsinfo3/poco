function plotFadingLink(x,y,color1,color2)
stepnumber=10;
stepsize=(color2-color1)/stepnumber;
xsize=diff(x)/stepnumber;
ysize=diff(y)/stepnumber;
for i=1:stepnumber
    color1+stepsize*i;
    plot(x(1)+xsize*[i-1 i],y(1)+ysize*[i-1 i],'Color',max([0 0 0],color1+stepsize*i),'LineWidth',3, 'LineSmoothing','on');
end
