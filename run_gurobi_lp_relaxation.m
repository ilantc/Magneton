% Function: run_LP_Solve
% input:    AgentInfo(i,1)  = takeoff time
%           AgentInfo(i,2)  = flightTime
%           AgentInfo(i,3)  = speed
%           AgentInfo(i,4)  = AgentID;
%           AgentInfo(i,5)  = FlightID;
%           verbose       - tell me more...

function [lp_rlaxation_model,A,b,result] = run_gurobi_lp_relaxation(target2val,targetsData,agentInfo,Agent2target,missionLink,verbose)
    
    targetsData_BEGIN_COL       =4;
    targetsData_END_COL         =5;
    targetsData_DURATION_COL    =6;
    M                           = 1000000;
    
    % since lp_solve can't accept a matrix in its objective function, we
    % will flatten the matrix to an array (i.e. x(i,j) = x[i*n + j]
    
    
    verbose && fprintf('\nentered run_gurobi_for_relaxation');
    
    %fix input: add target 0,inf  and fix parallel targets by duration
    [targetsData,Agent2target] = input_relaxation(missionLink,targetsData,Agent2target,verbose);
    target2val = [0;target2val;0];
    
    % some required variables 
    NumOfAgents      = size(agentInfo,1);
    NumOfTargets     = size(targetsData,1);
    numOfYVars       = NumOfAgents*NumOfTargets*NumOfTargets;
    numOfTimeWinVars = 2*NumOfAgents*NumOfTargets;
    NumOfVariables   = numOfYVars + numOfTimeWinVars;
    sOffset          = numOfYVars;
    eOffset          = numOfYVars + (NumOfAgents*NumOfTargets);
    
    
    verbose && fprintf('\nINFO: NumOfAgenets=%d, NumOfTargets=%d, numOfYVars=%d, numOfTimeWinVars=%d, sOffset=%d, eOffset=%d\n',...
                                NumOfAgents,     NumOfTargets,    numOfYVars,    numOfTimeWinVars,    sOffset,    eOffset);
    
%     % make sure confval is a row vector
%     if (size(confVal,1) > 1)
%         confVal = confVal';
%     end
%     size(confVal,1) > 1 && error('confVal must be either row or col vector');
    
    % the columns are sorted by:
    % Y[1,1,1],...,Y[1,1,K],Y[1,2,1],...,Y[1,2,K],...,Y[1,J,1],...,Y[1,J,K],Y[2,1,1],....,Y[I,J,K]
    JBlock = [];
    for j=1:NumOfTargets
        JBlock = [JBlock ; repmat(target2val(j),[NumOfTargets,1])];
    end
    % size(JBlok) = J*K
    c = repmat(JBlock,[NumOfAgents,1]);
    % size(c) = I*J*K
    c = [c ; zeros(numOfTimeWinVars,1)];
    % size(c) = I*J*K  +  2*I*J

    % gurobi model objective value
    lp_rlaxation_model.obj = c;
    
    % set objective function to max 
    lp_rlaxation_model.modelsense = 'max';
    
    % declare integer variables
    vtypes = [repmat('B',[1,numOfYVars]),repmat('C',[1,numOfTimeWinVars])];
    lp_rlaxation_model.vtype = vtypes;
    
    time = tic;
    % every agent scans the first and last targets
    A1 = [];
    A1 = sparse(A1);
    b1 = [];
    rest = zeros(1,numOfTimeWinVars);
    currBlockTarget0 = [ones(1,NumOfTargets), zeros(1, NumOfTargets * (NumOfTargets - 1))];
    currBlockTargetN = repmat([zeros(1, NumOfTargets -1), 1],[1,NumOfTargets]);
    for i= 1:NumOfAgents
        allAgentsBeforeI = zeros(1,(i-1) * NumOfTargets * NumOfTargets);
        allAgentsAfterI  = zeros(1,(NumOfAgents - i) * NumOfTargets * NumOfTargets);
        row1 = [allAgentsBeforeI,currBlockTarget0,allAgentsAfterI,rest];
        row2 = [allAgentsBeforeI,currBlockTargetN,allAgentsAfterI,rest];
        A1 = [A1 ; row1 ; row2];
        A1 = [A1 ; -1 * row1 ; -1 * row2];
        b1 = [b1 ; 1 ; 1; -1; -1];
    end
    verbose && fprintf('every agent scans the first and last targets\nElapsed=%10.2f\n',toc(time));
    
    time = tic;
    % if i scans j right before k, then k starts after j ends
%     sMatrix1      = [];
%     eMatrix1      = [];
%     sMatrix1      = sparse(sMatrix1);
%     eMatrix1      = sparse(eMatrix1);
    sMatrix      = zeros(NumOfTargets * NumOfTargets * NumOfAgents,NumOfTargets * NumOfAgents);
    eMatrix      = zeros(NumOfTargets * NumOfTargets * NumOfAgents,NumOfTargets * NumOfAgents);
    eMatrixBlock = zeros(NumOfTargets * NumOfTargets,NumOfTargets);
%     eMatrixBlock1 = [];
%     eMatrixBlock1 = sparse(eMatrixBlock1);
    for i=1:NumOfTargets
        eMatrixBlock(((i-1) * NumOfTargets + 1):i * NumOfTargets,i) = -1 * ones(NumOfTargets,1);
%         eMatrixBlock1 = [eMatrixBlock1 ; [zeros(NumOfTargets,i - 1), -1 * ones(NumOfTargets,1), zeros(NumOfTargets,NumOfTargets -i)]];
    end 
    sMatrixBlock = repmat(eye(NumOfTargets),[NumOfTargets,1]);
    rowStep = NumOfTargets * NumOfTargets;
    colStep = NumOfTargets;
    for i=1:NumOfAgents
        eMatrix(((i-1) * rowStep + 1):(i * rowStep),(((i-1) * colStep) + 1):(i * colStep)) = eMatrixBlock;
        sMatrix(((i-1) * rowStep + 1):(i * rowStep),(((i-1) * colStep) + 1):(i * colStep)) = sMatrixBlock;
%         eMatrix1 = [eMatrix1 ; [zeros(NumOfTargets * NumOfTargets,NumOfTargets * (i-1)), eMatrixBlock,                                zeros(NumOfTargets * NumOfTargets,NumOfAgents * NumOfTargets - (NumOfTargets * i))]];
%         sMatrix1 = [sMatrix1 ; [zeros(NumOfTargets * NumOfTargets,NumOfTargets * (i-1)), repmat(eye(NumOfTargets),[NumOfTargets,1]) , zeros(NumOfTargets * NumOfTargets,NumOfAgents * NumOfTargets - (NumOfTargets * i))]];
    end
    A2 = [-M * eye(numOfYVars),sparse(sMatrix), sparse(eMatrix)];
    b2 = -M * ones(numOfYVars,1);
    verbose && fprintf('if i scans j right before k, then k starts after j ends\nElapsed=%10.2f\n',toc(time));
    
    time = tic;
    % every target gets scanned within its window
    A3 = [];
    A3 = sparse(A3);
    b3 = [];
    for i=1:NumOfAgents
        for j=1:NumOfTargets
            row1 = zeros(1,NumOfVariables);
            row2 = zeros(1,NumOfVariables);
            row1(getSOrEIndex(sOffset,i,j,NumOfTargets)) = 1;
            row2(getSOrEIndex(eOffset,i,j,NumOfTargets)) = -1;
            A3 = [A3 ; row1; row2];
            b3 = [b3 ; targetsData(j,targetsData_BEGIN_COL) ; -1 * targetsData(j, targetsData_END_COL)];
        end
    end
    verbose && fprintf('every target gets scanned within its window\nElapsed=%10.2f\n',toc(time));
    
    time = tic;
    A4 = [];
    A4 = sparse(A4);
    b4 = [];
    % target 1 is getting scanned by agent i after takeoff(i)
    % target N is finished getting scanned before landing(i)
    for i=1:NumOfAgents
        row1 = zeros(1,NumOfVariables);
        row2 = zeros(1,NumOfVariables);
        row1(getSOrEIndex(eOffset,i,1,NumOfTargets)) = 1;
        row2(getSOrEIndex(sOffset,i,NumOfTargets,NumOfTargets)) = -1;
        A4 = [A4 ; row1; row2];
        b4 = [b4 ; agentInfo(i,1) ; -1 * (agentInfo(i,1) + agentInfo(i,2))];
    end
    verbose && fprintf('targets 1 and N are getting scanned by agent i between takeoff(i) and landing(i)\nElapsed=%10.2f\n',toc(time));
    
    time = tic;
    A5 = [];
    A5 = sparse(A5);
    b5 = [];
    % scanning time is t_J for every target j
    for i=1:NumOfAgents
        allAgentsBeforeI = zeros(1,(i-1) * NumOfTargets * NumOfTargets);
        allAgentsAfterI  = zeros(1,(NumOfAgents - i) * NumOfTargets * NumOfTargets);
        for j=1:NumOfTargets
            currBlock = [zeros(1,NumOfTargets *(j-1)), ones(1,NumOfTargets), zeros(1,(NumOfTargets * (NumOfTargets - j)))];
            currBlock = currBlock * targetsData(j,targetsData_DURATION_COL);
            row1 = [allAgentsBeforeI,currBlock,allAgentsAfterI,rest];
            row2 = [allAgentsBeforeI,-1 * currBlock,allAgentsAfterI,rest];
            row1(getSOrEIndex(sOffset,i,j,NumOfTargets)) = 1;
            row1(getSOrEIndex(eOffset,i,j,NumOfTargets)) = -1;
            row2(getSOrEIndex(sOffset,i,j,NumOfTargets)) = -1;
            row2(getSOrEIndex(eOffset,i,j,NumOfTargets)) = 1;
            A5 = [A5 ; row1; row2];
            b5 = [b5 ; 0 ; 0];
        end
    end
    verbose && fprintf('scanning time is t_J for every target j\nElapsed=%10.2f\n',toc(time));
    
    time = tic;
    new_constraint=zeros(1,NumOfVariables);
    % no targets before 0
    iterator=1;
    while iterator<numOfYVars
        new_constraint(iterator)=1;
        iterator=iterator+NumOfTargets;
    end
    A6 = [new_constraint; (-1)*new_constraint];
    b6 = [0 ; 0];
    verbose && fprintf('no targets before 0\nElapsed=%10.2f\n',toc(time));
    
    time = tic;
    % no targets after inf
    new_constraint=zeros(1,NumOfVariables);
    jump_size = NumOfTargets*(NumOfTargets);
    iterator=1+jump_size - NumOfTargets;
    while iterator<numOfYVars
        new_constraint(iterator:iterator+NumOfTargets - 1)=ones(1,NumOfTargets);
        iterator=iterator+jump_size;
    end
    A7 = [new_constraint; (-1)*new_constraint];
    b7 = [ 0 ; 0];
    verbose && fprintf('no targets after inf\nElapsed=%10.2f\n',toc(time));
    
    
    time = tic;
    A8 = [];
    A8 = sparse(A8);
    b8 = [];
    % flow constraint %
    for i=1:NumOfAgents
        for j=2:NumOfTargets-1
            new_constraint=zeros(1,NumOfVariables);
            index = cubeIndex2int(i,j,1,NumOfTargets,NumOfTargets);
            new_constraint(index:index+NumOfTargets - 1)=-1*ones(1,NumOfTargets);
            for t=1:NumOfTargets
                index = cubeIndex2int(i,t,j,NumOfTargets,NumOfTargets);
                new_constraint(index)=1;
            end
            A8 = [A8 ; new_constraint ; (-1)*new_constraint];
            b8 = [b8;0;0];
        end
    end
    verbose && fprintf('flow constrs\nElapsed=%10.2f\n',toc(time));
    
    time = tic;
    A9 = [];
    A9 = sparse(A9);
    b9 = [];
    % each target has maximum one target after 
    jump_size = NumOfTargets*NumOfTargets;
    for j=1:(NumOfTargets-1)
        iterator=j*NumOfTargets + 1;
        new_constraint=zeros(1,NumOfVariables);
        while iterator<numOfYVars
            new_constraint(iterator:iterator+NumOfTargets - 1)=ones(1,NumOfTargets);
            iterator=iterator+jump_size;
        end
        A9 = [A9 ; (-1)*new_constraint];
        b9 = [b9 ; -1];
    end
    verbose && fprintf('each target has maximum one target after\nElapsed=%10.2f\n',toc(time));
    
    time = tic;
    A10 = [];
    A10 = sparse(A10);
    b10 = [];
    % scanner constraint
    for i=1:NumOfAgents
        for j=1:NumOfTargets
            new_constraint=zeros(1,NumOfVariables);
            index = cubeIndex2int(i,j,1,NumOfTargets,NumOfTargets);
            new_constraint(index:index+NumOfTargets - 1)=ones(1,NumOfTargets);
            A10 = [A10 ; (-1)*new_constraint];
            b10 = [b10 ; -1*Agent2target(i,j)];
        end
    end
    verbose && fprintf('i scans j only iff canScan(i,j)\nElapsed=%10.2f\n',toc(time));
    
    A11 = [];
    A11 = sparse(A11);
    b11 = [];
    time = tic;
    % Y_i_j_j <= 0
    for i=1:NumOfAgents
        for j=1:NumOfTargets
            new_constraint=zeros(1,NumOfVariables);
            index = cubeIndex2int(i,j,j,NumOfTargets,NumOfTargets);
            new_constraint(index) = -1;
            A11 = [A11 ; new_constraint];
            b11 = [b11 ; 0];
        end
    end
    verbose && fprintf('Y_i_j_j <= 0\nElapsed=%10.2f\n',toc(time));

    A = [];
    A = sparse(A);
    b = [];
    A = [A ; A1];  b = [b ; b1];  % every agent scans the first and last targets
    A = [A ; A2];  b = [b ; b2];  % if i scans j right before k, then k starts after j ends
    A = [A ; A3];  b = [b ; b3];  % every target gets scanned within its window
    A = [A ; A4];  b = [b ; b4];  % targets 1 and N are getting scanned by agent i between takeoff(i) and landing(i)
    A = [A ; A5];  b = [b ; b5];  % scanning time is t_J for every target j
    A = [A ; A6];  b = [b ; b6];  % no targets before 0
    A = [A ; A7];  b = [b ; b7];  % no targets after inf
    A = [A ; A8];  b = [b ; b8];  % flow constraint %
    A = [A ; A9];  b = [b ; b9];  % each target has maximum one target after 
    A = [A ; A10]; b = [b ; b10]; % scanner constraint
    A = [A ; A11]; b = [b ; b11]; % Y_i_j_j <= 0
    
    % add A and b to the model
    lp_rlaxation_model.A = sparse(A);
    lp_rlaxation_model.rhs = b;
    lp_rlaxation_model.sense = '>';
    gurobi_write(lp_rlaxation_model, 'model.lp');
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%  from here and down is copied code, need to modify it as
    %%%%%%%%%%%  needed
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % assign bounds
    lp_rlaxation_model.lb = zeros(NumOfVariables,1);
    lp_rlaxation_model.ub = [ones(numOfYVars,1); M * ones(numOfTimeWinVars,1)];
    
    % output file for temp memory usage
    params.NodefileStart = 0.5;
    params.NodefileDir = pwd;
    params.Threads = 1;
        
    % solve!
    params.outputflag = 1;
    result = gurobi(lp_rlaxation_model, params);
    
    mat = result.x;
    
    fprintf('\n\n\n######## results ########\n');
     for i = 1:NumOfAgents 
         for j = 1:NumOfTargets
             for k = 1:NumOfTargets
                if (mat(cubeIndex2int(i,j,k,NumOfTargets,NumOfTargets))>0)
                    kForPrint = k - 1;
                    if (k == NumOfTargets )
                        kForPrint = Inf;
                    end
                    fprintf('agent %d: %d => %d, (%10.2f)\n',i,j-1,kForPrint,mat(cubeIndex2int(i,j,k,NumOfTargets,NumOfTargets)));
                end
            end
        end
     end
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

function [targetsData,Agent2target] = input_relaxation(missionLink,targetsData,Agent2target,verbose)
    
    %eliminating parallel targets by dividing their duration time by 2
    for i=1:size(missionLink,1)
        if sum(missionLink(i,:)>0)
            targetsData(i,6)=targetsData(i,6)/2; % 6 is the duration column
        end
    end

    %add targets 0 and inf to agent2target at the begining and end of the matrix 
    Agent2target=[ones(size(Agent2target,1),1),Agent2target,ones(size(Agent2target,1),1)];
    %add targets 0 and inf to targetsData at the end of the matrix last row
    targetsData_vector=zeros(1,size(targetsData,2));
    targetsData_vector(5) = 1000000;              %end time
    targetsData=[targetsData;targetsData_vector]; % added the zero target
    targetsData_vector(1) = -1;                   %ID of inf target
    targetsData=[targetsData_vector;targetsData]; % added the inf target
end

            
            





% %%
% NumOfAgents      = 6;
% NumOfTargets     = 8;
% numOfYVars       = NumOfAgents*NumOfTargets*NumOfTargets;
% numOfTimeWinVars = 2*NumOfAgents*NumOfTargets;
% NumOfVariables   = numOfYVars + numOfTimeWinVars;
% sOffset          = numOfYVars;
% eOffset          = numOfYVars + (NumOfAgents*NumOfTargets);
% M                = 100;
% verbose          = 1;
% A                = [];
% b                = [];
%     



