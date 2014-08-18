% EVALUATESINGLEINSTANCE Evaluates different controller placements for a
% single distance matrix instance.
%
%   X = EVALUATESINGLEINSTANCE(A,B) evaluates different placements of B 
%   controllers for the single instance of distance matrix A.
%
%   X = EVALUATESINGLEINSTANCE(A,B,C) evaluates different placements of B 
%   controllers for the single instance of distance matrix A with node
%   weights C.
%
%   X = EVALUATESINGLEINSTANCE(A,B,C,D) evaluates different placements of B 
%   controllers for the single instance of distance matrix A with node
%   weights C and a subset of working controllers D.
%
%   X = EVALUATESINGLEINSTANCE(A,[B],C,D,E) evaluates the single controller 
%   placement E for the single instance of distance matrix A with node
%   weights C and a subset of working controllers D. In this case, the
%   content of variable B is ignored.
%
%   For example use cases, see also PLOTEXAMPLE.

%   Copyright 2012-2013 David Hock, Stefan Geißler, Fabian Helmschrott,
%                       Steffen Gebert
%                       Chair of Communication Networks, Uni Würzburg    

function evaluationResult=evaluateSingleInstance_(distanceMatrix,numberOfControllers,nodeWeights,workingsubset,singlePlacementInstance)

evaluationResult.numberOfControllers=numberOfControllers;
evaluationResult.failureType='SingleInstance';

mydisttemp=distanceMatrix;
mydisttemp(mydisttemp==Inf)=nan;
mydiameter=nanmax(nanmax(mydisttemp));

if ~exist('nodeWeights','var')
    nodeWeights=ones(1,size(distanceMatrix,1));
end

if ~exist('workingsubset','var')
    if ~exist('singlePlacementInstance','var')
        workingsubset=1:numberOfControllers;
    else
        workingsubset=1:size(singlePlacementInstance,2);
    end
end

mylimit=2e7/4;

if ~exist('singlePlacementInstance','var')
    
    % Create help arrays for avoiding the repeated computation of combnk
    % (combnk creates all possible combinations of numberOfControllers elements out of n)
    if ~exist('variables','dir')
        mkdir('variables');
    end
    for i=1:numberOfControllers
        if nchoosek(size(distanceMatrix,1),i)*i<mylimit
%             if ~exist(['variables/nk' num2str(size(distanceMatrix,1)) '_' num2str(i) '.mat'],'file') && i*nchoosek(size(distanceMatrix,1),i)<mylimit
                nk=combnk(1:size(distanceMatrix,2),i);
%                 save(['variables/nk' num2str(size(distanceMatrix,1)) '_' num2str(i) '.mat'],'nk');
%             end
        else
            break;
        end
    end
    
    nksize=nchoosek(size(distanceMatrix,1),numberOfControllers);
    
    if numberOfControllers*nksize<mylimit
%         load(['variables/nk' num2str(size(distanceMatrix,1)) '_' num2str(numberOfControllers) '.mat']);
        evaluationResult.nk=nk
        % Returns all placements for numberOfControllers
        [avgLatencyN2C,maxLatencyN2C,controllerlessNodes,controllerImbalance,avgLatencyC2C,maxLatencyC2C]=calculateMetrics(distanceMatrix,nk(:,workingsubset),nodeWeights);
    else
        return
        % find largest computable numberOfControllers (fitting in RAM)
        for i=numberOfControllers:-1:1
            if i*nchoosek(size(distanceMatrix,1),i)<mylimit
                rightNumberOfControllers=i;
                break;
            end
        end
        fprintf('Taking %d nodes as basis and considering all placements of %d additional nodes (total numberOfControllers=%d)',rightNumberOfControllers,numberOfControllers-rightNumberOfControllers,numberOfControllers);
        leftNumberOfControllers=numberOfControllers-rightNumberOfControllers;
        if leftNumberOfControllers>rightNumberOfControllers
            disp(' --> One side numberOfControllers to high, not solvable that way!');
            return;
        end
        lstruct=load(['variables/nk' num2str(size(distanceMatrix,1)) '_' num2str(leftNumberOfControllers) '.mat']);
        left=lstruct.(char(fieldnames(lstruct)));
        lstruct=load(['variables/nk' num2str(size(distanceMatrix,1)) '_' num2str(rightNumberOfControllers) '.mat']);
        right=lstruct.(char(fieldnames(lstruct)));
        clear lstruct;
        avgLatencyN2C=nan(1,nksize);
        maxLatencyN2C=nan(1,nksize);
        controllerlessNodes=nan(1,nksize);
        controllerImbalance=nan(1,nksize);
        avgLatencyC2C=nan(1,nksize);
        maxLatencyC2C=nan(1,nksize);
        arrayoffset=0;
        for j=1:size(left,1)
            if mod(j,ceil(size(left,1)/10))==0
                fprintf('.');
            end
            rightsubset=right(right(:,1)>left(j,end),:);
            nk=[repmat(left(j,:),size(rightsubset,1),1) rightsubset];
            % Returns a subset of all placements for numberOfControllers
            [avgLatencyN2Ctemp,maxLatencyN2Ctemp,controllerlessNodesTemp,controllerImbalanceTemp,avgLatencyC2Ctemp,maxLatencyC2Ctemp]=calculateMetrics(distanceMatrix,nk(:,workingsubset),nodeWeights);
            % Merges the subset to one total set
            avgLatencyN2C(arrayoffset+(1:length(avgLatencyN2Ctemp)))=avgLatencyN2Ctemp;
            maxLatencyN2C(arrayoffset+(1:length(avgLatencyN2Ctemp)))=maxLatencyN2Ctemp;
            controllerlessNodes(arrayoffset+(1:length(avgLatencyN2Ctemp)))=controllerlessNodesTemp;
            controllerImbalance(arrayoffset+(1:length(avgLatencyN2Ctemp)))=controllerImbalanceTemp;
            avgLatencyC2C(arrayoffset+(1:length(avgLatencyN2Ctemp)))=avgLatencyC2Ctemp;
            maxLatencyC2C(arrayoffset+(1:length(avgLatencyN2Ctemp)))=maxLatencyC2Ctemp;
            arrayoffset=arrayoffset+length(avgLatencyN2Ctemp);
        end
    end
else
    [avgLatencyN2C,maxLatencyN2C,controllerlessNodes,controllerImbalance,avgLatencyC2C,maxLatencyC2C]=calculateMetrics(distanceMatrix,singlePlacementInstance(:,workingsubset),nodeWeights);
end
evaluationResult.maxNumberOfControllerlessNodes=controllerlessNodes;
evaluationResult.avgLatencyN2C=avgLatencyN2C/mydiameter;
evaluationResult.maxLatencyN2C=maxLatencyN2C/mydiameter;
evaluationResult.avgLatencyC2C=avgLatencyC2C/mydiameter;
evaluationResult.maxLatencyC2C=maxLatencyC2C/mydiameter;
evaluationResult.controllerImbalance=controllerImbalance;
end
