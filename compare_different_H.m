function [stat_matrix,v_p] = compare_different_H(files,stat_obj,numofiter)
    num_of_h=6;
    stat_matrix=zeros(length(files),num_of_h+1);
    %value_progress=[];
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
            %[v3,match,v_p]             = Hiuristic_staff_improved_random(agent2conf,allConfigurations,targetsData,0,good,100);
             [v15,match,v_p]             = Hiuristic_staff_improved_random(agent2conf,allConfigurations,targetsData,0,good_match,15);
             [v30,match,v_p]             = Hiuristic_staff_improved_random(agent2conf,allConfigurations,targetsData,1,good_match,30);
             [v50,match,v_p]             = Hiuristic_staff_improved_random(agent2conf,allConfigurations,targetsData,2,good_match,50);
             [v100,match,v_p]             = Hiuristic_staff_improved_random(agent2conf,allConfigurations,targetsData,2,good_match,100);
             [v200,match,v_p]             = Hiuristic_staff_improved_random(agent2conf,allConfigurations,targetsData,2,good_match,200);
             [v300,match,v_p]             = Hiuristic_staff_improved_random(agent2conf,allConfigurations,targetsData,2,good_match,300);
           %value_progress=[value_progress v_p];
             [v6,match,v_p]             = Hiuristic_staff_improved_random(agent2conf,allConfigurations,targetsData,2,[],numofiter);
            
            
%         [v_segev_h,~]                             = segev_h(agent2conf,allConfigurations,targetsData);        
        stat_matrix(k,1)                        = val_before;
        stat_matrix(k,2)                        = v15;
        stat_matrix(k,3)                        = v30;
        stat_matrix(k,4)                        = v50;
        stat_matrix(k,5)                        = v100;  
        stat_matrix(k,6)                        = v200;
        stat_matrix(k,7)                        = v300;

%         stat_matrix(k,2)                        =  v_segev_h;
%         stat_matrix(k,3)                        =  val_best_conf;
%         stat_matrix(k,4)                        =  val_h_staff;
    toc
    end
end
