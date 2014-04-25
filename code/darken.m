function cdark=darken(c)
if c=='g'
    c=[0 1 0];
elseif c=='r'
    c=[1 0 0];
elseif c=='b'
    c=[0 0 1];
end
cdark=c*0.8;
