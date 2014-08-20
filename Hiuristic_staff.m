function [total_val,match]=Hiuristic_staff(agent2conf,all_conf,targetsData)

    global allConf;
    allConf = all_conf;
    VAL_COL=3;
        
    %update each conf with its value
    % where c is index of conf and t index of target
    for c=1:size(agent2conf,2)
        conf_val=0;
        for t=1:size(allConf,1)
            if allConf(t,c)>0
                conf_val=conf_val+(8-targetsData(t,VAL_COL));
            end
        end
        for a=1:size(agent2conf,1)
            if agent2conf(a,c)>0
                agent2conf(a,c)=conf_val;
            end
        end
    end
    
    % here we assign for each drone his best conf
    % can think of another starting point
    match=zeros(size(agent2conf,1),1);
    for a=1:size(agent2conf,1)
        maximum=find(agent2conf(a,:)==max(agent2conf(a,:)));
        match(a)= maximum(1); %first maximum
    end
    %match=b_match;
    total_val=calculate_assign_value(match);

    %another starting point
    hiuristic_match=new_start(agent2conf);
    val_hiuristic_first_match=calculate_assign_value(hiuristic_match);
  
    % check which is better starting point
    if val_hiuristic_first_match>    total_val
        total_val=val_hiuristic_first_match;
        match=hiuristic_match;
    end
        
    %the improvment
    continue_param=1;
    counter=0;
    new_match=match;
    while (continue_param && counter<5000)
        continue_param=0;
        for a=1:size(agent2conf,1)
        %for a=size(agent2conf,1):-1:1
            agent_conf=find(agent2conf(a,:)>0);
            for i=1:size(agent_conf,2) %run over all new possible confs
                new_match(a)=agent_conf(i);
                new_val= calculate_assign_value(new_match,targetsData);
                if new_val>total_val
                    total_val=new_val;
                    match=new_match;
                    continue_param=1;
                end
            end
        end
        counter=counter+1;
        total_val;
    end
end  

 function [val]=calculate_assign_value(match,targetsData)
    VAL_COL=3;
    global allConf;
    choosen_conf= allConf(:,match');
    targets=sum(choosen_conf,2)>0;
    val=(8-targetsData(:,VAL_COL)') * targets;     
 end
        
        
 function [match]=new_start(agent2conf)
     global allConf;
     match=zeros(size(agent2conf,1),1);
    for a=1:size(agent2conf,1)
        maximum=find(agent2conf(a,:)==max(agent2conf(a,:)));
        maximum=maximum(1);
        targets_of_best_conf=allConf(:,maximum);
        match(a)= maximum; %first maximum
        for c=1:size(allConf,2)
            if allConf(:,c)'*targets_of_best_conf>0
                agent2conf(:,c)=0;
            end
        end
    end
 end
 
%  function [best_match]=new_start_point_to_hiuristic_2(agent2conf,allConf)
%     num=1:size(agent2conf,1);
%     all_permutation=perms(num);
%     match=zeros(size(agent2conf,1),1);
%     best_match=match;
%     val_best=0;
%     for p=1:size(all_permutation,1)
%         permutation=all_permutation(p,:);
%         match=zeros(size(agent2conf,1),1);
%         agent2conf_temp=agent2conf;
%         for a=permutation
%             maximum=find(agent2conf_temp(a,:)==max(agent2conf_temp(a,:)));
%             maximum=maximum(1);
%             targets_of_best_conf=allConf(:,maximum);
%             match(a)= maximum;%first maximum
%             for c=1:size(allConf,2)
%                 if allConf(:,c)'*targets_of_best_conf>0
%                     agent2conf_temp(:,c)=0;
%                 end
%             end
%         end
%         new_val=calculate_assign_value(match)
%         if val_best<new_val
%             best_match=match;
%             val_best=new_val
%         end
%     end
%  end
%  