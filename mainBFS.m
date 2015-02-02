function [model,outConf,AgentInfo, allConfigurations, agent2conf, Agent2target, AllConf, excelOut, Agent2sensor, target2sensor,targetsData,target2Val,missionLink,allStat] = mainBFS(file,buildAmount,runAmount,writeOutput,allowParallel)
    
    global target2TargetDistance;
    global missionLink;
    
    amountForBuild = buildAmount;
    finalAmount = runAmount;
    parsingTime = tic;
    % parse the input file
    [ Agent2sensor,target2sensor, AgentInfo, target2Val, target2TargetDistance, missionLink ] = ParseInfile( file );
    if allowParallel~=1
        missionLink=zeros(size(missionLink,1),size(missionLink,2));
    end
    Agent2target = Agent2sensor * target2sensor';
    targetsData  = read_excel_and_clean(file,'InMissions');
    numOfTargets = size(target2sensor,1);
    numOfDrones  = size(AgentInfo,1);

    currTargetID = 1; % all drones are in spot 0,0 (target 0)
    
    allConfigurations = zeros(0,numOfTargets);
    agent2conf        = zeros(numOfDrones,0);
    
    sumAllVals = sum(target2Val);
    maxVal = min(sumAllVals,maxValH1(Agent2target,targetsData,AgentInfo,target2Val));
    fprintf('total value = %d, Best heuristic value = %d\n',sumAllVals,maxVal);
    
    parsingTime = toc(parsingTime);
    fprintf('Done parsing infile, elapsed time %f\n',parsingTime);
    confBuildingTime = tic;
    allStat = {};
    % build the configuration per drone
    for drone = 1:numOfDrones
        %fprintf('calculating confs for drone %i of %i (agentID is %i)\n',drone,numOfDrones,AgentInfo(drone,4));
        agentFlightTime = AgentInfo(drone,2);
        agentTakeoffTime = AgentInfo(drone,1);
        speed = AgentInfo(drone,3);
        agentID = AgentInfo(drone,5);
        currConfs = zeros(numOfTargets,1);
        confTimes = zeros(numOfTargets,2,0);
        allAgentConfs = currConfs;
        droneStat = {};
        for confSize=1:12
            %fprintf('\tconf size %i\n',confSize - 1);
            if (size(currConfs,2) > 0 )
                confBuildTime = tic;
                [currConfs,confsForRun,confTimes,confStat]  = buildConfigurationsPerDroneBFS(currConfs,confTimes,speed,agentID,agentTakeoffTime,agentFlightTime +agentTakeoffTime,target2Val,Agent2target,targetsData,amountForBuild,finalAmount,currTargetID);
                droneStat.(sprintf('conf%d',confSize)).stat = confStat;
                droneStat.(sprintf('conf%d',confSize)).time = toc(confBuildTime);
                % trim top 10k from currConfs here (or inisde the builder
                % function)
                BinaryConfsForRun = confsForRun>0;
                % trim top 1k from binary confs here!
                BinaryConfsForRun  = unique(BinaryConfsForRun', 'rows');
                BinaryConfsForRun  = BinaryConfsForRun';
                allAgentConfs = [allAgentConfs BinaryConfsForRun];
            end
        end 
        currAgent2conf = zeros(numOfDrones,size(allAgentConfs,2));
        currAgent2conf(drone,:) = ones(1,size(allAgentConfs,2));
        agent2conf = [agent2conf currAgent2conf];
        allConfigurations = [allConfigurations allAgentConfs];
        allStat.(sprintf('drone%d',drone)) = droneStat;
        fprintf('done drone %i of %i\n',drone,numOfDrones);
    end
    fprintf('Done building Confs ');
    confBuildingTime = toc(confBuildingTime);
    fprintf('Done building Confs, elapsed time %f\n',confBuildingTime);
    
    fprintf('the number of confs before removing non uniques is: %d\n',size(allConfigurations,2));
    b = unique(allConfigurations', 'rows');
    fprintf('the number of unique confs is: %d\n',size(b,1));
    
    %%%%%%%%%%%%
    % removing duplicate confs
    dupRemovalTime = tic;
    [allConfigurationsU,~,Iu] = unique(allConfigurations','rows','stable');
    allConfigurationsU = allConfigurationsU';
    agent2confU = zeros(numOfDrones,size(allConfigurationsU,2));
    for i=1:max(Iu)
        % a col vector which indicates which agent can perform this conf
        currA2C = sum(agent2conf(:,Iu == i),2);
        agent2confU(:,i) = currA2C;
    end
    dupRemovalTime = toc(dupRemovalTime);
    fprintf('Done removing duplicates, elapsed time %f\n',dupRemovalTime);
    
    fprintf('the number of confs after removing non uniques is: %d\n',size(allConfigurationsU,2));
    agent2conf = agent2confU;
    allConfigurations = allConfigurationsU;
    
    confVal = target2Val' * allConfigurations;
    
    %model = 0;
    %outConf = 0;
    %AllConf = 0;
    %excelOut= 0;
    %return;
    
    solverTime = tic;
    %[model,outConf] = run_LP_Solve(allConfigurations,agent2conf,confVal,0);
    [model,outConf,optVal] = run_gurobi(allConfigurations,agent2conf,confVal,0);
    solverTime = toc(solverTime);
    fprintf('Done running solver, elapsed time %f\n',solverTime);
    AllConf = zeros(0,4);
    excelOut = zeros(0,5);
    for i=1:size(outConf,2)
        currConf = getRealConf(outConf(:,i),AgentInfo(i,1),AgentInfo(i,2),AgentInfo(i,3),0,currTargetID,targetsData);
        if (size(currConf,1) > 0) 
            AllConf = [AllConf ; (ones(size(currConf,1),1) * AgentInfo(i,5)) currConf];
            % build the excel output
            % best payload for the first mission
            compatible = Agent2sensor(AgentInfo(i,5),:) .* target2sensor(currConf(1,1),:);
            bestPayload = find(compatible==max(compatible));
            excelOut = [excelOut ; AgentInfo(i,5) currConf(1,1) bestPayload currConf(1,2:3)];
            for j=2:size(currConf,1)
                % if there is a gap - insert a "0" mission
                currFinish = excelOut(size(excelOut,1),5);
                newStart   = currConf(j,2);
                if (currFinish < (newStart - 0.001)) 
                    excelOut = [excelOut ; AgentInfo(i,5) 0 0 currFinish newStart];
                end
                compatible = Agent2sensor(AgentInfo(i,5),:) .* target2sensor(currConf(j,1),:);
                bestPayload = find(compatible == max(compatible));
                excelOut = [excelOut ; AgentInfo(i,5) currConf(j,1) bestPayload currConf(j,2:3)];
            end
        end
    end

    col_w = 11;  % Fixed column width in characters
    fr_n = 2;    % Number of fraction digits

    % Print header
    hdr_line = '| drone ID  | target ID |   start   |     end   ';
    fprintf('\n\nResults:\n%s\n', hdr_line)
    % Print values
    data_fmt = [repmat(['|%', int2str(col_w - 1), '.', int2str(fr_n), 'f '], 1, size(AllConf, 2)), '\n'];
    fprintf(data_fmt, AllConf')
    if (writeOutput)
        xlswrite(file,excelOut,'OutAssignment','A3');
    end
    
    % save stat
    allStat.val = optVal;
    allStat.runParam = runAmount;
    allStat.buildParam = buildAmount;
    allStat.solverTime = solverTime;
    allStat.confBuildTime = confBuildingTime;
    allStat.confDupRemovalTime = dupRemovalTime;
    allStat.inputParsingTime = parsingTime;
    allStat.allTargets = sumAllVals;
    
end