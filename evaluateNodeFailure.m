% EVALUATENODEFAILURE Evaluates different controller placements 
% including node failure scenarios.
%
%   X = EVALUATENODEFAILURE(A,B) evaluates different placements of B 
%   controllers in the topology A for the resilience case including 
%   node failure scenarios.
%
%   X = EVALUATENODEFAILURE(A,B,C) evaluates different placements of 
%   B controllers in the topology A for the resilience case including 
%   node failure scenarios with node weights C.
%
%   X = EVALUATENODEFAILURE(A,B,C,D) evaluates different placements of 
%   B controllers in the topology A for the resilience case including 
%   node failure scenarios with node weights C and a maximum number of 
%   simultaneous node failures D.
% 
%   X = EVALUATENODEFAILURE(A,[B],C,D,E) evaluates the single controller 
%   placement E in the topology A for the resilience case including node
%   failure scenarios with node weights C and a maximum number of 
%   simultaneous node failures D. In this case, the content of variable B 
%   is ignored.
%
%   In the node failure case, the default value for the maximum considered 
%   number of simultaneous failures is 2.
%
%   For example use cases, see also PLOTEXAMPLE.

%   Copyright 2012-2013 David Hock, Stefan Geißler, Fabian Helmschrott,
%                       Steffen Gebert
%                       Chair of Communication Networks, Uni Würzburg    


function evaluationResult=evaluateNodeFailure(topology,numberOfControllers,nodeWeights,maximumFailureNumber,singlePlacementInstance)

evaluationResult.numberOfControllers=numberOfControllers;
evaluationResult.failureType='Node';

if ~exist('nodeWeights','var')
    nodeWeights=ones(1,size(topology,1));
end

distanceMatrix=allToAllShortestPathMatrix(topology);


temporaryDistanceMatrix=distanceMatrix;
temporaryDistanceMatrix(temporaryDistanceMatrix==Inf)=nan;
diameterFailureFreeCase=nanmax(nanmax(temporaryDistanceMatrix));

if ~exist('maximumFailureNumber','var')
    if ~exist('singlePlacementInstance','var')
        maximumFailureNumber=2;
    else
        maximumFailureNumber=min(2,size(singlePlacementInstance,2)-1);
    end
end


if ~exist('singlePlacementInstance','var')
    nksize=nchoosek(size(distanceMatrix,1),numberOfControllers);
else
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

% Failure free case
if ~exist('singlePlacementInstance','var')
    evaluationResultFailureFreeCase=evaluateSingleInstance(distanceMatrix,numberOfControllers,nodeWeights);
else
    evaluationResultFailureFreeCase=evaluateSingleInstance(distanceMatrix,numberOfControllers,nodeWeights,1:size(singlePlacementInstance,2),singlePlacementInstance);
end

evaluationResult.avgLatencyN2C=evaluationResultFailureFreeCase.avgLatencyN2C;
evaluationResult.avgLatencyN2CAllNodeFailures=evaluationResultFailureFreeCase.avgLatencyN2C;
evaluationResult.maxLatencyN2C=evaluationResultFailureFreeCase.maxLatencyN2C;
evaluationResult.maxLatencyN2CAllNodeFailures=evaluationResultFailureFreeCase.maxLatencyN2C;
evaluationResult.controllerImbalance=evaluationResultFailureFreeCase.controllerImbalance;
evaluationResult.controllerImbalanceAllNodeFailures=evaluationResultFailureFreeCase.controllerImbalance;
evaluationResult.avgLatencyC2C=evaluationResultFailureFreeCase.avgLatencyC2C;
evaluationResult.avgLatencyC2CAllNodeFailures=evaluationResultFailureFreeCase.avgLatencyC2C;
evaluationResult.maxLatencyC2C=evaluationResultFailureFreeCase.maxLatencyC2C;
evaluationResult.maxLatencyC2CAllNodeFailures=evaluationResultFailureFreeCase.maxLatencyC2C;
evaluationResult.controllerlessNodes=evaluationResultFailureFreeCase.controllerlessNodes;
evaluationResult.sumOfControllerlessNodes=evaluationResultFailureFreeCase.controllerlessNodes;
evaluationResult.maxNumberOfControllerlessNodes=evaluationResultFailureFreeCase.controllerlessNodes;

