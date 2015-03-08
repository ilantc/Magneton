function [allConfigurations,a2c] = runAndRecalcPlan(file,buildAmount,runAmount,writeOutput,allowParallel,currTime,smallbuildAmount,smallrunAmount)
    [~,~,AgentInfo, ~, ~, Agent2target, oldAllConf, excelOut, Agent2sensor, target2sensor,targetsData,target2Val,missionLink,~,target2TargetDistance] = mainBFS(file,buildAmount,runAmount,writeOutput,allowParallel);
    [allConfigurations,a2c] = recalculatePlan(smallbuildAmount,smallrunAmount,writeOutput,AgentInfo,Agent2sensor,target2sensor, Agent2target,excelOut,targetsData,target2Val,currTime,target2TargetDistance,missionLink,oldAllConf);
end