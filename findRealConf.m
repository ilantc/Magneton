function[RealConf] = findRealConf(sortedTargetsData,currRealConf,currConfSize,currFinish,maxFinish)
    
    ID_COL          =1;
    BEGIN_COL       =4;
    END_COL         =5;
    DURATION_COL    =6;

    % if curr realConf is full, return it
    if (currConfSize == size(currRealConf,1))
        RealConf = currRealConf;
        return;
    end
    
    % find the next candidate, or return an empty conf to signal that no
    % one was found
    for (i = 1:size(sortedTargetsData,1))
        
        currID = sortedTargetsData(i,ID_COL);
        currWasScheduled = currRealConf(currRealConf(:,ID_COL) == currID,:);
        % if this one is already in the conf, skip it
        if (size(currWasScheduled,1) == 0) 
            % check if can schedule it next
            duration = sortedTargetsData(i,DURATION_COL);
            start    = max(currFinish,sortedTargetsData(i,BEGIN_COL));
            finish   = start + duration;
            if ((finish <= maxFinish) && (finish <= sortedTargetsData(i,END_COL)) )
                % add this row, and call the recursive function again
                currRow = sortedTargetsData(sortedTargetsData(:,ID_COL) == currID,:);
                tempCurrRealConf = currRealConf;
                tempCurrRealConf(currConfSize + 1,:) = [currID,start,finish];
                foundConf = findRealConf(sortedTargetsData,tempCurrRealConf,currConfSize + 1,finish,maxFinish);
                % if found conf is not good, continue, else - return it
                if (size(foundConf,1) > 0 )
                    RealConf = foundConf;
                    return
                end
            end
        end
    end
    % if we got here - there is no feasible conf, return an empty matrix
    RealConf = zeros(0,0);
end