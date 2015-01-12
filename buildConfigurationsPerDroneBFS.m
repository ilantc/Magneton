function [ allConfigurationsForBuild,allConfigurationsForRun,allConfTimes,confStat] = buildConfigurationsPerDroneBFS(lastLevelConfs,lastLevelTimes,speed,agent,agentTakeoffTime,agentFinishTime,target2Val,amountForBuild,finalAmount,currTargetID)
    %% for all confs in lastLevelConfs - try to add an additional task to
    %% it
    global Agent2target;
    % global data for this function, derived from input
    numTargets = size(lastLevelConfs,1);
    oldConfSize = sum(lastLevelConfs(:,1) ~= 0);
    fprintf('\t\tconf size %i, num of confs is %i\n',oldConfSize,size(lastLevelConfs,2));
    % output
    allConfigurations = zeros(numTargets,0);
    allConfTimes      = zeros(numTargets,2,0);
    
    if (oldConfSize == 0)
        for targetID=1:numTargets
            % if this target is not in the current conf
            % and agent is able to sense it
            if (Agent2target(agent,targetID) ~= 0)
                
                [success,newConf,confTimes] = addToConf(zeros(numTargets,0),zeros(numTargets,2),targetID,agentTakeoffTime,agentFinishTime,speed,oldConfSize,currTargetID);
                if (success)
                        allConfigurations = [allConfigurations, newConf];
                        allConfTimes(:,:,size(allConfTimes,3)+1) = confTimes;
                end
            end
        end
    else 
        % try to expand all confs
        for confID=1:size(lastLevelConfs,2)

            % data for current conf
            currConf = lastLevelConfs(:,confID);
            currTimes = lastLevelTimes(:,:,confID);
            % try to exapnd with every target
            for targetID=1:numTargets
                % if this target is not in the current conf
                % and agent is able to sense it
                if ((currConf(targetID) == 0) && (Agent2target(agent,targetID) ~= 0))
                    
                    [success,newConf,confTimes] = addToConf(currConf,currTimes,targetID,agentTakeoffTime,agentFinishTime,speed,oldConfSize,0);
                    
                    % if feasible - add to all Confs
                    if (success)
                        allConfigurations = [allConfigurations, newConf];
                        allConfTimes(:,:,size(allConfTimes,3)+1) = confTimes;
                    end
                end
            end
        end
    end
    if (size(allConfigurations,2) > 0 )
        [allConfigurationsForBuild,allConfigurationsForRun,allConfTimes,confStat] = trimConfs(allConfigurations,allConfTimes,target2Val,amountForBuild,finalAmount);
    else
        allConfigurationsForBuild = allConfigurations;
        allConfigurationsForRun = allConfigurations;
        confStat = [];
    end
end