function [stat_matrix,value_progress] = compare_different_H(files,stat_obj,numofiter)
    num_of_h=5;
    stat_matrix=zeros(length(files),num_of_h+1);
    good_match=[];
    num_iter=10;
    for k=1:length(files)
        files(k)
        allStat                                     = stat_obj.(sprintf('f_%s',files{k})).allStat;
        allConfigurations                       = stat_obj.(sprintf('f_%s',files{k})).allConfigurations;
        agent2conf                              = stat_obj.(sprintf('f_%s',files{k})).agent2conf;
        targetsData                              = stat_obj.(sprintf('f_%s',files{k})).targetsData;
        
%%%%%%%%%%%%%%%%%%% compare best startpoint with different iteration
              [val_before,good_match]                   = new_start_point_to_hiuristic_2(agent2conf,allConfigurations,targetsData,num_iter);
%              [v15,match,v_p1]             = Hiuristic_staff_improved_random(agent2conf,allConfigurations,targetsData,0,good_match,15);
%              [v30,match,v_p2]             = Hiuristic_staff_improved_random(agent2conf,allConfigurations,targetsData,1,good_match,30);
%              [v50,match,v_p3]             = Hiuristic_staff_improved_random(agent2conf,allConfigurations,targetsData,2,good_match,50);
%              [v100,match,v_p4]             = Hiuristic_staff_improved_random(agent2conf,allConfigurations,targetsData,2,good_match,100);
%              [v200,match,v_p5]             = Hiuristic_staff_improved_random(agent2conf,allConfigurations,targetsData,2,good_match,200);
              [v300,match,v_p6]             = Hiuristic_staff_improved_random(agent2conf,allConfigurations,targetsData,2,good_match,numofiter);

%         stat_matrix(k,1)                        = val_before;
%         stat_matrix(k,2)                        = v15;
%         stat_matrix(k,3)                        = v30;
%         stat_matrix(k,4)                        = v50;
%         stat_matrix(k,5)                        = v100;  
%         stat_matrix(k,6)                        = v200;
%         stat_matrix(k,7)                        = v300;
%               value_progress.(sprintf('f_%s',files{k})).vp1=v_p1;
%              value_progress.(sprintf('f_%s',files{k})).vp2=v_p2;
%              value_progress.(sprintf('f_%s',files{k})).vp3=v_p3;
%              value_progress.(sprintf('f_%s',files{k})).vp4=v_p4;
%              value_progress.(sprintf('f_%s',files{k})).vp5=v_p5;
%              value_progress.(sprintf('f_%s',files{k})).vp6=v_p6;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            maxi=0;
            for i=1:num_iter
             [v0,~,v_p1,~,~]             = Hiuristic_staff_improved_random(agent2conf,allConfigurations,targetsData,1,[],numofiter);
             if v0>maxi
                 v=v0;
                 v_p=v_p1;
                 maxi=v0;
             end
            end
%              [v1,~,v_p2,~,FV1]             = Hiuristic_staff_improved_random(agent2conf,allConfigurations,targetsData,1,good_match,numofiter);
%              [v2,~,v_p3,~,FV2]             = Hiuristic_staff_improved_random(agent2conf,allConfigurations,targetsData,2,good_match,numofiter);
%          
              value_progress.(sprintf('f_%s',files{k})).vprand=v_p;
%              value_progress.(sprintf('f_%s',files{k})).vp2=v_p2;
%              value_progress.(sprintf('f_%s',files{k})).vp3=v_p3;
            value_progress.(sprintf('f_%s',files{k})).vp1=v_p6;

            
            
%         [v_segev_h,~]                             = segev_h(agent2conf,allConfigurations,targetsData);        
%         stat_matrix(k,1)                        = val_before;
        stat_matrix(k,2)                        = v300;
        stat_matrix(k,1)                        = v;
%         stat_matrix(k,3)                        = FV1;
%         stat_matrix(k,4)                        = v1;
%         stat_matrix(k,5)                        = FV2;
%         stat_matrix(k,6)                        = v2;



%         stat_matrix(k,2)                        =  v_segev_h;
%         stat_matrix(k,3)                        =  val_best_conf;
%         stat_matrix(k,4)                        =  val_h_staff;
    end
end
