% EVALUATECONTROLLERFAILURE Evaluates different controller placements 
% including controller failure scenarios.
%
%   X = EVALUATECONTROLLERFAILURE(A,B) evaluates different placements of B 
%   controllers in the topology A for the resilience case including 
%   controller failure scenarios.
%
%   X = EVALUATECONTROLLERFAILURE(A,B,C) evaluates different placements of 
%   B controllers in the topology A for the resilience case including 
%   controller failure scenarios with node weights C.
% 
%   X = EVALUATECONTROLLERFAILURE(A,[B],C,D) evaluates the single controller 
%   placement D in the topology A for the resilience case including 
%   controller failure scenarios with node weights C. In this case, the
%   content of variable B is ignored.
%
%   In the controller failure case, the maximum considered number of 
%   simultaneous failures is always B-1.
%
%   For example use cases, see also PLOTEXAMPLE.

%   Copyright 2012-2013 David Hock, Stefan Geißler, Fabian Helmschrott,
%                       Steffen Gebert
%                       Chair of Communication Networks, Uni Würzburg    

function evaluationResult=evaluateControllerFailure(topology,numberOfControllers,nodeWeights,isPLC,singlePlacementInstance)

evaluationResult.numberOfControllers=numberOfControllers;
evaluationResult.failureType='Controller';

if ~exist('nodeWeights','var')
    nodeWeights=ones(1,size(topology,1));
end

if isPLC
    distanceMatrix=topology;
else
    distanceMatrix=allToAllShortestPathMatrix(topology);
end

if ~exist('singlePlacementInstance','var')
    maximumFailureNumber=numberOfControllers-1;
    nksize=nchoosek(size(distanceMatrix,1),numberOfControllers);
else
    maximumFailureNumber=min(numberOfControllers-1,size(singlePlacementInstance,2)-1);
    nksize=size(singlePlacementInstance,1);
end

evaluationResult.avgLatencyN2CForUpToNFailures=zeros(maximumFailureNumber,nksize); 

evaluationResult.maxLatencyN2CForNFailures=zeros(maximumFailureNumber,nksize);
evaluationResult.maxLatencyN2CForUpToNFailures=nan(maximumFailureNumber,nksize);
evaluationResult.failurePatternIndexOfMaxLatencyN2CForNFailures=nan(maximumFailureNumber,nksize);

evaluationResult.controllerImbalanceForUpToNFailures=nan(maximumFailureNumber,nksize); 
evaluationResult.controllerImbalanceForNFailures=zeros(maximumFailureNumber,nksize);
evaluationResult.failurePatternIndexOfControllerImbalanceForNFailures=nan(maximumFailureNumber,nksize); 

evaluationResult.sumOfControllerlessNodesForUpToNFailures=zeros(maximumFailureNumber,nksize); 
evaluationResult.maxNumberOfControllerlessNodesForNFailures=zeros(maximumFailureNumber,nksize);
evaluationResult.failurePatternIndexOfMaxNumberOfControllerlessNodesForNFailures=nan(maximumFailureNumber,nksize);

evaluationResult.avgLatencyC2CForUpToNFailures=zeros(maximumFailureNumber,nksize);

evaluationResult.maxLatencyC2CForUpToNFailures=nan(maximumFailureNumber,nksize);
evaluationResult.maxLatencyC2CForNFailures=zeros(maximumFailureNumber,nksize);
evaluationResult.failurePatternIndexOfMaxLatencyC2CForNFailures=nan(maximumFailureNumber,nksize);

%% Failure free case
if ~exist('singlePlacementInstance','var')
    evaluationResultFailureFreeCase=evaluateSingleInstance(distanceMatrix,numberOfControllers,nodeWeights);
else
    evaluationResultFailureFreeCase=evaluateSingleInstance(distanceMatrix,numberOfControllers,nodeWeights,1:size(singlePlacementInstance,2),singlePlacementInstance);
end

