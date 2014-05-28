function[RealConf] = findRealConf(sortedTargetsData,currRealConf,currConfSize,currFinish,maxFinish, lastTargetVisited,speed,v)
    
    global target2TargetDistance;
    ID_COL          =1;
    VAL_COL         =3;
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
            duration    = sortedTargetsData(i,DURATION_COL);
            flightTime  = (target2TargetDistance(lastTargetVisited,currID + 1)/(speed*60*60));
            start       = max(currFinish + flightTime,sortedTargetsData(i,BEGIN_COL));
            finish      = start + duration;
            val         = sortedTargetsData(i,VAL_COL);
            val = 8- val;
          %  duration
          %  flightTime
          %  start
          %  finish
          if (v) 
              fprintf('dur = %10.2d, start = %10.2d, finish = %10.2d\n',duration,start,finish);
              fprintf('maxFinish = %10.2d, win_end = %10.2d, target = %10.2d\n',maxFinish,sortedTargetsData(i,END_COL),currID);
             % currRealConf
          end
            if ((finish <= maxFinish + 0.01) && (finish <= sortedTargetsData(i,END_COL) + 0.01) )
                % add this row, and call the recursive function again
                tempCurrRealConf = currRealConf;
                tempCurrRealConf(currConfSize + 1,:) = [currID,start,finish,val];
                foundConf = findRealConf(sortedTargetsData,tempCurrRealConf,currConfSize + 1,finish,maxFinish,currID + 1,speed,v);
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