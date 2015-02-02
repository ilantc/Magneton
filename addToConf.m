function [ success,conf,confTimes] = addToConf(currConf,confTimes,targetID,agentTakeoffTime,agentFinishTime,speed,oldConfSize,currTargetID,targetsData)
    global target2TargetDistance;
    global missionLink;
    
    targetsData_BEGIN_COL       =4;
    targetsData_END_COL         =5;
    targetsData_DURATION_COL    =6;
    
    % global data for this function, derived from input
    numTargets = size(currConf,1);
    %fprintf('\t\tconf size %i, num of confs is %i\n',oldConfSize,size(currConf,2));
    success = 0;
    conf = 0;
    if (oldConfSize == 0)
        % flight time between targets
        flightTime = target2TargetDistance(currTargetID + 1,targetID + 1)/(speed*60*60);

        % start time for next target
        currStart  = max(agentTakeoffTime + flightTime,targetsData(targetID,targetsData_BEGIN_COL));

        % finishTime
        currFinish  = currStart + targetsData(targetID,targetsData_DURATION_COL);
        
        % output
        if ((currFinish <= agentFinishTime) && (currFinish <= targetsData(targetID,targetsData_END_COL)) ) 
            success                 = 1;
            conf                    = zeros(numTargets,1);
            conf(targetID)          = 1;
            confTimes(targetID,1)   = currStart;
            confTimes(targetID,2)   = currFinish;
        end
    else 

        % fprintf('\t\t\tconf finish time %i, confID %i\n',confFinishTime,confID);
        
        % flight time between targets
        flightTime = target2TargetDistance(find(currConf == oldConfSize) + 1,targetID + 1)/(speed*60*60);
        
        % calculate the begining of the last time segment in which scans one target
        firstAloneTime = confTimes(find(currConf == oldConfSize),1);
        for t=oldConfSize-1:-1:1
            tFinishTime = confTimes(find(currConf == t),2);
            if (tFinishTime > firstAloneTime) 
                firstAloneTime = tFinishTime;
                break;
            end
            firstAloneTime = confTimes(find(currConf == t),1);
        end
        
        % target window time start
        targetWinStartTime = targetsData(targetID,targetsData_BEGIN_COL);
        
        % calculate the earliest time in which we can do this target in
        % parallel with all the targets until the end of conf
        endOflastNonParallelableTarget = confTimes(find(currConf == oldConfSize),2);
        for t=oldConfSize:-1:1
            if (missionLink(targetID,find(currConf == t)) == 1)
                if (t == 1) 
                    endOflastNonParallelableTarget = confTimes(find(currConf == t),1);
                else
                    endOflastNonParallelableTarget = confTimes(find(currConf == (t-1)),2);
                end
            else
                break;
            end
        end
        
        % start time for next target
        earlyStart  = max([endOflastNonParallelableTarget + flightTime, firstAloneTime + flightTime,targetWinStartTime]);

        % finishTime
        currFinish  = earlyStart + targetsData(targetID,targetsData_DURATION_COL);

        % if feasible - add to all Confs
        finishBeforeAgent       = (currFinish <= agentFinishTime);
        finishBeforTarget       = (currFinish <= targetsData(targetID,targetsData_END_COL));
        finishBeforeOldConf     = (currFinish > confTimes(find(currConf == oldConfSize),2));
        finishAtOldConf         = (currFinish == confTimes(find(currConf == oldConfSize),2));
        
        if (finishBeforeAgent && finishBeforTarget &&  ( finishBeforeOldConf || (finishAtOldConf && ( targetID > find(currConf == oldConfSize) ) ) ));
            conf = currConf;
            conf(targetID) = oldConfSize + 1;
            confTimes(targetID,1) = earlyStart;
            confTimes(targetID,2) = currFinish;
            success = 1;
        end
    end
end