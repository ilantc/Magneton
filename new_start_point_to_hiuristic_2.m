  function [val_best,best_match]=new_start_point_to_hiuristic_2(agent2conf,all_conf,targetsData)
  tic
  %%%% calculate all conf val
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
    %%%%
    num_of_iter=100;
    num=size(agent2conf,1);
    all_permutation=zeros(num_of_iter,num);
    for i=1:num_of_iter
        all_permutation(i,:)= randperm(num);
    end
    match=zeros(size(agent2conf,1),1);
    best_match=match;
    val_best=0;
    counter=0;
    for p=1:size(all_permutation,1)
        permutation=all_permutation(p,:);
        match=zeros(size(agent2conf,1),1);
        agent2conf_temp=agent2conf;
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
        new_val=calculate_assign_value(match,targetsData);
        if val_best<=new_val
            best_match=match;
            val_best=new_val;
            best_perm=permutation;
            counter=counter+1;
        end
    end
    toc
 end

 function [val]=calculate_assign_value(match,targetsData)
    VAL_COL=3;
    global allConf;
    choosen_conf= allConf(:,match');
    targets=sum(choosen_conf,2)>0;
    val=(8-targetsData(:,VAL_COL)') * targets;     
 end
