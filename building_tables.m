function [ output_args ] = building_tables( drone_sensor,targets)
%BUILDING_TABLES Summary of this function goes here
%   Detailed explanation goes here
    targets_sensor=(targets(:,1))';
    for i=1:N; %building the drone vs target table, drone at rows , N=size of drons
        for j=1:T; % T =size of targets
            if (drone_sensor(i,targets_sensor(j)));
                drone_targets(i,j)=1;
            else
                drone_targets(i,j)=0;
            end
        end
    end
    
    % now we build for each agent his configurations
    targets_conf_bool = (targets_conf>=ones(D,C)); %D=size of drons, C= size of configurations
    temp=repmat(sum(targets_conf_bool),[T,1]);
    agent2conf=(drone_targets*targets_conf>=temp);
    
    
    
    
                 
    
end

