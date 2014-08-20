function [stat_matrix] = compare_different_H(files,stat_obj)
    num_of_h=3;
    stat_matrix=zeros(length(files),num_of_h+1);
    for k=1:length(files)
        allStat                                     = stat_obj.(sprintf('f_%s',files{k})).allStat;
        allConfigurations                       = stat_obj.(sprintf('f_%s',files{k})).allConfigurations;
        agent2conf                              = stat_obj.(sprintf('f_%s',files{k})).agent2conf;
        targetsData                              = stat_obj.(sprintf('f_%s',files{k})).targetsData;
        
        [val_h_staff,~]                         = Hiuristic_staff(agent2conf,allConfigurations,targetsData);
        [val_random_conf,~]               = new_start_point_to_hiuristic_2(agent2conf,allConfigurations,targetsData);
        [val_best_conf,~]   = new_start_point_to_hiuristic_3(agent2conf,allConfigurations,targetsData);
        
        stat_matrix(k,1)                        =  allStat.val;
        stat_matrix(k,2)                        =  val_random_conf;
        stat_matrix(k,3)                        =  val_best_conf;
        stat_matrix(k,4)                        =  val_h_staff;
    end
end
