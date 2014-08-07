function [allConfigurationsForBuild,allConfigurationsForRun,allConfTimes,allValsOutput] = trimConfs(allConfigurations,allConfTimes,target2Val,amountForBuild,finalAmount)
    confNum = size(allConfigurations,2);
    %% first bucket all the values
    allValues = zeros(0,4); % first col = val, 2nd col = amount
                            % 3rd col = amound for amountForBuild
                            % 4th col = amound for finalAmount
    confVals = zeros(1,confNum);
    for conf=1:confNum
        currVal = getConfVal(allConfigurations(:,conf)>0,target2Val);
        valIndex = find(allValues(:,1) == currVal);
        if (size(valIndex,1) == 0)
            allValues = [allValues ; currVal 1 0 0];
        else
            allValues(valIndex,2) = allValues(valIndex,2) + 1;
        end
        confVals(conf) = currVal;        
    end
    
    % sort all Vals
    allValues = sortrows(allValues,1);
    
    % determine how many from each bucket for each 
    aggregatedTotal = 0;
    for valIndex=size(allValues,1):-1:1
        aggregatedTotal = aggregatedTotal + allValues(valIndex,2);
        if (aggregatedTotal > amountForBuild)
            allValues(valIndex,3) = allValues(valIndex,2) - (aggregatedTotal - amountForBuild); % how many we have minus overflow
        else
            allValues(valIndex,3) = allValues(valIndex,2);
        end
        if (aggregatedTotal > finalAmount)
            allValues(valIndex,4) = allValues(valIndex,2) - (aggregatedTotal - finalAmount); % how many we have minus overflow
        else
            allValues(valIndex,4) = allValues(valIndex,2);
        end
    end
    
    % output for statistics 
    allValsOutput = allValues;
    
    % this block should move up to row 3 for performence, it is only here
    % for stats
    if ( (confNum <= amountForBuild) && (confNum <= finalAmount)  )
        allConfigurationsForBuild = allConfigurations;
        allConfigurationsForRun = allConfigurations;
        return 
    end
    
    buildConfs = zeros(1,confNum);
    finalConfs = zeros(1,confNum);
    % find top picks for both params
    for conf=1:confNum
        currVal = getConfVal(allConfigurations(:,conf)>0,target2Val);
        currValRow = find(allValues(:,1) == currVal);
        if (allValues(currValRow,3) > 0)
            allValues(currValRow,3) = allValues(currValRow,3) -1;
            buildConfs(conf) = 1;
        end
        if (allValues(currValRow,4) > 0)
            allValues(currValRow,4) = allValues(currValRow,4) -1;
            finalConfs(conf) = 1;
        end
    end
    allConfigurationsForBuild = allConfigurations(:,buildConfs == 1);
    allConfTimes              = allConfTimes(:,:,buildConfs == 1);
    allConfigurationsForRun   = allConfigurations(:,finalConfs == 1);
end

function [val] = getConfVal(conf,target2Val)
    val = conf' * target2Val;
end