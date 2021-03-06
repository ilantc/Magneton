function [total_val,match,value_progress,numOfIterBeforebreake,first_val]=Hiuristic_staff_improved_random(agent2conf,all_conf,targetsData,start_point_option,start_match,numofiter)
% here we choose randomly from the list  of the configuration that gives greater value than current match.
    tic
    VAL_COL=3;
    numOfIterBeforebreake=-1;
    value_progress=[];
    global allConf;
    allConf = all_conf;    
%  Update each conf with its value. where c is index of conf and t index of target
%%%%%%%%%%%%%%%%%%%%%%%%
    if size(start_match,1)~=size(agent2conf,1)
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
    end
%%%%%%%%%%%%%%%%%%%%%%
    if size(start_match,1)~=size(agent2conf,1)
        switch(start_point_option)
            case 0
                    match=greedy_start(agent2conf);
            case 1
                    match=random_start(agent2conf);
            otherwise
                    match=greedy_random_start(agent2conf);
        end
    else
        match=start_match;
    end
   total_val=calculate_assign_value(match,targetsData);
   first_val=total_val;
%%%%%%%%%%%%%%%%%%%%%%%
    agents=randperm(size(agent2conf,1));
    counter=0;
    numOfAgentToSample=0;
    total_number_of_iteration=size(agent2conf,1)*numofiter;
    while (numOfAgentToSample <total_number_of_iteration)
        counter=counter+1;
        numOfAgentToSample=numOfAgentToSample+1;
        agent=randsample(agents,1);
        new_match=match;
        better_match=[];
        available_conf=find(agent2conf(agent,:)>0);
        value_progress = [value_progress , total_val];
        for c=1:size(available_conf,2)
            new_match(agent)=available_conf(c);
            new_val= calculate_assign_value(new_match,targetsData);
            if new_val>=total_val
                better_match=[better_match , available_conf(c)];
            end
           if new_val>total_val
                counter=0;
           end
        end
        if  size(better_match,2)~=0 % need to change to size(better_match,2)~=1 "if gadolshave"
            if size(better_match,2)~=1
                choosen_index=randsample(better_match,1);
            else
                choosen_index=better_match(1);
            end
            match(agent)=choosen_index;   
            total_val= calculate_assign_value(match,targetsData);
        end
        if (counter>size(agents,2)*100)
            numOfIterBeforebreake=numOfAgentToSample;
            break
        end
    end
    toc
end

  

 
 function [match]=greedy_start(agent2conf) 
    match=zeros(size(agent2conf,1),1);
    for a=1:size(agent2conf,1)
        maximum=find(agent2conf(a,:)==max(agent2conf(a,:)));
        match(a)= maximum(1); %first maximum
    end
  end
 
 function [match]=random_start(agent2conf) 
    match=randsample(size(agent2conf,2),size(agent2conf,1));
 end
 
  
 function [match]=greedy_random_start(agent2conf) 
    match=zeros(size(agent2conf,1),1);
    for a=1:size(agent2conf,1)
        maximum=find(agent2conf(a,:)==max(agent2conf(a,:)));
        match(a)= randsample(maximum,1);
    end
  end