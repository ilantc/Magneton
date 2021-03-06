function [ agent2conf ] = build_agent2conf( targets_conf,drone_targets,verbose)

    
    if (verbose) 
        fprintf('\nentered build_agent2conf');
    end


    % building agent2conf table : for each agent his configurations
    T=size(targets_conf,1);
    C=size(targets_conf,2); %num of conf
    N=size(drone_targets,1);
    
    targets_conf_bool   = (targets_conf>=ones(T,C)); %N=size of drons, C= size of configurations
    temp                = repmat(sum(targets_conf_bool),[N,1]);
    agent2conf          = drone_targets*targets_conf >= temp;      
end

