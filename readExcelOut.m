function [ agent2currTargetLoc, completedTargets, targetsInProcess] = readExcelOut(excelOut, currTime)
    agent2lastTargetLoc = struct;
    agent2currTargetLoc = struct;
    targetsInProcess    = struct;
    completedTargets = [];
    for excelLine = 1:size(excelOut,1)
        % fprintf('line is %d\n',excelLine);
        currAgent   = excelOut(excelLine,1);
        currTarget  = excelOut(excelLine,2) + 1;
        startTime   = excelOut(excelLine,4);
        endTime     = excelOut(excelLine,5);
        if currTarget == 1
            continue
        end
        if (currTime <= endTime) && (currTime >= startTime)
            agent2currTargetLoc.(sprintf('a%d',currAgent)) = currTarget;
            % fprintf('curr target for agent %d is %d\n',currAgent,currTarget)
            targetsInProcess.(sprintf('t%d',currTarget)) = {};
            targetsInProcess.(sprintf('t%d',currTarget)).elapsed = currTime - startTime;
            targetsInProcess.(sprintf('t%d',currTarget)).agent   = currAgent;
        elseif currTime > endTime
            completedTargets = [completedTargets currTarget];
            if isfield(agent2lastTargetLoc,sprintf('a%d',currAgent)) && (endTime > agent2lastTargetLoc.(sprintf('a%d',currAgent)).time)
                agent2lastTargetLoc.(sprintf('a%d',currAgent)).time = endTime;
                agent2lastTargetLoc.(sprintf('a%d',currAgent)).target = currTarget;
                % fprintf('last target for agent %d is %d\n',currAgent,currTarget);
            else
                agent2lastTargetLoc.(sprintf('a%d',currAgent)) = {};
                agent2lastTargetLoc.(sprintf('a%d',currAgent)).time = endTime;
                agent2lastTargetLoc.(sprintf('a%d',currAgent)).target = currTarget;
                % fprintf('last target for agent %d is %d\n',currAgent,currTarget);
            end
        end     
    end
    fields = fieldnames(agent2lastTargetLoc);
    for i = 1:numel(fields)
        if ~isfield(agent2currTargetLoc,fields{i})
            agent2currTargetLoc.(fields{i}) = agent2lastTargetLoc.(fields{i}).target;
        end
    end         
end

