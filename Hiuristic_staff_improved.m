function [total_val,match,agent2conf_new]=Hiuristic_staff_improved(agent2conf,all_conf,targetsData)
% here we choose randomly from the maximum of the configuration.
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
    agent2conf_new=agent2conf;
    % here we assign for each drone his best conf
    % can think of another starting point
    match=zeros(size(agent2conf,1),1);
    for a=1:size(agent2conf,1)
        maximum=find(agent2conf(a,:)==max(agent2conf(a,:)));
        match(a)= maximum(1); %first maximum
    end
    %match=b_match;
    total_val=calculate_assign_value(match,targetsData);

%     %another starting point
%     hiuristic_match=new_start(agent2conf);
%     val_hiuristic_first_match=calculate_assign_value(hiuristic_match,targetsData);
  
%     % check which is better starting point
%     if val_hiuristic_first_match>    total_val
%         total_val=val_hiuristic_first_match;
%         match=hiuristic_match;
%     end
%         
    %the improvment
    agents=1:size(agent2conf,1);
    continue_param=1;
    counter=0;
    new_match=match;
    while (continue_param && counter<20)
        continue_param=0;
        for a=1:size(agent2conf,1)
        %for a=size(agent2conf,1):-1:1
            agent_conf=agent2conf(a,:);
            max_index=find(agent_conf==max(agent_conf(:)));
            choosen_index=randsample(max_index,1);
            size(choosen_index)
            [x,y] = ind2sub(size(agent_conf),choosen_index);
            new_match(a)=y;
            new_val= calculate_assign_value(new_match,targetsData);
            if new_val>=total_val
                total_val=new_val;
                match=new_match;
            end
            continue_param=1;
        end
        counter=counter+1;
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