for i=1:(maximumFailureNumber)
    evaluationResult.sumOfControllerlessNodesForUpToNFailures(i,:)=evaluationResultFailureFreeCase.controllerlessNodes;
    evaluationResult.avgLatencyN2CForUpToNFailures(i,:)=evaluationResultFailureFreeCase.avgLatencyN2C;
    evaluationResult.maxLatencyN2CForUpToNFailures(i,:)=evaluationResultFailureFreeCase.maxLatencyN2C;
    evaluationResult.controllerImbalanceForUpToNFailures(i,:)=evaluationResultFailureFreeCase.controllerImbalance;
    evaluationResult.avgLatencyC2CForUpToNFailures(i,:)=evaluationResultFailureFreeCase.avgLatencyC2C;
    evaluationResult.maxLatencyC2CForUpToNFailures(i,:)=evaluationResultFailureFreeCase.maxLatencyC2C;
end

clear evaluationResultFailureFreeCase; % to save memory

%%Failure cases
for i=1:(maximumFailureNumber)
    fprintf('Considering all combinations of %d node failure(s)',i);
    nkb=combnk(1:size(distanceMatrix,1),i); % select broken nodes
    for j=1:size(nkb,1) % check all combinations of broken nodes
        if mod(j,ceil(size(nkb,1)/10))==0
            fprintf('.');
        end
        
        % Reduce topology to topology without these nodes
        topologyreduced=topology;
        topologyreduced(nkb(j,:),:)=Inf;
        topologyreduced(:,nkb(j,:))=Inf;
        
        % Recalculate new distance metric
        modifiedDistanceMatrix=allToAllShortestPathMatrix(topologyreduced);
        for m=1:length(nkb(j,:))
            modifiedDistanceMatrix(nkb(j,m),nkb(j,m))=Inf;
        end
        
        % Single node islands are not counted
        notcountednodes=0;
        for m=1:size(modifiedDistanceMatrix,1)
            if length(find(modifiedDistanceMatrix(m,:)~=inf))==1
                modifiedDistanceMatrix(m,:)=Inf;
                modifiedDistanceMatrix(:,m)=Inf;
                notcountednodes=notcountednodes+nodeWeights(m);
            end
        end
        
        if ~exist('singlePlacementInstance','var')
            approximationCurrent=evaluateSingleInstance(modifiedDistanceMatrix,numberOfControllers,nodeWeights);
        else
            approximationCurrent=evaluateSingleInstance(modifiedDistanceMatrix,numberOfControllers,nodeWeights,1:size(singlePlacementInstance,2),singlePlacementInstance);
        end
        
        temporaryDistanceMatrix=modifiedDistanceMatrix;
        temporaryDistanceMatrix(temporaryDistanceMatrix==Inf)=nan;
        diameterConsideredFailureCase=nanmax(nanmax(temporaryDistanceMatrix));
        
        approximationCurrent.avgLatencyN2C=approximationCurrent.avgLatencyN2C*diameterConsideredFailureCase/diameterFailureFreeCase;
        approximationCurrent.avgLatencyC2C=approximationCurrent.avgLatencyC2C*diameterConsideredFailureCase/diameterFailureFreeCase;
        approximationCurrent.maxLatencyN2C=approximationCurrent.maxLatencyN2C*diameterConsideredFailureCase/diameterFailureFreeCase;
        approximationCurrent.maxLatencyC2C=approximationCurrent.maxLatencyC2C*diameterConsideredFailureCase/diameterFailureFreeCase;
        
        evaluationResult.sumOfControllerlessNodes=evaluationResult.sumOfControllerlessNodes+approximationCurrent.controllerlessNodes-sum(nodeWeights(nkb(j,:)))-notcountednodes;
        evaluationResult.maxNumberOfControllerlessNodes=nanmax([evaluationResult.maxNumberOfControllerlessNodes;approximationCurrent.controllerlessNodes-sum(nodeWeights(nkb(j,:)))-notcountednodes]);
        evaluationResult.avgLatencyN2CAllNodeFailures=evaluationResult.avgLatencyN2CAllNodeFailures+approximationCurrent.avgLatencyN2C;
        evaluationResult.maxLatencyN2CAllNodeFailures=nanmax([evaluationResult.maxLatencyN2CAllNodeFailures;approximationCurrent.maxLatencyN2C]);
        [evaluationResult.maxLatencyN2CForNFailures(i,:),tempidx]=max([evaluationResult.maxLatencyN2CForNFailures(i,:);approximationCurrent.maxLatencyN2C]);
        evaluationResult.failurePatternIndexOfMaxLatencyN2CForNFailures(i,tempidx==2)=j;
        evaluationResult.avgLatencyC2CAllNodeFailures=evaluationResult.avgLatencyC2CAllNodeFailures+approximationCurrent.avgLatencyC2C;
        evaluationResult.maxLatencyC2CAllNodeFailures=nanmax([evaluationResult.maxLatencyC2CAllNodeFailures;approximationCurrent.maxLatencyC2C]);
        [evaluationResult.maxLatencyC2CForNFailures(i,:),tempidx]=max([evaluationResult.maxLatencyC2CForNFailures(i,:);approximationCurrent.maxLatencyC2C]);
        evaluationResult.failurePatternIndexOfMaxLatencyC2CForNFailures(i,tempidx==2)=j;
        [evaluationResult.maxNumberOfControllerlessNodesForNFailures(i,:),tempidx]=max([evaluationResult.maxNumberOfControllerlessNodesForNFailures(i,:);approximationCurrent.controllerlessNodes-sum(nodeWeights(nkb(j,:)))-notcountednodes]);
        evaluationResult.failurePatternIndexOfMaxNumberOfControllerlessNodesForNFailures(i,tempidx==2)=j;
        evaluationResult.controllerImbalanceAllNodeFailures=nanmax([evaluationResult.controllerImbalanceAllNodeFailures;approximationCurrent.controllerImbalance]);
        [evaluationResult.controllerImbalanceForNFailures(i,:),tempidx]=max([evaluationResult.controllerImbalanceForNFailures(i,:);approximationCurrent.controllerImbalance]);
        evaluationResult.failurePatternIndexOfControllerImbalanceForNFailures(i,tempidx==2)=j;
        for m=i:(maximumFailureNumber)
            evaluationResult.sumOfControllerlessNodesForUpToNFailures(m,:)=evaluationResult.sumOfControllerlessNodesForUpToNFailures(m,:)+approximationCurrent.controllerlessNodes-sum(nodeWeights(nkb(j,:)))-notcountednodes;
            evaluationResult.avgLatencyN2CForUpToNFailures(m,:)=evaluationResult.avgLatencyN2CForUpToNFailures(m,:)+approximationCurrent.avgLatencyN2C;
            evaluationResult.maxLatencyN2CForUpToNFailures(m,:)=nanmax([evaluationResult.maxLatencyN2CForUpToNFailures(m,:);approximationCurrent.maxLatencyN2C]);
            evaluationResult.avgLatencyC2CForUpToNFailures(m,:)=evaluationResult.avgLatencyC2CForUpToNFailures(m,:)+approximationCurrent.avgLatencyC2C;
            evaluationResult.maxLatencyC2CForUpToNFailures(m,:)=nanmax([evaluationResult.maxLatencyC2CForUpToNFailures(m,:);approximationCurrent.maxLatencyC2C]);
            evaluationResult.controllerImbalanceForUpToNFailures(m,:)=nanmax([evaluationResult.controllerImbalanceForUpToNFailures(m,:);approximationCurrent.controllerImbalance]);
        end
        
        clear approximationCurrent;
    end
    fprintf('\n')
end

mydimension=1;
for i=1:(maximumFailureNumber)
    mydimension=mydimension+nchoosek(size(distanceMatrix,1),i);
    evaluationResult.avgLatencyN2CForUpToNFailures(i,:)=evaluationResult.avgLatencyN2CForUpToNFailures(i,:)/mydimension;
    evaluationResult.avgLatencyC2CForUpToNFailures(i,:)=evaluationResult.avgLatencyC2CForUpToNFailures(i,:)/mydimension;
end
evaluationResult.avgLatencyN2CAllNodeFailures=evaluationResult.avgLatencyN2CAllNodeFailures/mydimension;
evaluationResult.avgLatencyC2CAllNodeFailures=evaluationResult.avgLatencyC2CAllNodeFailures/mydimension;
end