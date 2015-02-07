function [realConf] = getRealConf(conf,takeoffTime,flightTime,speed,v,currTargetID,targetsData,target2TargetDistance,missionLink)
    % targetsData col values
    ID_COL          =1;
    BEGIN_COL       =4;
    
    confSize = sum(conf);
    
    % sort the relevant targets data according to start time (this is a
    % heuristic for finding the feasible conf)
    sortedTargetsData = zeros(confSize,size(targetsData,2));
    for step=1:confSize
        stepMinID = 0;
        stepMinStartTime = 2500; % a large number
        for j=1:size(targetsData,1)
            currID = targetsData(j,ID_COL);
            % only  sort if this ID is in the conf
            if (conf(currID) == 1)
                % get the rows with this ID from sorted Matrix
                idWasSorted = sortedTargetsData(sortedTargetsData(:,ID_COL) == currID,:);
                % if we didnt schedule this target yet
                if ( size(idWasSorted,1) == 0)
                    currStartTime = targetsData(j,BEGIN_COL);
                    if (currStartTime < stepMinStartTime)
                        stepMinStartTime = currStartTime;
                        stepMinID = currID;
                    end
                end
            end
        end
        stepRealRow = targetsData(targetsData(:,ID_COL) == stepMinID,:);
        sortedTargetsData(step,:) = stepRealRow;
    end
    % output => col1 = targetID, col2 = start time, col3 = end time col4 =
    % val
    % realConf = findRealConf(sortedTargetsData,zeros(confSize,4),0,takeoffTime,takeoffTime + flightTime,1,speed,v);
    numTargets = size(targetsData,1);
    confTimes = zeros(numTargets,2);
    tempConf   = zeros(numTargets,1);
    realConf = findRealConfParralel(sortedTargetsData,zeros(confSize,4),tempConf,confTimes,0           ,takeoffTime,takeoffTime + flightTime,speed,numTargets,v,currTargetID,target2TargetDistance,missionLink);
              %findRealConfParralel(sortedTargetsData,currRealConf     ,tempConf,confTimes,currConfSize,takeoffTime,finishTime              ,speed,numTargets,v)
end
       
       
       