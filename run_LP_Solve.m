% Function: run_LP_Solve
% input:    configuration - a matrix where each column is a target
%                           configuration (binary), each row is a target
%           agents2conf   - a binary matrix indicating that agent i (row)
%                           can be assigned to configuration j (col)
%           confVal       - vector of configuration valus
%           verbose       - tell me more...

function [] = run_LP_Solve(configurations,agent2conf,confVal,verbose)
    
    % constraints - every target has at most one agent assigned to it =>
    %               #rows(configuration) constraints
    %             - every agent is assigned to at most one configuration =>
    %               #rows(agents2conf) constraints
    %             - agent is only assigned to legal confs =>
    %               #rows(agents2conf) constraints
    
    lp=mxlpsolve('make_lp', 0, 0);
    % since lp_solve can't accept a matrix in its objective function, we
    % will flatten the matrix to an array (i.e. x(i,j) = x[i*n + j]
    
    % some required variables 
    NumOfAgents = size(agent2conf,1);
    
    % make sure confval is a row vector
    size(confVal,1) > 1 && (confVal == confVal');
    size(confVal,1) > 1 && error('confVal must be either row or col vector');
    
    c = repmat(confVal,[1,NumOfAgents])
    mxlpsolve('set_obj_fn', lp, c');
    mxlpsolve('write_lp', lp, 'debug.lp');