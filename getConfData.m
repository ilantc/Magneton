function [confFinishTime, lastTargetIndex] = getConfData(currConf,agentTakeoffTime,speed,oldConfSize,v)
    
    %% globals
    global target2TargetDistance;
    global targetsData;
  
    targetsData_BEGIN_COL       =4;
    targetsData_DURATION_COL    =6;
    
    % inital data
    currTime = agentTakeoffTime;
    currTarget = 0;
    if (v) 
        fprintf('\t\t\t\tcurrTarget %i, currTime %10.2f\n',currTarget,currTime);
    end
    for i=1:oldConfSize
        ithTarget = find(currConf == i);
        flightTime = target2TargetDistance(currTarget + 1,ithTarget + 1)/(speed*60*60);
        ithTargetStart = max(targetsData(ithTarget,targetsData_BEGIN_COL),currTime + flightTime);
        currTime = ithTargetStart + targetsData(ithTarget,targetsData_DURATION_COL);
        currTarget = ithTarget;
        if (v) 
            fprintf('\t\t\t\tcurrTarget %i, currTime %10.2f, targetStart %10.2f\n',currTarget,currTime,ithTargetStart);
        end
    end
    lastTargetIndex = find(currConf == oldConfSize);
    confFinishTime = currTime;
end