evaluationResult.avgLatencyN2C=evaluationResultFailureFreeCase.avgLatencyN2C;
evaluationResult.avgLatencyN2CAllControllerFailures=evaluationResultFailureFreeCase.avgLatencyN2C;
evaluationResult.maxLatencyN2C=evaluationResultFailureFreeCase.maxLatencyN2C;
evaluationResult.maxLatencyN2CAllControllerFailures=evaluationResultFailureFreeCase.maxLatencyN2C;
evaluationResult.controllerImbalance=evaluationResultFailureFreeCase.controllerImbalance;
evaluationResult.controllerImbalanceAllControllerFailures=evaluationResultFailureFreeCase.controllerImbalance;
evaluationResult.avgLatencyC2C=evaluationResultFailureFreeCase.avgLatencyC2C;
evaluationResult.avgLatencyC2CAllControllerFailures=evaluationResultFailureFreeCase.avgLatencyC2C;
evaluationResult.maxLatencyC2C=evaluationResultFailureFreeCase.maxLatencyC2C;
evaluationResult.maxLatencyC2CAllControllerFailures=evaluationResultFailureFreeCase.maxLatencyC2C;
evaluationResult.sumOfControllerlessNodes=evaluationResultFailureFreeCase.maxNumberOfControllerlessNodes;
evaluationResult.maxNumberOfControllerlessNodes=evaluationResultFailureFreeCase.maxNumberOfControllerlessNodes;

for i=1:(maximumFailureNumber)
    evaluationResult.sumOfControllerlessNodesForUpToNFailures(i,:)=evaluationResultFailureFreeCase.maxNumberOfControllerlessNodes;
    evaluationResult.avgLatencyN2CForUpToNFailures(i,:)=evaluationResultFailureFreeCase.avgLatencyN2C;
    evaluationResult.maxLatencyN2CForUpToNFailures(i,:)=evaluationResultFailureFreeCase.maxLatencyN2C;
    evaluationResult.controllerImbalanceForUpToNFailures(i,:)=evaluationResultFailureFreeCase.controllerImbalance;
    evaluationResult.avgLatencyC2CForUpToNFailures(i,:)=evaluationResultFailureFreeCase.avgLatencyC2C;
    evaluationResult.maxLatencyC2CForUpToNFailures(i,:)=evaluationResultFailureFreeCase.maxLatencyC2C;
end

clear evaluationResultFailureFreeCase; % to save memory

