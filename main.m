function [lp] = main(file)
    
    tic;
    % parse the input file
    [ Agent2sensor,target2sensor, AgentInfo, target2Val ] = ParseInfile( file );
    
    global targetsData;
    targetsData  = xlsread(file,'InMissions');
    numOfTargets = size(target2sensor,1);
    numOfDrones  = size(AgentInfo,1);
    
    allConfigurations = zeros(0,numOfTargets);
    agent2conf        = zeros(numOfDrones,0);
    
    fprintf('Done parsing infile ');
    toc;
    tic;
    % build the configuration per drone
    for (drone = 1 : numOfDrones) 
        currConfs  = buildConfigurationsPerDrone(zeros(numOfTargets,1), AgentInfo(drone,2),AgentInfo(drone,1) );
        allConfigurations = [allConfigurations currConfs];
        currAgent2conf = zeros(numOfDrones,size(currConfs,2));
        currAgent2conf(drone,:) = ones(1,size(currConfs,2));
        agent2conf = [agent2conf currAgent2conf];
    end
    

    confVal = target2Val' * allConfigurations;
    
    fprintf('the number of confs is: %d\n',size(allConfigurations,2));
    fprintf('Done building Confs ');
    toc;
    tic;
    lp                              = run_LP_Solve(allConfigurations,agent2conf,confVal,0);
    fprintf('Done running lp ');
    toc;
    tic;
    %agent2targets                   = build_drone_targets( targets,agent2sensors,verbose);
    %allConf                         = getAllConfigurations( numOfTargets,maxNumOfTargetInConfiguration,verbose );
    %size(allConf)
    %verbose && xlswrite('C:\Magneton\temp.xls',allConf','temp');
    %cleanConf                       = cleanConfigurations( allConf,targets,BEGIN_COL,END_COL,DURATION_COL,maxNumOfTargetInConfiguration,maxFlightTime,verbose);
    %verbose && xlswrite('C:\Magneton\temp.xls',cleanConf','temp2');
    %confVal                         = targets(:,CONF_VAL_COL)' * cleanConf;
    %agent2conf                      = build_agent2conf( cleanConf,agent2targets,verbose);
    %lp                              = run_LP_Solve(cleanConf,agent2conf,confVal,verbose);
end