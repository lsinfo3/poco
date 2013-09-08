% GETPLOTPARAMETERS Retrieves the parameters necessary to plot a given 
% topology, placement, and failure scenario.
%
%   [W,X,Y,Z]=getPlotParameters(A,B,C,D) retrieves the parameters used to
%   plot the topology A regarding given evaluation result B, metric field 
%   name C and placement id D and returns the ids of controllers W, failed 
%   controllers X, failed nodes Y, and failed links Z, where in the
%   considered cases of node and controller failures, Z is always empty.
%
%   For example use cases, see also PLOTEXAMPLE.

%   Copyright 2012-2013 David Hock, Stefan Geißler, Fabian Helmschrott,
%                       Steffen Gebert
%                       Chair of Communication Networks, Uni Würzburg   

function [controllerplaces,controllersfailed,nodesfailed,linksfailed]=getPlotParameters(topology,evaluationResult,fieldname,idx)

% Check Matlab-version
matlabVersion=str2num(regexprep(version('-release'),'[^0-9]','')) ;

controllersfailed=[];
nodesfailed=[];
linksfailed=[];

% Proof completeness of statement
if ~exist('fieldname','var') || ~isfield(evaluationResult,fieldname)
    error('Invalid fieldname.');
end

% idx not given or illegal value
if ~exist('idx','var') || idx<1 || idx>length(evaluationResult.(fieldname))
    error('Invalid idx.');
end

%% Get controllerplaces for every optimizationtype
% Generate all possible placements for given evaluation result
nk=combnk(1:size(topology,1),evaluationResult.numberOfControllers);
% Select the used placement given by idx
controllerplaces=nk(idx,:);

%% Generate failurepatterns regarding node failures
if strcmpi(evaluationResult.failureType,'Node')
    [temp,worst_number_of_failures]=max(evaluationResult.(['failurePatternIndexOf' strrep(strrep(strrep(strrep(fieldname,'AllNodeFailures', ''), 'controller', 'Controller'), 'max', 'Max'), 'Controllerless', 'MaxNumberOfControllerless') 'ForNFailures'])(:,idx));
    clear temp;
    failurepatterns=combnk(1:size(topology),worst_number_of_failures);
    if ~isnan(evaluationResult.failurePatternIndexOfMaxLatencyN2CForNFailures(worst_number_of_failures,idx))
        nodesfailed=failurepatterns(evaluationResult.failurePatternIndexOfMaxLatencyN2CForNFailures(worst_number_of_failures,idx),:);
    end  
    
%% Generate failurepatterns redarding controller failures
elseif strcmpi(evaluationResult.failureType,'Controller')
    [temp,worst_number_of_failures]=max(evaluationResult.(['failurePatternIndexOf' strrep(strrep(strrep(strrep(fieldname,'AllControllerFailures', ''), 'controller', 'Controller'), 'max', 'Max'), 'Controllerless', 'MaxNumberOfControllerless') 'ForNFailures'])(:,idx));
    clear temp;
    % In this case failurepatterns contain the remaining WORKING
    % controllers
    failurepatterns=combnk(1:evaluationResult.numberOfControllers,evaluationResult.numberOfControllers-worst_number_of_failures);
    if matlabVersion < 2013
        controllersfailed=nk(idx,setdiff(1:size(nk,2),failurepatterns(evaluationResult.failurePatternIndexOfMaxLatencyN2CForNFailures(worst_number_of_failures,idx),:)));
    else
        controllersfailed=nk(idx,setdiff(1:size(nk,2),failurepatterns(evaluationResult.failurePatternIndexOfMaxLatencyN2CForNFailures(worst_number_of_failures,idx),:), 'legacy'));
    end
end