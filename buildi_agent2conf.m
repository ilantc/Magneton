function [ agent2conf ] = buildi_agent2conf( targets_conf,drone_targets)
    % building agent2conf table : for each agent his configurations
    T=size(targets_conf,1);
    C=size(targets_conf,2); %num of conf
    N=size(drone_targets,1);
    
    targets_conf_bool = (targets_conf>=ones(N,C)); %N=size of drons, C= size of configurations
    temp=repmat(sum(targets_conf_bool),[T,1]);
    agent2conf=(drone_targets*targets_conf>=temp);      
end

