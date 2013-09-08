% PARETOBEST2FASTLOGIC Finds and returns Pareto-optimal solutions.
%
%   [X,Y] = PARETOBEST2FASTLOGIC(A,B) finds and returns Pareto-optimal 
%   solutions based out of two vectors A and B where for both vectors it is
%   supposed that the contained metrics should be minimized.
%
%   If used in any other case, e.g., if metric A should be maximized, the 
%   input parameters have to be manipulated accordingly, e.g, 
%   PARETOBEST2FASTLOGIC(-A,B).
%
%   For example use case, see also PLOTPARETO.

%   Copyright 2012-2013 David Hock, Stefan Geißler, Fabian Helmschrott,
%                       Steffen Gebert
%                       Chair of Communication Networks, Uni Würzburg   
%

function [xout,yout]=paretobest2fastlogic(xin,yin)

% Check Matlab-version
matlabVersion=str2num(regexprep(version('-release'),'[^0-9]','')) ;

%% Filter out NaN values
idx=(~isnan(xin)&~isnan(yin));
xin=xin(idx);
yin=yin(idx);

% if xin array is empty or contained only NaN values, return original array
if isempty(xin)
    xout=xin;
    yout=yin;
    return;
end
xout=[];
yout=[];

%% For each disjoint xin value, keep only best yin value
if matlabVersion < 2013
    [x3b,temp,ix]=unique(xin);
    clear temp;
else
    [x3b,~,ix]=unique(xin,'legacy');
end

y3b=accumarray(ix',yin,[],@min);

%% For each disjoint yin value, keep only best xin value
if matlabVersion < 2013
    [y3,temp,ix]=unique(y3b);
    clear temp;
else
    [y3,~,ix]=unique(y3b,'legacy');
end

x3=accumarray(ix,x3b,[],@min)';

%% Loop over all values and add Pareto-optimal values to output sets xout,yout
% whenever a value added to the Pareto-set "dominates" values already included in the
% set, these values are removed
for i=1:length(x3)
    append=1; % boolean if regarded value should be added to the Pareto-set
    delidx=[];
    % compare regarded value to all currently Pareto-optimal values
    for j=1:length(xout)
        if (i~=j)
            % "compare pattern" indicates the comparison between the values
            % -1 indicates that the new value is worse than the old one
            %  0 indicates that both values are the same, should not
            %  happen, due to earlier unique commands above
            % +1 indicates that the new value is better
            comparePattern=sign([xout(j)-x3(i) yout(j)-y3(i)]);            
            minpat=min(comparePattern);
            maxpat=max(comparePattern);    
                                    
            % if maxpat==-1, the new value is not better in any dimension
            % and is not appended
            if(maxpat==-1)
                append=0;
                break;
            end
                        
            % if minpat==1, the value is better as the old
            % value --> the old value can be deleted
            if(minpat==1)
                delidx(end+1)=j;
            end       
        end
    end
    
    % delete all values from the Pareto-set that have been dominated by the
    % new value
    if matlabVersion < 2013
        remainidx=setdiff(1:length(xout),delidx);
    else
        remainidx=setdiff(1:length(xout),delidx,'legacy');
    end
    xout=xout(remainidx);
    yout=yout(remainidx);
    
    % append the value if it is identified as Pareto-optimal
    if append
        xout(end+1)=x3(i);
        yout(end+1)=y3(i);
    end
end
