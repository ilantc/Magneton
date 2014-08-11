function [lp,outConf,AgentInfo, allConfigurations, agent2conf, Agent2target, AllConf, excelOut, Agent2sensor, target2sensor] = main(file)
    
    global targetsData;
    global Agent2target;
    global target2TargetDistance;

    tic;
    % parse the input file
    [ Agent2sensor,target2sensor, AgentInfo, target2Val, target2TargetDistance ] = ParseInfile( file );
    Agent2target = Agent2sensor * target2sensor';
    targetsData  = read_excel_and_clean(file,'InMissions');
    numOfTargets = size(target2sensor,1);
    numOfDrones  = size(AgentInfo,1);
    
    allConfigurations = zeros(0,numOfTargets);
    agent2conf        = zeros(numOfDrones,0);
    
    fprintf('Done parsing infile ');
    toc;
    tic;
    % build the configuration per drone
    allConfs = RunSchedulAssignment(file);
    for (drone = 1 : numOfDrones) 
        % convert to matrix format
        currConfs = getConfMatrix(allConfs(drone).goodOptions2,numOfTargets);
        currConfs = [currConfs getConfMatrix(allConfs(drone).goodOptions3,numOfTargets)];
        currConfs = [currConfs getConfMatrix(allConfs(drone).goodOptions4,numOfTargets)];
        currConfs = [currConfs getConfMatrix(allConfs(drone).goodOptions5,numOfTargets)];
        allConfigurations = [allConfigurations currConfs];
        currAgent2conf = zeros(numOfDrones,size(currConfs,2));
        currAgent2conf(drone,:) = ones(1,size(currConfs,2));
        agent2conf = [agent2conf currAgent2conf];
        fprintf('done drone %i of %i\n',drone,numOfDrones);
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
    excelOut = zeros(0,5);
    for i=1:size(outConf,2)
        currConf = getRealConf(outConf(:,i),AgentInfo(i,1),AgentInfo(i,2),AgentInfo(i,3),0);
        if (size(currConf,1) > 0) 
            AllConf = [AllConf ; (ones(size(currConf,1),1) * AgentInfo(i,4)) currConf];
            % build the excel output
            % best payload for the first mission
            compatible = Agent2sensor(AgentInfo(i,4),:) .* target2sensor(currConf(1,1),:);
            bestPayload = find(compatible==max(compatible));
            excelOut = [excelOut ; i currConf(1,1) bestPayload currConf(1,2:3)];
            for j=2:size(currConf,1)
                % if there is a gap - insert a "0" mission
                currFinish = excelOut(size(excelOut,1),5);
                newStart   = currConf(j,2);
                if (currFinish < (newStart - 0.001)) 
                    excelOut = [excelOut ; i 0 0 currFinish newStart];
                end
                compatible = Agent2sensor(AgentInfo(i,4),:) .* target2sensor(currConf(j,1),:);
                bestPayload = find(compatible == max(compatible));
                excelOut = [excelOut ; i currConf(j,1) bestPayload currConf(j,2:3)];
            end
        end
    end

    col_w = 11;  % Fixed column width in characters
    fr_n = 2;    % Number of fraction digits

    % Print header
    hdr_line = '| drone ID  | target ID |   start   |     end   ';
    fprintf('\n\nResults:\n%s\n', hdr_line)
    % Print values
    data_fmt = [repmat(['|%', int2str(col_w - 1), '.', int2str(fr_n), 'f '], 1, size(AllConf, 2)), '\n'];
    fprintf(data_fmt, AllConf')
    %xlswrite(file,excelOut,'OutAssignment','A3');
    
    
    
    
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