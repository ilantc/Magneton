function [stat_matrix,v_p] = compare_different_H(files,stat_obj)
    num_of_h=2;
    stat_matrix=zeros(length(files),num_of_h+1);
    value_progress=[];
    for k=1:length(files)
        tic
        files(k)
        allStat                                     = stat_obj.(sprintf('f_%s',files{k})).allStat;
        allConfigurations                       = stat_obj.(sprintf('f_%s',files{k})).allConfigurations;
        agent2conf                              = stat_obj.(sprintf('f_%s',files{k})).agent2conf;
        targetsData                              = stat_obj.(sprintf('f_%s',files{k})).targetsData;
        
%         [val_h_staff,~]                               = Hiuristic_staff(agent2conf,allConfigurations,targetsData);
            [val_before,good_match]                   = new_start_point_to_hiuristic_2(agent2conf,allConfigurations,targetsData);
%         [val_best_conf,~]                             = new_start_point_to_hiuristic_3(agent2conf,allConfigurations,targetsData);
%             [v0,~]                                      = Hiuristic_staff_improved_random(agent2conf,allConfigurations,targetsData,0,0);
%             [v1,~]                                      = Hiuristic_staff_improved_random(agent2conf,allConfigurations,targetsData,1,0);
%             [v2,~]                                      = Hiuristic_staff_improved_random(agent2conf,allConfigurations,targetsData,2,0);
            [v3,match,v_p]             = Hiuristic_staff_improved_random(agent2conf,allConfigurations,targetsData,1,good_match);
            match
           
            
            
%         [v_segev_h,~]                             = segev_h(agent2conf,allConfigurations,targetsData);        
       stat_matrix(k,1)                        =  allStat.val;
       stat_matrix(k,2)                        = val_before;
%        stat_matrix(k,3)                        = v1;
%        stat_matrix(k,4)                        = v2;
       stat_matrix(k,3)                        = v3;
%         stat_matrix(k,2)                        =  v_segev_h;
%         stat_matrix(k,3)                        =  val_best_conf;
%         stat_matrix(k,4)                        =  val_h_staff;
    toc
    end
end
