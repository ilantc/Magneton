function [ allConfigurations ] = getAllConfigurations( numOfTargets,maxNumOfTargetInConfiguration, verbose )
    
    if (verbose) 
        fprintf('\nentered getAllConfigurations');
    end

    % define matrix size and allocate it
    matSize = 0;
    for i=1:maxNumOfTargetInConfiguration
        matSize = matSize + nChooseK(numOfTargets,i);
    end
    
    allConfigurations = zeros(numOfTargets,matSize);
    
    colNo = 1; %running index 
    
    for i = 1:maxNumOfTargetInConfiguration
        A = combntns(1:numOfTargets,i)'; % produce the nchoosek matrix to be used as inideces
        for j=1:size(A,2)
            allConfigurations(A(:,j),colNo)=1;
            colNo = colNo + 1;
        end
    end
    allConfigurations = sparse(allConfigurations);
end

