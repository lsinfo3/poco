function solution=solveSingleInstancePLC(mydist,k,tm,workingsubset,singlenk)

mydisttemp=mydist;
mydisttemp(mydisttemp==Inf)=nan;
mydiameter=nanmax(nanmax(mydisttemp));

if ~exist('tm','var')
    tm=ones(1,size(mydist,1));
end

if ~exist('workingsubset','var')
    if ~exist('singlenk','var')
        workingsubset=1:k;
    else
        workingsubset=1:size(singlenk,2);
    end
end

mylimit=2e7/4;

if ~exist('singlenk','var')
    
    % Create help arrays for avoiding the repeated computation of combnk
    % (combnk creates all possible combinations of k elements out of n)
    if ~exist('variables','dir')
        mkdir('variables');
    end
    for i=1:k
        if nchoosek(size(mydist,1),i)*i<mylimit
            if ~exist(['variables/nk' num2str(size(mydist,2)) '_' num2str(i) '.mat'],'file') && i*nchoosek(size(mydist,1),i)<mylimit
                nk=combnk(1:size(mydist,2),i);
                save(['variables/nk' num2str(size(mydist,2)) '_' num2str(i) '.mat'],'nk')
            end
        else
            break;
        end
    end
    
    nksize=nchoosek(size(mydist,1),k);
    
    if k*nksize<mylimit
        load(['variables/nk' num2str(size(mydist,1)) '_' num2str(k) '.mat'])
        % Returns all placements for k
        [avgarray,maxarray,uncoveredarray,balancearray,avgarrayCC,maxarrayCC]=evaluatePlacements(mydist,nk(:,workingsubset),tm);
    else
        % find largest computable k (fitting in RAM)
        for i=k:-1:1
            if i*nchoosek(size(mydist,1),i)<mylimit
                rightk=i;
                break;
            end
        end
        fprintf('Taking %d nodes as basis and considering all placements of %d additional nodes (total k=%d)',rightk,k-rightk,k);
        leftk=k-rightk;
        if leftk>rightk
            disp(' --> One side k to high, not solvable that way!');
            return;
        end
        lstruct=load(['variables/nk' num2str(size(mydist,1)) '_' num2str(leftk) '.mat']);
        left=lstruct.(char(fieldnames(lstruct)));
        lstruct=load(['variables/nk' num2str(size(mydist,1)) '_' num2str(rightk) '.mat']);
        right=lstruct.(char(fieldnames(lstruct)));
        clear lstruct;
        avgarray=nan(1,nksize);
        maxarray=nan(1,nksize);
        uncoveredarray=nan(1,nksize);
        balancearray=nan(1,nksize);
        avgarrayCC=nan(1,nksize);
        maxarrayCC=nan(1,nksize);
        arrayoffset=0;
        for j=1:size(left,1)
            if mod(j,ceil(size(left,1)/10))==0
                fprintf('.');
            end
            rightsubset=right(right(:,1)>left(j,end),:);
            nk=[repmat(left(j,:),size(rightsubset,1),1) rightsubset];
            % Returns a subset of all placements for k
            [avgarraytemp,maxarraytemp,uncoveredarraytemp,balancearraytemp,avgarrayCCtemp,maxarrayCCtemp]=evaluatePlacements(mydist,nk(:,workingsubset),tm);
            % Merges the subset to one total set
            avgarray(arrayoffset+(1:length(avgarraytemp)))=avgarraytemp;
            maxarray(arrayoffset+(1:length(avgarraytemp)))=maxarraytemp;
            uncoveredarray(arrayoffset+(1:length(avgarraytemp)))=uncoveredarraytemp;
            balancearray(arrayoffset+(1:length(avgarraytemp)))=balancearraytemp;
            avgarrayCC(arrayoffset+(1:length(avgarraytemp)))=avgarrayCCtemp;
            maxarrayCC(arrayoffset+(1:length(avgarraytemp)))=maxarrayCCtemp;
            arrayoffset=arrayoffset+length(avgarraytemp);
        end
    end
else
    [avgarray,maxarray,uncoveredarray,balancearray,avgarrayCC,maxarrayCC]=evaluatePlacements(mydist,singlenk(:,workingsubset),tm);
end
solution.uncoveredarray=uncoveredarray;
solution.avgarray=avgarray/mydiameter;
solution.maxarray=maxarray/mydiameter;
solution.avgarrayCC=avgarrayCC/mydiameter;
solution.maxarrayCC=maxarrayCC/mydiameter;
solution.balancemaxarray=balancearray;
end
