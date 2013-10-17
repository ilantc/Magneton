% Function: run_LP_Solve
% input:    configuration - a matrix where each column is a target
%                           configuration (binary), each row is a target
%           agents2conf   - a binary matrix indicating that agent i (row)
%                           can be assigned to configuration j (col)
%           confVal       - vector of configuration valus
%           verbose       - tell me more...

function [lp] = run_LP_Solve(configurations,agent2conf,confVal,verbose)
    
    % constraints - every target has at most one agent assigned to it =>
    %               #rows(configuration) constraints
    %             - every agent is assigned to at most one configuration =>
    %               #rows(agents2conf) constraints
    %             - agent is only assigned to legal confs =>
    %               #rows(agents2conf) constraints
    

    % since lp_solve can't accept a matrix in its objective function, we
    % will flatten the matrix to an array (i.e. x(i,j) = x[i*n + j]
    
    % some required variables 
    NumOfAgents     = size(agent2conf,1);
    NumOfConf       = size(agent2conf,2);
    NumOfTargets    = size(configurations,1);
    NumOfVariables  = NumOfAgents * NumOfConf;
    
    verbose && fprintf('\nINFO:NumOfAgenets=%d,NumOfConf=%d,NumOfTargets=%d',NumOfAgenets,NumOfConf,NumOfTargets);
    
    lp=mxlpsolve('make_lp', 0, NumOfVariables);
    mxlpsolve('set_maxim',lp);
    
    % make sure confval is a row vector
    size(confVal,1) > 1 && (confVal == confVal');
    size(confVal,1) > 1 && error('confVal must be either row or col vector');
    
    c = repmat(confVal,[1,NumOfAgents]);
    mxlpsolve('set_obj_fn', lp, c);
    
    % first constraint - every target has at most one agent passing through it
    % could not think of a better way to this other than a loop
    for i= 1:NumOfTargets
        row = repmat(configurations(i,:),[1,NumOfAgents]);
        mxlpsolve('add_constraint', lp, row,'LE',1);
    end
    
    % every agent is assigned to at most one configuration
    for i=0:NumOfAgents-1
        row = zeros(1,NumOfVariables);
        row(( i*NumOfConf + 1):((i+1)*NumOfConf)) = ones(1,NumOfConf);
        mxlpsolve('add_constraint', lp, row,'LE',1);
    end
    
    % making sure agents are only assigned to legal configurations:
    row         = reshape(agent2conf',[1,NumOfVariables]);
    leftSide    = sum(row);
    mxlpsolve('add_constraint', lp, row,'LE',leftSide);
    
    % adding binary constraints 
    for i=1:NumOfVariables
        mxlpsolve('set_binary',lp,i,1);
    end
    mxlpsolve('write_lp', lp, 'debug.lp');
    mxlpsolve('solve', lp);
    
    
    
    
    
    
    