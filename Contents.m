% A Matlab-based tool for calculating pareto-optimal placements of controllers in a network topology. 
% Version xxx 01-Sep-2013
%
% Files
%
%   Evaluation functions
%   CALCULATEMETRICS            - Calculates all placement metrics for given distance matrix, placements, and node weights.
%   EVALUATECONTROLLERFAILURE   - Evaluates different controller placements including controller failure scenarios.
%   EVALUATENODEFAILURE         - Evaluates different controller placements including node failure scenarios.
%   EVALUATESINGLEINSTANCE      - Evaluates different controller placements for a single distance matrix instance.
%
%   Visualization functions
%   GETPLOTPARAMETERS           - Retrieves the parameters necessary to plot a given topology, placement, and failure scenario.
%   PLOTPARETO                  - Displays the solution space for two given metrics including a set of Pareto-optimal values.
%   PLOTTOPOLOGY                - Plots a given topology to visualize placements and failure scenarios.
%
%   Utility functions
%   ALLTOALLASHORTESTPATHMATRIX - Calculates an all to all shortest path matrix between any nodes of a given topology.
%   IMPORTGRAPHML               - Utility function to import topologies given in GraphML format.
%   PARETOBEST2FASTLOGIC        - Finds and returns Pareto-optimal solutions.
%
%   Script with example use cases
%   PLOTEXAMPLE                 - Examplescript to show how to plot optimization results and corresponding placements and failures.

