function [ cleanConf ] = cleanConfigurations( targets_conf,targets,BEGIN_COL,END_COL,DURATION_COL,verbose)
    % removing all unpossible configurations.
    max_target_per_drone=3;
    T=size(targets,1);
    C=size(targets_conf,2); %num of conf
    targets_conf_clean=zeros(1,C);
    % run on all conf (num of cols of targets_conf)
    for i=1:C;
        counter=1;
        which_targets=zeros(1,max_target_per_drone);
        for t=1:T; %for each conf put in "which_targets" his targets.
            if targets_conf(t,i)==1;
                which_targets(counter)=t;
                counter=counter+1;
            end
        end
        which_targets = which_targets(which_targets > 0);
        targets_options=perms(which_targets);% all permotations of a configuration.
        targets_options_checked=zeros(1,size(targets_options,1));
        if (verbose)
            fprintf('cleanConf:  i=%d which_targets=%d\n',i);
            which_targets
            fprintf('targets_options =');
            targets_options
        end
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
            a_win_begin=targets(option(1),BEGIN_COL);%begin_column_in_targets = 4
            a_win_end=targets(option(1),END_COL);%begin_column_in_targets = 4
            t_a=targets(option(1),DURATION_COL);
            a_end=t_a+a_win_begin;
            
            if size(which_targets,2) > 1
                b_win_begin=targets(option(2),BEGIN_COL);%begin_column_in_targets = 4
                b_win_end=targets(option(2),END_COL);%begin_column_in_targets = 4
                b_begin=max(a_end,b_win_begin);
                t_b=targets(option(2),DURATION_COL);
                b_end=b_begin+t_b;
                    
            end
            if size(which_targets,2) > 2
                c_win_begin=targets(option(3),BEGIN_COL);%begin_column_in_targets = 4
                c_win_end=targets(option(3),END_COL);%begin_column_in_targets = 4
                c_begin=max(b_end,c_win_begin);
                t_c=targets(option(3),DURATION_COL);
                c_end=c_begin+t_c;
            end
            if ((c_end <= c_win_end) && (b_end <= b_win_end) && (a_end <= a_win_end));
                targets_options_checked(j)=1; 
            end
            if (verbose)
                fprintf('a_end=%d, a_win_end =%d, b_end=%d, b_win_end =%d,c_end=%d, c_win_end =%d\n',a_end,a_win_end,b_end,b_win_end,c_end,c_win_end);
                fprintf('res = %d,j=%d,i=%d\n',targets_options_checked(j),j,i);
            end
        end
        if ( (sum(targets_options_checked)) >= 1)
            verbose && fprintf('sum targets options bugger than 1, i is %d',i);
            targets_conf_clean(i)=1;
        end
    end
    targets_conf_clean;
    cleanConf = targets_conf(:,targets_conf_clean>0);
end