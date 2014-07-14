% Function: run_LP_Solve
% input:    configuration - a matrix where each column is a target
%                           configuration (binary), each row is a target
%           agents2conf   - a binary matrix indicating that agent i (row)
%                           can be assigned to configuration j (col)
%           confVal       - vector of configuration valus
%           verbose       - tell me more...

function [result,outConf] = run_gurobi(configurations,agent2conf,confVal,verbose)
    
    % constraints - every target has at most one agent assigned to it =>
    %               #rows(configuration) constraints
    %             - every agent is assigned to at most one configuration =>
    %               #rows(agents2conf) constraints
    %             - agent is only assigned to legal confs =>
    %               #rows(agents2conf) constraints
    

    % since lp_solve can't accept a matrix in its objective function, we
    % will flatten the matrix to an array (i.e. x(i,j) = x[i*n + j]
    
    if (verbose) 
        fprintf('\nentered run_gurobi');
    end
    
    % some required variables 
    NumOfAgents     = size(agent2conf,1);
    NumOfConf       = size(agent2conf,2);
    NumOfTargets    = size(configurations,1);
    NumOfVariables  = NumOfAgents * NumOfConf;

    verbose && fprintf('\nINFO: NumOfAgenets=%d, NumOfConf=%d, NumOfTargets=%d, NumOfVariables=%d',NumOfAgents,NumOfConf,NumOfTargets,NumOfVariables);
    
    % make sure confval is a row vector
    if (size(confVal,1) > 1)
        confVal = confVal';
    end
    size(confVal,1) > 1 && error('confVal must be either row or col vector');
    
    c = repmat(confVal,[1,NumOfAgents]);

    % gurobi model objective value
    model.obj = c;
    
    % set max 
    model.modelsense = 'max';
    
    % declare integer variables
    % model.vtype = repmat('C', NumOfVariables, 1);
    model.vtype(ones(NumOfVariables,1)) = 'B';
    
    A = [];
    b = [];
    % first constraint - every target has at most one agent passing through it
    % could not think of a better way to this other than a loop
    for i= 1:NumOfTargets
        row = repmat(configurations(i,:),[1,NumOfAgents]);
        A = [A ; row];
        b = [b ; 1];
    end
    
    % every agent is assigned to at most one configuration
    for i=0:NumOfAgents-1
        row = zeros(1,NumOfVariables);
        row(( i*NumOfConf + 1):((i+1)*NumOfConf)) = ones(1,NumOfConf);
        A = [A ; row];
        b = [b ; 1];
    end
    
    % making sure agents are only assigned to legal configuration:
    row         = reshape(agent2conf',[1,NumOfVariables]);
    row         = row -1;
    row         = row * (-1);
    leftSide    = 0;
    A = [A ; row];
    b = [b ; 0];
    
    % add A and b to the model
    model.A = sparse(A);
    model.rhs = b;
    model.sense = '<';
    
    % addign bounds
    model.lb = zeros(NumOfVariables,1);
    model.ub = ones(NumOfVariables,1);
    
    % solve!
    params.outputflag = 1;
    result = gurobi(model, params);
    
    % adding timeout constraints
    % mxlpsolve('set_timeout', lp, 1200);
    % mxlpsolve('set_break_at_first', lp, 1)
    % mxlpsolve('set_obj_bound', lp, 130);
    % mxlpsolve('set_print_sol',lp, 2);
    % mxlpsolve('write_lp', lp, 'debug.lp');
    % mxlpsolve('solve', lp);
    
    res = result.objval;
    mat = result.x;
    mat = reshape(mat,[NumOfConf,NumOfAgents])';
    configurations = full(configurations);
    
    outConf = zeros(NumOfTargets,NumOfAgents);
    
    fprintf('\n\n\n######## results ########\n');
     for agent = 1:NumOfAgents 
         for conf = 1:NumOfConf
            if (mat(agent,conf)==1)
               %fprintf('agent %d is assigned to targets:',agent);
                for trgt = 1:NumOfTargets
                    if (configurations(trgt,conf) == 1) 
                        outConf(trgt,agent) = 1;
                        %fprintf(' %d ',trgt);
                    end
                end
                %fprintf('\n');
            end
        end
    end
    fprintf('opt val = %10.10f\n',res);
end
    
    
    
    
    
    