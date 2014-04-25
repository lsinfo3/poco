% PLOTCOMBS - Return evaluation of all placements for distance matrix mydist and
% combinations of columns nk, as well as optionally for node
% weights/traffic matrix tm
function  [avgarray,maxarray,uncoveredarray,balancearray,avgarrayCC,maxarrayCC]=evaluatePlacements(mydist,nk,tm)
% Check Matlab-version
matlabVersion=str2num(regexprep(version('-release'),'[^0-9]','')) ;
% Create temporary matrix T
[temp,tempidx]=min(reshape(mydist(:,nk),size(mydist,1),size(nk,1),size(nk,2)),[],3);

% Calculate load balancing

% Indices of all controllers with at least one node assigned
if matlabVersion < 2013
    usedidx=unique(tempidx);
else 
    usedidx=unique(tempidx,'legacy');
end
% Simple case - only one controller - imbalance is 0
if length(usedidx)<=1        
        balancearray=zeros(1,size(tempidx,2));
else   
    
    if ~exist('tm','var')
        tempidx4=hist(tempidx,usedidx);
    else
        % If node weights are defined, they are included in calculation of
        % imbalance
        tempidx4=accumarray([reshape(repmat(1:size(tempidx,2),size(tempidx,1),1),numel(tempidx),1) reshape(tempidx,numel(tempidx),1)],repmat(tm,1,size(tempidx,2)),[], @sum)';
    end
    
    % Transpose necessary to repair one-column vector
    if size(tempidx4,1)==1 && size(tempidx4,2)>1
        tempidx4=tempidx4';
    end
    
    % Calculate imbalance as max minus min 
    balancearray=max(tempidx4(end-length(usedidx)+1:end,:))-min(tempidx4(end-length(usedidx)+1:end,:));
end

% Number of controller-less nodes is calculated with or without node
% weights
if exist('tm','var')
    uncoveredarray=sum((temp==Inf).*repmat(tm',1,size(temp,2)));
else
    uncoveredarray=sum(temp==Inf);
end

% Maximum and average node-to-controller latency are calculated
temp(temp==Inf)=nan;
avgarray=nanmean(temp);
maxarray=nanmax(temp);

% Maximum and average inter-controller latency are calculated - matrix needs to be of square size
if diff(size(mydist))==0
    %Controller to Controller - max
    temp=reshape(mydist(:,nk),size(nk,1)*size(mydist,1),size(nk,2));
    maxtemp=reshape(nanmax(temp,[],2),size(mydist,1),size(nk,1));
    maxtemp(maxtemp==Inf)=nan;
    maxarrayCC=nanmax(maxtemp(sub2ind(size(maxtemp),nk',repmat(1:size(nk,1),size(nk,2),1))),[],1);

    %Controller to Controller - avg
    meantemp=reshape(nanmean(temp,2),size(mydist,1),size(nk,1));
    meantemp(meantemp==Inf)=nan;
    avgarrayCC=nanmean(meantemp(sub2ind(size(meantemp),nk',repmat(1:size(nk,1),size(nk,2),1))),1);
else
    maxarrayCC=nan(size(maxarray));
    avgarrayCC=nan(size(maxarray));
end
return