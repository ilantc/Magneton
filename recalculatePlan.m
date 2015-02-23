function [] = recalculatePlan(buildAmount,runAmount,writeOutput,AgentInfo,Agent2sensor,target2sensor, Agent2target,excelOut,targetsData,target2Val,currTime,target2TargetDistance,missionLink,oldAllConf)
    [agent2location, completedTargets, targetsInProcess] = readExcelOut(excelOut,currTime);
    [target2sensor,Agent2target,targetsData,target2Val,target2TargetDistance,missionLink]=updateTargets(completedTargets,targetsInProcess,target2sensor,Agent2target,targetsData,target2Val,target2TargetDistance,missionLink);
    [AgentInfo]=updateAgentInfo(agent2location,currTime,AgentInfo);
    [agent2location]=agent2locationUpdatedTargets(agent2location,completedTargets,size(AgentInfo,1));
    
 %   <build all confs>
    numOfTargets      = size(targetsData,1);
    numOfDrones       = size(AgentInfo,1);
    allConfigurations = zeros(0,numOfTargets);
    agent2conf        = zeros(numOfDrones,0);
    confBuildingTime  = tic;
    for drone = 1:numOfDrones
        %fprintf('calculating confs for drone %i of %i (agentID is %i)\n',drone,numOfDrones,AgentInfo(drone,4));
        agentFlightTime  = AgentInfo(drone,2);
        agentTakeoffTime = AgentInfo(drone,1);
        speed            = AgentInfo(drone,3);
        agentID          = AgentInfo(drone,5);
        currConfs        = zeros(numOfTargets,1);
        confTimes        = zeros(numOfTargets,2,0);
        allAgentConfs    = currConfs;
        droneStat        = {};
        currTargetID     = 0;
        if isfield(agent2location,sprintf('a%d',agentID))
            currTargetID = agent2location.(sprintf('a%d',agentID));
        end
        for confSize=1:12
            %fprintf('\tconf size %i\n',confSize - 1);
            if (size(currConfs,2) > 0 )
                confBuildTime = tic;          
                [currConfs,confsForRun,confTimes,confStat]  = buildConfigurationsPerDroneBFS(currConfs,confTimes,speed,agentID,agentTakeoffTime,agentFlightTime +agentTakeoffTime,target2Val,Agent2target,targetsData,buildAmount,runAmount,currTargetID,target2TargetDistance,missionLink);
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
%     % removing duplicate confs
%     dupRemovalTime = tic;
%     [allConfigurationsU,~,Iu] = unique(allConfigurations','rows','stable');
%     allConfigurationsU = allConfigurationsU';
%     agent2confU = zeros(numOfDrones,size(allConfigurationsU,2));
%     for i=1:max(Iu)
%         % a col vector which indicates which agent can perform this conf
%         currA2C = sum(agent2conf(:,Iu == i),2);
%         agent2confU(:,i) = currA2C;
%     end
%     dupRemovalTime = toc(dupRemovalTime);

    dupRemovalTime = tic;
    allConfigurationsU = allConfigurations(:,1);
    agent2confU        = agent2conf(:,1);
    for i=2:size(allConfigurations,2)
        isU = 1;
        for j=1:size(allConfigurationsU,2)
            if allConfigurations(:,i) == allConfigurationsU(:,j)
                agent2confU(:,j) = agent2confU(:,j) + agent2conf(:,i);
                isU = 0;
                break;
            end
        end
        if isU == 1
            allConfigurationsU = [allConfigurationsU,allConfigurations(:,i)];
            agent2confU = [agent2confU,agent2conf(:,i)];
        end
    end
    fprintf('Done removing duplicates ');
    toc(dupRemovalTime);
    fprintf('Done removing duplicates, elapsed time %f\n',dupRemovalTime);
    
    fprintf('the number of confs after removing non uniques is: %d\n',size(allConfigurationsU,2));
    agent2conf = agent2confU;
    allConfigurations = allConfigurationsU;
    confVal = target2Val' * allConfigurations;
    
    
  %  <call solver>
    solverTime = tic;
    %[model,outConf] = run_LP_Solve(allConfigurations,agent2conf,confVal,0);
    [~,outConf,optVal] = run_gurobi(allConfigurations,agent2conf,confVal,0);
    solverTime = toc(solverTime);
    fprintf('Done running solver, elapsed time %f\n',solverTime);
    AllConf = zeros(0,4);
    excelOut = zeros(0,5);
    for i=1:size(outConf,2)
        currTargetID = 0;
        if isfield(agent2location,sprintf('a%d',AgentInfo(i,5)))
            currTargetID = agent2location.(sprintf('a%d',AgentInfo(i,5)));
        end

        currConf = getRealConf(outConf(:,i),AgentInfo(i,1),AgentInfo(i,2),AgentInfo(i,3),0,currTargetID,targetsData,target2TargetDistance,missionLink);
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
  
    %  <Result>
    % Print header
    hdr_line = '| drone ID  | target ID |   start   |     end   ';
    data_fmt = [repmat(['|%', int2str(col_w - 1), '.', int2str(fr_n), 'f '], 1, size(AllConf, 2)), '\n'];
    fprintf('\n\nold results:\n%s\n', hdr_line)
    fprintf(data_fmt,oldAllConf')
    
    fprintf('\n\nResults:\n%s\n', hdr_line)
    % Print values
    fprintf(data_fmt, AllConf')
    if (writeOutput)
        xlswrite(file,excelOut,'OutAssignment','A3');
    end
    sumAllVals = sum(target2Val);
    maxVal = min(sumAllVals,maxValH1(Agent2target,targetsData,AgentInfo,target2Val));
    fprintf('total value = %d, Best heuristic value = %d\n',sumAllVals,maxVal);
    % save stat
    allStat.val = optVal;
    allStat.runParam = runAmount;
    allStat.buildParam = buildAmount;
    allStat.solverTime = solverTime;
    allStat.confBuildTime = confBuildingTime;
    allStat.confDupRemovalTime = dupRemovalTime;
   % allStat.inputParsingTime = parsingTime;
    allStat.allTargets = sumAllVals;    
end

%%
function [newID]= newTargetID(ID,completedTargets)
    counter=0;
    for i=1:size(completedTargets,2)  
        completedID=completedTargets(i);
        if completedID<ID
            counter=counter+1;
        end   
    end
    newID=ID-counter;
end

function [agent2location]=agent2locationUpdatedTargets(agent2location,completedTargets,Nagents)
    for i=1:Nagents
         if isfield(agent2location,sprintf('a%d',i))
            agent2location.(sprintf('a%d',i))=newTargetID(agent2location.(sprintf('a%d',i)),completedTargets);
         end
    end
end

 function [target2sensor,Agent2target,targetsData,target2Val,target2TargetDistance,missionLink] = updateTargets(completedTargets,targetsInProcess,target2sensor,Agent2target,targetsData,target2Val,target2TargetDistance,missionLink)
     
     % update targets time and Agent2target
     for t=1:size(targetsData,1)
         if isfield(targetsInProcess,sprintf('t%d',t))
             targetsData(t,6) = targetsData(t,6) - targetsInProcess.(sprintf('t%d',t)).elapsed;
             Agent2target(targetsInProcess.(sprintf('t%d',t)).agent,:) = zeros(1,size(targetsData,1));
             Agent2target(targetsInProcess.(sprintf('t%d',t)).agent,t) = 1;
         end
     end
     
     target2sensor(completedTargets,:)          =[];
     Agent2target(:,completedTargets)           =[];
     target2Val(completedTargets,:)             =[];
     target2TargetDistance(completedTargets+1,:)=[]; % check if need to add +1 
     target2TargetDistance(:,completedTargets+1)=[]; % check if need to add +1
     missionLink(:,completedTargets)            =[];
     missionLink(completedTargets,:)            =[];
     targetsData(completedTargets,:)            =[];
     new_targets=1:size(targetsData,1);
     targetsData(:,1)=new_targets';
 end
  
 function [AgentInfo]=updateAgentInfo(agent2location,currTime,AgentInfo)
    agentsNeedChange=[];
    for i=1:size(AgentInfo,1)
        currAgent=AgentInfo(i,5); % 5 is agent id 
         if isfield(agent2location,sprintf('a%d',currAgent))
            agentsNeedChange=[agentsNeedChange,currAgent];
         end
    end
    for i=1:size(agentsNeedChange,2)
        agentID=agentsNeedChange(i);                               %notice that ID in AgentInfo in descending order
        AgentInfo(agentID,2)=max(0,AgentInfo(agentID,2)-currTime); % 2 is flight time
        AgentInfo(agentID,1)=currTime;                             % 1 is takeoff time
    end
 end
 