%% Failure cases
for i=1:(maximumFailureNumber)
    fprintf('Considering all combinations of %d controller failure(s)',i);
    if ~exist('singlePlacementInstance','var')
        nkb=combnk(1:numberOfControllers,numberOfControllers-i); % select working controllers
    else
        nkb=combnk(1:size(singlePlacementInstance,2),size(singlePlacementInstance,2)-i); % select working controllers
    end
    for j=1:size(nkb,1) % check all combinations of working controllers
        if mod(j,ceil(size(nkb,1)/10))==0
            fprintf('.');
        end
        notcountednodes=0;
        
        if ~exist('singlePlacementInstance','var')
            approximationCurrent=evaluateSingleInstance(distanceMatrix,numberOfControllers,nodeWeights,nkb(j,:));
        else
            approximationCurrent=evaluateSingleInstance(distanceMatrix,numberOfControllers,nodeWeights,nkb(j,:),singlePlacementInstance);
        end
        
        evaluationResult.sumOfControllerlessNodes=evaluationResult.sumOfControllerlessNodes+approximationCurrent.maxNumberOfControllerlessNodes-sum(nodeWeights(nkb(j,:)))-notcountednodes;
        evaluationResult.maxNumberOfControllerlessNodes=nanmax([evaluationResult.maxNumberOfControllerlessNodes;approximationCurrent.maxNumberOfControllerlessNodes-sum(nodeWeights(nkb(j,:)))-notcountednodes]);
        evaluationResult.avgLatencyN2CAllControllerFailures=evaluationResult.avgLatencyN2CAllControllerFailures+approximationCurrent.avgLatencyN2C;
        evaluationResult.maxLatencyN2CAllControllerFailures=nanmax([evaluationResult.maxLatencyN2CAllControllerFailures;approximationCurrent.maxLatencyN2C]);
        [evaluationResult.maxLatencyN2CForNFailures(i,:),tempidx]=max([evaluationResult.maxLatencyN2CForNFailures(i,:);approximationCurrent.maxLatencyN2C]);
        evaluationResult.failurePatternIndexOfMaxLatencyN2CForNFailures(i,tempidx==2)=j;
        evaluationResult.avgLatencyC2CAllControllerFailures=evaluationResult.avgLatencyC2CAllControllerFailures+approximationCurrent.avgLatencyC2C;
        evaluationResult.maxLatencyC2CAllControllerFailures=nanmax([evaluationResult.maxLatencyC2CAllControllerFailures;approximationCurrent.maxLatencyC2C]);
        [evaluationResult.maxLatencyC2CForNFailures(i,:),tempidx]=max([evaluationResult.maxLatencyC2CForNFailures(i,:);approximationCurrent.maxLatencyC2C]);
        evaluationResult.failurePatternIndexOfMaxLatencyC2CForNFailures(i,tempidx==2)=j;
        [evaluationResult.maxNumberOfControllerlessNodesForNFailures(i,:),tempidx]=max([evaluationResult.maxNumberOfControllerlessNodesForNFailures(i,:);approximationCurrent.maxNumberOfControllerlessNodes-sum(nodeWeights(nkb(j,:)))-notcountednodes]);
        evaluationResult.failurePatternIndexOfMaxNumberOfControllerlessNodesForNFailures(i,tempidx==2)=j;
        evaluationResult.controllerImbalanceAllControllerFailures=nanmax([evaluationResult.controllerImbalanceAllControllerFailures;approximationCurrent.controllerImbalance]);
        [evaluationResult.controllerImbalanceForNFailures(i,:),tempidx]=max([evaluationResult.controllerImbalanceForNFailures(i,:);approximationCurrent.controllerImbalance]);
        evaluationResult.failurePatternIndexOfControllerImbalanceForNFailures(i,tempidx==2)=j;
        for m=i:(maximumFailureNumber)
            evaluationResult.sumOfControllerlessNodesForUpToNFailures(m,:)=evaluationResult.sumOfControllerlessNodesForUpToNFailures(m,:)+approximationCurrent.maxNumberOfControllerlessNodes-sum(nodeWeights(nkb(j,:)))-notcountednodes;
            evaluationResult.avgLatencyN2CForUpToNFailures(m,:)=evaluationResult.avgLatencyN2CForUpToNFailures(m,:)+approximationCurrent.avgLatencyN2C;
            evaluationResult.maxLatencyN2CForUpToNFailures(m,:)=nanmax([evaluationResult.maxLatencyN2CForUpToNFailures(m,:);approximationCurrent.maxLatencyN2C]);
            evaluationResult.avgLatencyC2CForUpToNFailures(m,:)=evaluationResult.avgLatencyC2CForUpToNFailures(m,:)+approximationCurrent.avgLatencyC2C;
            evaluationResult.maxLatencyC2CForUpToNFailures(m,:)=nanmax([evaluationResult.maxLatencyC2CForUpToNFailures(m,:);approximationCurrent.maxLatencyC2C]);
            evaluationResult.controllerImbalanceForUpToNFailures(m,:)=nanmax([evaluationResult.controllerImbalanceForUpToNFailures(m,:);approximationCurrent.controllerImbalance]);
        end
        
        clear approximationCurrent;
    end
    fprintf('\n');
end

mydimension=1;
for i=1:(maximumFailureNumber)
    mydimension=mydimension+nchoosek(size(distanceMatrix,1),i);
    evaluationResult.avgLatencyN2CForUpToNFailures(i,:)=evaluationResult.avgLatencyN2CForUpToNFailures(i,:)/mydimension;
    evaluationResult.avgLatencyC2CForUpToNFailures(i,:)=evaluationResult.avgLatencyC2CForUpToNFailures(i,:)/mydimension;
end
evaluationResult.avgLatencyN2CAllControllerFailures=evaluationResult.avgLatencyN2CAllControllerFailures/mydimension;
evaluationResult.avgLatencyC2CAllControllerFailures=evaluationResult.avgLatencyC2CAllControllerFailures/mydimension;
end