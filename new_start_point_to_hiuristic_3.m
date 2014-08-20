  function [match,val]=new_start_point_to_hiuristic_3(agent2conf,all_conf)
  
  %%%% calculate all conf val
    global targetsData;
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
    permutation=zeros(1,size(agent2conf,1));
    %%%% find best perm
    temp_agent2conf=agent2conf;
    for k=1:size(temp_agent2conf,1)
        [num, idx] = max(temp_agent2conf(:))
        [x,y] = ind2sub(size(temp_agent2conf),idx)
        permutation(k)=x;
        temp_agent2conf(x,:)=0;
        temp_agent2conf(:,y)=0;
    end
    if sum(permutation)~=sum(1:size(temp_agent2conf,1))
        permutation=randperm(size(temp_agent2conf,1));
    end
          
    %%%%
    agent2conf_temp=agent2conf;
    match=zeros(size(agent2conf,1),1);
    for a=permutation
        maximum=find(agent2conf_temp(a,:)==max(agent2conf_temp(a,:)));
        maximum=maximum(1);
        targets_of_best_conf=allConf(:,maximum);
        match(a)= maximum;%first maximum
        for c=1:size(allConf,2)
            if allConf(:,c)'*targets_of_best_conf>0
                agent2conf_temp(:,c)=0;
            end
        end
    end
     val=calculate_assign_value(match);   
 end

 function [val]=calculate_assign_value(match)
    VAL_COL=3;
    global targetsData;
    global allConf;
    choosen_conf= allConf(:,match');
    targets=sum(choosen_conf,2)>0;
    val=(8-targetsData(:,VAL_COL)') * targets;     
 end
