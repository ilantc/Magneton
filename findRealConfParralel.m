function[RealConf] = findRealConfParralel(sortedTargetsData,currRealConf,tempConf,confTimes,currConfSize,takeoffTime,finishTime,speed,numTargets,v,currTargetID,targetsData,target2TargetDistance,missionLink)
    
    ID_COL          =1;
    VAL_COL         =3;
    DURATION_COL    =6;

    % if curr realConf is full, return it
    if (currConfSize == size(currRealConf,1))
        RealConf = currRealConf;
        return;
    end
    
    if v==1
        sortedTargetsData
        currRealConf
        currConfSize
        takeoffTime
        finishTime
        currTargetID
    end
    
    % find the next candidate, or return an empty conf to signal that no
    % one was found
    for i =1:size(sortedTargetsData,1)
        
        currID = sortedTargetsData(i,ID_COL);
        currWasScheduled = currRealConf(currRealConf(:,ID_COL) == currID,:);
        % if this one is already in the conf, skip it
        if (size(currWasScheduled,1) == 0) 
            % check if can schedule it next
            duration    = sortedTargetsData(i,DURATION_COL);
            [success,confNew,confTimesNew] = addToConf(tempConf,confTimes,currID,takeoffTime,finishTime,speed,currConfSize,currTargetID,targetsData,target2TargetDistance,missionLink);
            if v
                success
            end
            if (success)
                % add this row, and call the recursive function again
                tempCurrRealConf = currRealConf;
                val              = sortedTargetsData(i,VAL_COL);
                val              = 8 - val;
                tempCurrRealConf(currConfSize + 1,:) = [currID,confTimesNew(currID,1),confTimesNew(currID,2),val];
                % recursive call
                foundConf       = findRealConfParralel(sortedTargetsData,tempCurrRealConf,confNew,confTimesNew,currConfSize + 1,takeoffTime,finishTime,speed,numTargets,v,currTargetID,targetsData,target2TargetDistance,missionLink);
                % if found conf is not good, continue, else - return it
                if (size(foundConf,1) > 0 )
                    RealConf = foundConf;
                    return
                end
            end
        end
    end
    % if we got here - there is no feasible conf, return an empty matrix
    RealConf = zeros(0,0);
end