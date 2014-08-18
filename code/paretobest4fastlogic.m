function [wout,xout,yout,zout]=paretobest4fastlogic(win,xin,yin,zin) %min min min min
tic;
%% Check Matlab-version
matlabVersion=str2num(regexprep(version('-release'),'[^0-9]','')) ;

allvalues=[win' xin' yin' zin'];
% size(allvalues)
%% Remove multiple identical values
if matlabVersion < 2013
    allvalues=unique(allvalues,'rows');
else
    allvalues=unique(allvalues,'rows','legacy');
end
% size(allvalues)
%% For each disjoint combination of all except for 1 columns of allvalues, keep only best value of remaining column
columns=combnk(1:size(allvalues,2),size(allvalues,2)-1);
for i=1:size(columns,1)
    remainingColumn=setdiff(1:size(allvalues,2),columns(i,:));
    if matlabVersion < 2013
        [allButOne,temp,ix]=unique(allvalues(:,columns(i,:)),'rows');
    else
        [allButOne,temp,ix]=unique(allvalues(:,columns(i,:)),'rows','legacy');
    end
    clear('temp')
    reducedColumn=accumarray(ix,allvalues(:,remainingColumn)',[],@min);
    clear('allvalues')
    allvalues(:,columns(i,:))=allButOne;
    allvalues(:,remainingColumn)=reducedColumn;
    %     size(allvalues)
end

% toc;
%% Test all elements with each other and remove non Pareto-optimal values

size(allvalues)
if size(allvalues,1)<=1e4
    % minuend ? subtrahend = difference
    minuend=repmat(allvalues,[1,1,size(allvalues,1)]);
    subtrahend=repmat(permute(allvalues,[3 2 1]),[size(allvalues,1),1,1]);
    difference=minuend-subtrahend;
    
    % don't compare values with themselves
    difference(logical(repmat(permute(eye(size(allvalues,1)),[1 3 2]),1,[size(allvalues,2),1])))=nan; 
    
    % obtain relation of any multi-dimensional value to all others with "inner min
    % function" and then determine worst relation to all others for each
    % multi-dimensional value with "outer max function"
    % A MAX value of "-1" indicates that there is NO other value which is at
    % least eqally good in all dimensions (MIN=="0")
    keepidx=find(max(min(sign(difference),[],2),[],3)==-1);
    allvalues=allvalues(keepidx,:);
    wout=allvalues(:,1)';
    xout=allvalues(:,2)';
    yout=allvalues(:,3)';
    zout=allvalues(:,4)';
else
    w3=allvalues(:,1)';
    x3=allvalues(:,2)';
    y3=allvalues(:,3)';
    z3=allvalues(:,4)';
    
    wout=[];
    xout=[];
    yout=[];
    zout=[];
    for i=1:length(x3)
        append=1;
        delidx=[];
        %     if (mod(i,1000)==0)
        %         i
        %     end
        for j=1:length(xout)
            if (i~=j)
                mypat=sign([wout(j)-w3(i) xout(j)-x3(i) yout(j)-y3(i) zout(j)-z3(i)]);
                minpat=min(mypat);
                maxpat=max(mypat);
                if(minpat>-1 & maxpat<1) % gleich, gibt es effektiv nicht, da vorher aussortiert
                    append=1;
                    break;
                end
                if(maxpat<1) % nie besser
                    append=0;
                    break;
                end
                if(minpat>-1) % nie schlechter
                    delidx(end+1)=j;
                end
            end
        end
        remainidx=setdiff(1:length(wout),delidx);
        wout=wout(remainidx);
        xout=xout(remainidx);
        yout=yout(remainidx);
        zout=zout(remainidx);
        if append
            wout(end+1)=w3(i);
            xout(end+1)=x3(i);
            yout(end+1)=y3(i);
            zout(end+1)=z3(i);
        end
    end
end
% toc;