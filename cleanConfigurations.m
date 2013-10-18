function [ targets_conf_clean ] = cleanConfigurations( targets_conf,targets)
    % removing all unpossible configurations.
    max_target_per_drone=3;
    T=size(targets,1);
    C=size(targets_conf,2); %num of conf
    targets_conf_clean=zeros(1,C);
    for i=1:C;
        counter=1;
        which_targets=zeros(1,max_target_per_drone);
        for t=1:T; %for each conf put in "which_targets" his targets.
            if targets_conf(i,t)==1;
                which_targets(1,counter)=t;
                counter=counter+1;
            end
        end
        targets_options=perms(which_targets);% all permotations of a configuration.
        targets_options_checked=ones(1,size(targets_options,1));
        for j=1:size(targets_options,1);
            c_end =0;
            c_win_end=0; 
            b_end =0;
            b_win_end=0; 
            
            option=targets_options(j,:); %the option we are now working on
            
            %now checking if option relevant.
            % "a" represent the first target in the specific order, "b" the
            %second and "c" the third
            %"a_win..." represents the end/begin time window
            a_win_begin=targets(option(1),begin_column_in_targets);%begin_column_in_targets = 4
            a_win_end=targets(option(1),end_column_in_targets);%begin_column_in_targets = 4
            t_a=a_win_end-a_win_begin;
            a_end=t_a+a_begin;
            
            if which_targets(2)~=0;
                b_win_begin=targets(option(2),begin_column_in_targets);%begin_column_in_targets = 4
                b_win_end=targets(option(2),end_column_in_targets);%begin_column_in_targets = 4
                b_begin=max(a_end,b_win_begin);
                t_b=b_win_end-b_win_begin;
                b_end=b_begin+t_b;
                    
            end
            if which_targets(3)~=0;
                c_win_begin=targets(option(3),begin_column_in_targets);%begin_column_in_targets = 4
                c_win_end=targets(option(3),end_column_in_targets);%begin_column_in_targets = 4
                c_begin=max(b_end,c_win_begin);
                t_c=c_win_end-c_win_begin;
                c_end=c_begin+t_c;
            end
            if ((c_end>c_win_end) || (b_end>b_win_end) || (a_end>a_win_end));
                targets_options_checked(j)=0; 
            end
        end
        if sum(targets_options_checked)>=1;
            targets_conf_clean(c)=1;
        end
    end
end