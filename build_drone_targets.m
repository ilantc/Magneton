function [ drone_targets ] = build_drone_targets( targets,drone_sensor)
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
