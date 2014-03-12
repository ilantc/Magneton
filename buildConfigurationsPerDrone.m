function [ allConfigurations ] = buildConfigurationsPerDrone(currConf, timeLeft,currTime )
    
    % targetsData col values
    ID_COL          =1;
    BEGIN_COL       =4;
    END_COL         =5;
    DURATION_COL    =6;
    global targetsData;
    n_targets =size(targetsData,1);
    if (timeLeft <= 0)
        allConfigurations = currConf;
    else

        % get all rows with start time > curr time
        currRows = ((targetsData(:,END_COL)-targetsData(:,DURATION_COL) >= currTime) & ( (targetsData(:,DURATION_COL) + max(currTime,targetsData(:,BEGIN_COL)) - currTime) <= timeLeft) );

        % remove conf that already exist in currConf
        currRows = currRows & (~ currConf);

        currData = targetsData(currRows,:);
        allConfigurations = zeros(n_targets,0);

        for i=1:size(currData,1)
            currConfig = currConf;
            currID = currData(i,ID_COL);
            currConfig(currID) = 1;
            currStart = max(currTime,targetsData(i,BEGIN_COL));
            newFinish = currStart + targetsData(i,DURATION_COL);
            newTimeLeft = timeLeft - (newFinish - currTime);
            allConfigurations = [allConfigurations, buildConfigurationsPerDrone(currConfig,newTimeLeft,newFinish)];
        end
        allConfigurations = [allConfigurations , currConf];
    end
end    

