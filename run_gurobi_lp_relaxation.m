% Function: run_LP_Solve
% input:    configuration - a matrix where each column is a target
%                           configuration (binary), each row is a target
%           AgentInfo(i,1)  = takeoff time
%           AgentInfo(i,2)  = flightTime
%           AgentInfo(i,3)  = speed
%           AgentInfo(i,4)  = AgentID;
%           AgentInfo(i,5)  = FlightID;
%           verbose       - tell me more...

function [result,outConf,res] = run_gurobi_lp_relaxation(target2val,targetsData,agentInfo,Agent2target,verbose)
    
    % constraints - every target has at most one agent assigned to it =>
    %               #rows(configuration) constraints
    %             - every agent is assigned to at most one configuration =>
    %               #rows(agents2conf) constraints
    %             - agent is only assigned to legal confs =>
    %               #rows(agents2conf) constraints
    
    targetsData_BEGIN_COL       =4;
    targetsData_END_COL         =5;
    targetsData_DURATION_COL    =6;
    M                           = 1000000;
    
    % since lp_solve can't accept a matrix in its objective function, we
    % will flatten the matrix to an array (i.e. x(i,j) = x[i*n + j]
    
    if (verbose) 
        fprintf('\nentered run_gurobi_for_relaxation');
    end
    
    target2Val = [0;target2Val;0];
    
    % some required variables 
    NumOfAgents      = size(agentInfo,1);
    NumOfTargets     = size(targetsData,1);
    numOfYVars       = NumOfAgents*NumOfTargets*NumOfTargets;
    numOfTimeWinVars = 2*NumOfAgents*NumOfTargets;
    NumOfVariables   = numOfYVars + numOfTimeWinVars;
    sOffset          = numOfYVars;
    eOffset          = numOfYVars + (NumOfAgents*NumOfTargets);
    emptyRow         = zeros(1,NumOfVariables);
    
    
    verbose && fprintf('\nINFO: NumOfAgenets=%d, NumOfTargets=%d',NumOfAgents,NumOfTargets);
    
    % make sure confval is a row vector
    if (size(confVal,1) > 1)
        confVal = confVal';
    end
    size(confVal,1) > 1 && error('confVal must be either row or col vector');
    
    % the columns are sorted by:
    % Y[1,1,1],...,Y[1,1,K],Y[1,2,1],...,Y[1,2,K],...,Y[1,J,1],...,Y[1,J,K],Y[2,1,1],....,Y[I,J,K]
    JBlock = [];
    for j=1:numOfTargets
        JBlock = [JBlock ; repmat(target2Val(j),[K,1])];
    end
    % size(JBlok) = J*K
    c = repmat(JBlock,[NumOfAgents,1]);
    % size(c) = I*J*K
    c = [c ; zeros(numOfTimeWinVars,1)]
    % size(c) = I*J*K  +  2*I*J

    % gurobi model objective value
    model.obj = c;
    
    % set max 
    model.modelsense = 'max';
    
    % declare integer variables
    model.vtype(ones(numOfYVars,1)) = 'B';
    
    A = [];
    b = [];
    
    % every agent scans the first and last targets
    rest = zeros(1,numOfTimeWinVars);
    currBlockTarget0 = [ones(1,NumOfTargets), zeros(1, NumOfTargets * (NumOfTargets - 1))];
    currBlockTargetN = repmat([zeros(1, NumOfTargets -1), 1],[1,NumOfTargets]);
    for i= 1:NumOfAgents
        allAgentsBeforeI = zeros(1,(i-1) * NumOfTargets * NumOfTargets);
        allAgentsAfterI  = zeros(1,(NumOfAgents - i) * NumOfTargets * NumOfTargets);
        row1 = [allAgentsBeforeI,currBlockTarget0,allAgentsAfterI,rest];
        row2 = [allAgentsBeforeI,currBlockTargetN,allAgentsAfterI,rest];
        A = [A ; row1 ; row2];
        A = [A ; -1 * row1 ; -1 * row2];
        b = [b ; 1 ; 1; 1; 1];
    end
    
    % if i scans j right before k, then k starts after j ends
    for i=1:NumOfAgents
        for j=1:NumOfTargets
            for k=1:NumOfTargets
                row = emptyRow;
                row(cubeIndex2int(i,j,k,NumOfTargets,NumOfTargets)) = -M;
                row(getSOrEIndex(sOffset,i,j,NumOfTargets)) = 1;
                row(getSOrEIndex(eOffset,i,k,NumOfTargets)) = -1;
                A = [A ; row];
                b = [b ; -1 * M];
            end
        end
    end
    
    % every target gets scanned within its window 
    for i=1:NumOfAgents
        for j=1:NumOfTargets
            row1 = emptyRow;
            row2 = emptyRow;
            row1(getSOrEIndex(sOffset,i,j,NumOfTargets)) = 1;
            row2(getSOrEIndex(eOffset,i,j,NumOfTargets)) = -1;
            A = [A ; row1; row2];
            b = [b ; targetsData(j,targetsData_BEGIN_COL) ; targetsData(j,-1 * targetsData_END_COL)];
        end
    end
    
    % target 1 is getting scanned by agent i after takeoff(i)
    % target N is finished getting scanned before landing(i)
    for i=1:NumOfAgents
        row1 = emptyRow;
        row2 = emptyRow;
        row1(getSOrEIndex(eOffset,i,1,NumOfTargets)) = 1;
        row2(getSOrEIndex(sOffset,i,NumOfTargets,NumOfTargets)) = -1;
        A = [A ; row1; row2];
        b = [b ; agentInfo(i,1) ; -1 * (agentInfo(i,1) + agentInfo(i,2))];
    end
    
    % scanning time is t_J for every target j
    for i=1:NumOfAgents
        allAgentsBeforeI = zeros(1,(i-1) * NumOfTargets * NumOfTargets);
        allAgentsAfterI  = zeros(1,(NumOfAgents - i) * NumOfTargets * NumOfTargets);
        for j=1:NumOfTargets
            currBlock = [zeros(1,j-1), ones(1,NumOfTargets), zeros(1,(NumOfTargets * (NumOfTargets - j)))];
            currBlock = currBlock * targetsData(j,targetsData_DURATION_COL);
            row1 = [allAgentsBeforeI,currBlock,allAgentsAfterI,rest];
            row2 = [allAgentsBeforeI,currBlock,allAgentsAfterI,rest];
            row1(getSOrEIndex(sOffset,i,j,NumOfTargets)) = 1;
            row1(getSOrEIndex(eOffset,i,j,NumOfTargets)) = -1;
            row2(getSOrEIndex(sOffset,i,j,NumOfTargets)) = 1;
            row2(getSOrEIndex(eOffset,i,j,NumOfTargets)) = -1
            A = [A ; row1; row2];
            b = [b ; 0 ; 0];
        end
    end
    
    % add A and b to the model
    model.A = sparse(A);
    model.rhs = b;
    model.sense = '>';
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%  from here and down is copied code, need to modify it as
    %%%%%%%%%%%  needed
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % assign bounds
    model.lb = zeros(NumOfVariables,1);
    model.ub = ones(NumOfVariables,1);
    
    % output file for temp memory usage
    params.NodefileStart = 0.5;
    params.NodefileDir = pwd;
    params.Threads = 1;
        
    % solve!
    params.outputflag = 1;
    result = gurobi(model, params);
    
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
    
% 1 <= i <= I, 1 <= j <= J, 1 <= k <= K
function [index] = cubeIndex2int(i,j,k,J,K)
   index = ((i-1)*J*K) + ((j-1)*K) + k;    
end

function [i,j,k] = intIndex2cubeVal(index,J,K)
    k = mod(index,K);
    indexForJ = (index - k) / K;
    j = mod(indexForJ,J) + 1;
    i = ((indexForJ - j + 1) / J) + 1;
end

function [index] = sqIndex2int(i,j,J)
   index = ((i-1)*J) + j;    
end

function [i,j] = intIndex2sqVal(index,J)
    j = mod(index,K);
    indexForI = (index - j) / J;
    i = indexForI + 1;
end

function [index] = getSOrEIndex(offset,i,j,numOfTargets)
    index = offset + sqIndex2int(i,j,numOfTargets);
end
