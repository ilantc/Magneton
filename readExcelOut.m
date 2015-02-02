function [ output_args ] = readExcelOut(excelOut, currTime)
    agent2lastTargetLoc = {};
    agent2currTargetLoc = {};
    for excelLine = 1:size(excelOut,1)
        currAgent   = excelOut(excelLine,1);
        currTarget  = excelOut(excelLine,2);
        startTime   = excelOut(excelLine,4);
        endTime     = excelOut(excelLine,5);
        if (currTime <= endTime) && (currTIme >= startTime)
            agent2currTargetLoc.(sprintf('%d',currAgent)) = currTarget;
        elseif currTime > endTime
            if isfield(agent2lastTargetLoc,sprintf('%d',currAgent)) && (endTime > agent2lastTargetLoc.(sprintf('%d',currAgent)).time)
                agent2lastTargetLoc.(sprintf('%d',currAgent)).time = endTime;
                agent2lastTargetLoc.(sprintf('%d',currAgent)).target = currTarget;
            else
                agent2lastTargetLoc.(sprintf('%d',currAgent)) = {};
                agent2lastTargetLoc.(sprintf('%d',currAgent)).time = endTime;
                agent2lastTargetLoc.(sprintf('%d',currAgent)).target = currTarget;
            end
                    
                    
                
                
    end
end

