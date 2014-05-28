function [ allConfigurationsForBuild,allConfigurationsForRun ] = buildConfigurationsPerDroneBFS(lastLevelConfs,speed,agent,agentTakeoffTime,agentFinishTime,target2Val,amountForBuild,finalAmount)
    %% for all confs in lastLevelConfs - try to add an additional task to
    %% it
    
    %% globals
    global Agent2target;
    global target2TargetDistance;
    global targetsData;
    
    targetsData_BEGIN_COL       =4;
    targetsData_END_COL         =5;
    targetsData_DURATION_COL    =6;
    
    % global data for this function, derived from input
    numTargets = size(lastLevelConfs,1);
    oldConfSize = sum(lastLevelConfs(:,1) ~= 0);
    %fprintf('\t\tconf size %i, num of confs is %i\n',oldConfSize,size(lastLevelConfs,2));
    % output
    allConfigurations = zeros(numTargets,0);
    
    if (oldConfSize == 0)
        for targetID=1:numTargets
            % if this target is not in the current conf
            % and agent is able to sense it
            if (Agent2target(agent,targetID) ~= 0)

                % flight time between targets
                flightTime = target2TargetDistance(1,targetID + 1)/(speed*60*60);

                % start time for next target
                currStart  = max(agentTakeoffTime + flightTime,targetsData(targetID,targetsData_BEGIN_COL));

                % finishTime
                currFinish  = currStart + targetsData(targetID,targetsData_DURATION_COL);

                % if feasible - add to all Confs
                if ((currFinish <= agentFinishTime) && (currFinish <= targetsData(targetID,targetsData_END_COL)) )
                    newConf = zeros(numTargets,1);
                    newConf(targetID) = 1;
                    allConfigurations = [allConfigurations, newConf];
                end
            end
        end
    else 
        % try to expand all confs
        for confID=1:size(lastLevelConfs,2)

            % data for current conf
            currConf = lastLevelConfs(:,confID);
            [confFinishTime, lastTargetIndex] = getConfData(currConf,agentTakeoffTime,speed,oldConfSize,0);
           % fprintf('\t\t\tconf finish time %i, confID %i\n',confFinishTime,confID);
            % try to exapnd with every target
            for targetID=1:numTargets
                % if this target is not in the current conf
                % and agent is able to sense it
                if ((currConf(targetID) == 0) && (Agent2target(agent,targetID) ~= 0))

                    % flight time between targets
                    flightTime = target2TargetDistance(currConf(lastTargetIndex) + 1,targetID + 1)/(speed*60*60);

                    % start time for next target
                    currStart  = max(confFinishTime + flightTime,targetsData(targetID,targetsData_BEGIN_COL));

                    % finishTime
                    currFinish  = currStart + targetsData(targetID,targetsData_DURATION_COL);

                    % if feasible - add to all Confs
                    if ((currFinish <= agentFinishTime) && (currFinish <= targetsData(targetID,targetsData_END_COL)) )
                        newConf = currConf;
                        newConf(targetID) = oldConfSize + 1;
                        allConfigurations = [allConfigurations, newConf];
                    end
                end
            end
        end
    end
    if (size(allConfigurations,2) > 0 )
        [allConfigurationsForBuild,allConfigurationsForRun] = trimConfs(allConfigurations,target2Val,amountForBuild,finalAmount);
    else
        allConfigurationsForBuild = allConfigurations;
        allConfigurationsForRun = allConfigurations;
    end
end