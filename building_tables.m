function [ drone_targets ] = building_tables_1( drone_sensor,targets)
    N=size(drone_sensor,1);
    T=size(targets,1);
    drone_targets=ones(N,T);    
    targets_sensor=(targets(:,1))'; % first column is "mataad"
    for i=1:N; %building the drone vs target table, drone at rows , N=size of drons
        for j=1:T; % T =size of targets
            if (drone_sensor(i,targets_sensor(j)));
                drone_targets(i,j)=1;
            else
                drone_targets(i,j)=0;
            end
        end
    end
end
    
function [ targets_conf_clean ] = building_tables_2( targets_conf,targets)
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
                
            

function [ agent2conf ] = building_tables_3( targets_conf,drone_targets)
    % building agent2conf table : for each agent his configurations
    T=size(targets_conf,1);
    C=size(targets_conf,2); %num of conf
    N=size(drone_targets,1);
    
    targets_conf_bool = (targets_conf>=ones(N,C)); %N=size of drons, C= size of configurations
    temp=repmat(sum(targets_conf_bool),[T,1]);
    agent2conf=(drone_targets*targets_conf>=temp);      
end

