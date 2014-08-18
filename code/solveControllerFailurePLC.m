% solveControllerFailure - solves the controller placement problem for the
% topology topology in the resilient case for a placement of k
% controllers with or without node weights tm
%
% USAGE: solution=solveControllerFailure(topology,k,tm)
function solution=solveControllerFailurePLC(topology,k,tm,singlenk)

if ~exist('tm','var')
    tm=ones(1,size(topology,1));
end

mydist=topology; % PLC Case --> allspath would make no sense

if ~exist('singlenk','var')
    maxnumb=k-1;
    nksize=nchoosek(size(mydist,1),k);
else
    maxnumb=min(k-1,size(singlenk,2)-1);
    nksize=size(singlenk,1);
end

solution.avgarrayupto=zeros(maxnumb,nksize);

solution.maxarrayat=zeros(maxnumb,nksize);
solution.maxarrayupto=nan(maxnumb,nksize);
solution.maxarrayidxat=nan(maxnumb,nksize);

solution.balancemaxarrayupto=nan(maxnumb,nksize);
solution.balancemaxarrayat=zeros(maxnumb,nksize);
solution.balancemaxarrayidxat=nan(maxnumb,nksize);

solution.uncoveredarraysumupto=zeros(maxnumb,nksize);
solution.uncoveredarraymaxat=zeros(maxnumb,nksize);
solution.uncoveredarraymaxidxat=nan(maxnumb,nksize);

solution.avgarrayCCupto=zeros(maxnumb,nksize);

solution.maxarrayCCupto=nan(maxnumb,nksize);
solution.maxarrayCCat=zeros(maxnumb,nksize);
solution.maxarrayCCidxat=nan(maxnumb,nksize);

% Failure free case
if ~exist('singlenk','var')
    solutionFF=solveSingleInstancePLC(mydist,k,tm);
else
    solutionFF=solveSingleInstancePLC(mydist,k,tm,1:size(singlenk,2),singlenk);
end

solution.avgarray=solutionFF.avgarray;
solution.avgarrayall=solutionFF.avgarray;
solution.maxarray=solutionFF.maxarray;
solution.maxarrayall=solutionFF.maxarray;
solution.balancemaxarray=solutionFF.balancemaxarray;
solution.balancemaxarrayall=solutionFF.balancemaxarray;
solution.avgarrayCC=solutionFF.avgarrayCC;
solution.avgarrayCCall=solutionFF.avgarrayCC;
solution.maxarrayCC=solutionFF.maxarrayCC;
solution.maxarrayCCall=solutionFF.maxarrayCC;
solution.uncoveredarray=solutionFF.uncoveredarray;
solution.uncoveredarraysum=solutionFF.uncoveredarray;
solution.uncoveredarraymax=solutionFF.uncoveredarray;

for i=1:(maxnumb)
    solution.uncoveredarraysumupto(i,:)=solutionFF.uncoveredarray;
    solution.avgarrayupto(i,:)=solutionFF.avgarray;
    solution.maxarrayupto(i,:)=solutionFF.maxarray;
    solution.balancemaxarrayupto(i,:)=solutionFF.balancemaxarray;
    solution.avgarrayCCupto(i,:)=solutionFF.avgarrayCC;
    solution.maxarrayCCupto(i,:)=solutionFF.maxarrayCC;
end

clear solutionFF; % to save memory

%%Failure cases
for i=1:(maxnumb)
    fprintf('Considering all combinations of %d controller failure(s)',i);
    if ~exist('singlenk','var')
        nkb=combnk(1:k,k-i); % select working controllers
    else
        nkb=combnk(1:size(singlenk,2),size(singlenk,2)-i); % select working controllers
    end
    for j=1:size(nkb,1) % check all combinations of working controllers
        if mod(j,ceil(size(nkb,1)/10))==0
            fprintf('.');
        end
        notcountednodes=0;
        
        if ~exist('singlenk','var')
            solutionCurrent=solveSingleInstancePLC(mydist,k,tm,nkb(j,:));
        else
            solutionCurrent=solveSingleInstancePLC(mydist,k,tm,nkb(j,:),singlenk);
        end
        
        solution.uncoveredarraysum=solution.uncoveredarraysum+solutionCurrent.uncoveredarray-sum(tm(nkb(j,:)))-notcountednodes;
        solution.uncoveredarraymax=nanmax([solution.uncoveredarraymax;solutionCurrent.uncoveredarray-sum(tm(nkb(j,:)))-notcountednodes]);
        solution.avgarrayall=solution.avgarrayall+solutionCurrent.avgarray;
        solution.maxarrayall=nanmax([solution.maxarrayall;solutionCurrent.maxarray]);
        [solution.maxarrayat(i,:),tempidx]=max([solution.maxarrayat(i,:);solutionCurrent.maxarray]);
        solution.maxarrayidxat(i,tempidx==2)=j;
        solution.avgarrayCCall=solution.avgarrayCCall+solutionCurrent.avgarrayCC;
        solution.maxarrayCCall=nanmax([solution.maxarrayCCall;solutionCurrent.maxarrayCC]);
        [solution.maxarrayCCat(i,:),tempidx]=max([solution.maxarrayCCat(i,:);solutionCurrent.maxarrayCC]);
        solution.maxarrayCCidxat(i,tempidx==2)=j;
        [solution.uncoveredarraymaxat(i,:),tempidx]=max([solution.uncoveredarraymaxat(i,:);solutionCurrent.uncoveredarray-sum(tm(nkb(j,:)))-notcountednodes]);
        solution.uncoveredarraymaxidxat(i,tempidx==2)=j;
        solution.balancemaxarrayall=nanmax([solution.balancemaxarrayall;solutionCurrent.balancemaxarray]);
        [solution.balancemaxarrayat(i,:),tempidx]=max([solution.balancemaxarrayat(i,:);solutionCurrent.balancemaxarray]);
        solution.balancemaxarrayidxat(i,tempidx==2)=j;
        for m=i:(maxnumb)
            solution.uncoveredarraysumupto(m,:)=solution.uncoveredarraysumupto(m,:)+solutionCurrent.uncoveredarray-sum(tm(nkb(j,:)))-notcountednodes;
            solution.avgarrayupto(m,:)=solution.avgarrayupto(m,:)+solutionCurrent.avgarray;
            solution.maxarrayupto(m,:)=nanmax([solution.maxarrayupto(m,:);solutionCurrent.maxarray]);
            solution.avgarrayCCupto(m,:)=solution.avgarrayCCupto(m,:)+solutionCurrent.avgarrayCC;
            solution.maxarrayCCupto(m,:)=nanmax([solution.maxarrayCCupto(m,:);solutionCurrent.maxarrayCC]);
            solution.balancemaxarrayupto(m,:)=nanmax([solution.balancemaxarrayupto(m,:);solutionCurrent.balancemaxarray]);
        end
        
        clear solutionCurrent;
    end
    fprintf('\n')
end

mydimension=1;
for i=1:(maxnumb)
    mydimension=mydimension+nchoosek(size(mydist,1),i);
    solution.avgarrayupto(i,:)=solution.avgarrayupto(i,:)/mydimension;
    solution.avgarrayCCupto(i,:)=solution.avgarrayCCupto(i,:)/mydimension;
end
solution.avgarrayall=solution.avgarrayall/mydimension;
solution.avgarrayCCall=solution.avgarrayCCall/mydimension;
end