function [lp] = main(file,targets,agent2sensors)
    if nargin == 1 
        targets                     = xlsread(file,'targets');
        agent2sensors               = xlsread(file,'agent2sensors');    
    end
        
    verbose = 1;
    
    CONF_VAL_COL                    = 5;
    BEGIN_COL                       = 3;
    END_COL                         = 4;
    DURATION_COL                    = 2;
    maxNumOfTargetInConfiguration   = 3; % as defined (maybe should be input)
    
    numOfTargets                    = size(targets,1);
    agent2targets                   = build_drone_targets( targets,agent2sensors,verbose);
    allConf                         = getAllConfigurations( numOfTargets,maxNumOfTargetInConfiguration,verbose );
    size(allConf)
    verbose && xlswrite('C:\Magneton\temp.xls',allConf','temp');
    cleanConf                       = cleanConfigurations( allConf,targets,BEGIN_COL,END_COL,DURATION_COL,maxNumOfTargetInConfiguration,1);
    verbose && xlswrite('C:\Magneton\temp.xls',cleanConf','temp2');
    confVal                         = targets(:,CONF_VAL_COL)' * cleanConf;
    agent2conf                      = build_agent2conf( cleanConf,agent2targets,verbose);
    lp                              = run_LP_Solve(cleanConf,agent2conf,confVal,verbose);
end