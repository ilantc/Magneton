function [lp,outConf,AgentInfo] = main(file)
    
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
        currConfs  = unique(currConfs', 'rows');
        currConfs  = currConfs';
        allConfigurations = [allConfigurations currConfs];
        currAgent2conf = zeros(numOfDrones,size(currConfs,2));
        currAgent2conf(drone,:) = ones(1,size(currConfs,2));
        agent2conf = [agent2conf currAgent2conf];
    end
    

    confVal = target2Val' * allConfigurations;
    
    fprintf('the number of confs is: %d\n',size(allConfigurations,2));
    b = unique(allConfigurations', 'rows');
    fprintf('the number of unique confs is: %d\n',size(b,1));
    
    fprintf('Done building Confs ');
    toc;
    tic;
    [lp,outConf] = run_LP_Solve(allConfigurations,agent2conf,confVal,0);
    fprintf('Done running lp ');
    toc;
    AllConf = zeros(0,4);
    for i=1:size(outConf,2)
        currConf = getRealConf(outConf(:,i),AgentInfo(i,1),AgentInfo(i,2));
        AllConf = [AllConf ; (ones(size(currConf,1),1) * i) currConf];
    end

    col_w = 11;  % Fixed column width in characters
    fr_n = 2;    % Number of fraction digits

    % Print header
    hdr_line = '| drone ID  | target ID |   start   |     end   ';
    fprintf('\n\nResults:\n%s\n', hdr_line)
    % Print values
    data_fmt = [repmat(['|%', int2str(col_w - 1), '.', int2str(fr_n), 'f '], 1, size(AllConf, 2)), '\n'];
    fprintf(data_fmt, AllConf')
    
    
    
    
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