% Function: run_LP_Solve
% input:    configuration - a matrix where each column is a target
%                           configuration (binary), each row is a target
%           agents2conf   - a binary matrix indicating that agent i (row)
%                           can be assigned to configuration j (col)
%           confVal       - vector of configuration valus
%           verbose       - tell me more...

function  = run_LP_Solve(configurations,agent2conf,confVal,verbose)
    
    % constraints - every target has at most one agent assigned to it =>
    %               #rows(configuration) constraints
    %             - every agent is assigned to at most one configuration =>
    %               #rows(agents2conf) constraints
    %             - agent is only assigned to legal confs =>
    %               #rows(agents2conf) constraints
    
    lp=mxlpsolve('make_lp', 0, 0);
    mxlpsolve('set_obj_fn', lp, [1, 3, 6.24, 0.1]);