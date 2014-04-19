function [ allConfigurations ] = buildConfigurationsPerDrone(currConf, timeLeft,currTime,speed, agent, lastTargetVisited,v )
    
    % targetsData col values
    ID_COL          =1;
    BEGIN_COL       =4;
    END_COL         =5;
    DURATION_COL    =6;
    global targetsData;
    global Agent2target;
    global target2TargetDistance;
    n_targets =size(targetsData,1);
    if (timeLeft <= 0)
        allConfigurations = currConf;
    else
        
        % flight time from last target to all targets
        flightTime = (target2TargetDistance(lastTargetVisited,:)/(speed*60*60))';
        flightTime = flightTime(2:size(flightTime));
        
        % get all rows with start time > curr time
        currRows = (targetsData(:,END_COL)-targetsData(:,DURATION_COL)-flightTime >= currTime);
        
        % remove conf that already exist in currConf
        currRows = currRows & (~ currConf);
        
        % get all rows that are possible to perform
        % caluculate actual start time (including flight time)
        startTime = targetsData(:,BEGIN_COL);
        arrivalTime = currTime + flightTime;
        realStart = max(arrivalTime ,startTime);
        % currRows = currRows & ( (targetsData(:,DURATION_COL) + max(currTime,targetsData(:,BEGIN_COL)) - currTime) <= timeLeft) );
        currRows = currRows & ( (targetsData(:,DURATION_COL) + realStart - currTime) <= timeLeft) ;

        currData = targetsData(currRows,:);
        allConfigurations = zeros(n_targets,0);

        for i=1:size(currData,1)
            currConfig = currConf;
            currID = currData(i,ID_COL);
            % only add this target if this agent is able to sense it
            if (Agent2target(agent,currID) ~= 0)
                flightTime = target2TargetDistance(lastTargetVisited,currID + 1)/(speed*60*60);
                currStart  = max(currTime + flightTime,currData(i,BEGIN_COL));
                % update newFinish with flying time
                newFinish  = currStart + currData(i,DURATION_COL);
                % update time left
                newTimeLeft = timeLeft - (newFinish - currTime);
                if (newTimeLeft >= 0)
                    currConfig(currID) = 1;
                    allConfigurations = [allConfigurations, buildConfigurationsPerDrone(currConfig,newTimeLeft,newFinish, speed, agent, currID + 1,v )];
                end
            end
        end
        allConfigurations = [allConfigurations , currConf];
    end
end    

