function [ cleanConf ] = cleanConfigurations( targets_conf,targets,BEGIN_COL,END_COL,DURATION_COL,max_target_per_drone,verbose)
    % removing all unpossible configurations.
    T=size(targets,1);
    C=size(targets_conf,2); %num of conf
    targets_conf_clean=zeros(1,C);

    BEGIN_COL_details       =1;
    END_COL_details         =2;
    DURATION_COL_details    =3;
    REAL_BEGIN_COL_details  =4;
    REAL_END_COL_details    =5;

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
        targets_options_checked=ones(1,size(targets_options,1));
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
            
            curr_option=targets_options(j,:) %the option we are now working on
            details=zeros(size(curr_option,2),5); % begin, end, duration, real_begin, real_end
            p = size(details)
            %details table will describe for each target the above info%

            for op=1:size(curr_option,2);
                details(op,BEGIN_COL_details)=targets(curr_option(op),BEGIN_COL)
                details(op,END_COL_details)=targets(curr_option(op),END_COL)
                details(op,DURATION_COL_details)=targets(curr_option(op),DURATION_COL)
            end

            details(1,REAL_END_COL_details)=details(1,BEGIN_COL_details)+details(1,DURATION_COL_details)
            
            
            %% check that there are no time wondow conflicts 
            if (size(curr_option,2) > 1) 
                for k=2:size(curr_option,2) %% max_target_per_drone;
                    %if (size(which_targets,2) > (k-1))
                        details(k,REAL_BEGIN_COL_details)= max(details(k-1,REAL_END_COL_details),details(k,BEGIN_COL_details))
                        details(k,REAL_END_COL_details)  = details(k,REAL_BEGIN_COL_details) + details(k,DURATION_COL_details)
                    %end
                    if ( details(k,REAL_END_COL_details)>details(k,END_COL_details) )
                        targets_options_checked(j)=0
                        %can break here.......
                    end
                end

                if (verbose)
                    %fprintf('a_end=%d, a_win_end =%d, b_end=%d, b_win_end =%d,c_end=%d, c_win_end =%d\n',a_end,a_win_end,b_end,b_win_end,c_end,c_win_end);
                    %fprintf('res = %d,j=%d,i=%d\n',targets_options_checked(j),j,i);
                end
            end 
        end
        if ( (sum(targets_options_checked)) >= 1)
            verbose && fprintf('sum targets options bugger than 1, i is %d',i);
            targets_conf_clean(i)=1;
        end
    end
    targets_conf_clean
    cleanConf = targets_conf(:,targets_conf_clean>0);
end