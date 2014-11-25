%% Agent2Target[i,j] = 1 if agent i can scan target j (sensor-wise)
%% targetsData - as stated by var names below
%% agentInfo -          AgentInfo(i,1)  = takeoffTime
%                       AgentInfo(i,2)  = flightTime;
%                       AgentInfo(i,3)  = speed;
%                       AgentInfo(i,4)  = AgentID;
%                       AgentInfo(i,5)  = FlightID;

function [val,targetDone] = maxValH1(Agent2target,targetsData,AgentInfo,target2Val)
    targetsData_BEGIN_COL       =4;
    targetsData_END_COL         =5;
    targetsData_DURATION_COL    =6;
    
    numAgents = size(Agent2target,1);
    numTargets = size(Agent2target,2);
    targetDone = zeros(1,numTargets);
    val = 0;
    for i=1:numAgents
        agentStartTime = AgentInfo(i,1);
        agentEndTime = AgentInfo(i,1) + AgentInfo(i,2);
        for j=1:numTargets
            if (Agent2target(i,j) > 0) && (targetDone(j) == 0)
                targetStartTime = targetsData(j,targetsData_BEGIN_COL);
                targetEndTime = targetsData(j,targetsData_END_COL);
                targetDuration = targetsData(j,targetsData_DURATION_COL);

                earliestStart = max(agentStartTime,targetStartTime);
                earliestFinish = earliestStart + targetDuration;
                if (earliestFinish <= min(agentEndTime,targetEndTime))
                    val = val + target2Val(j,1);
                    targetDone(j) = 1;
                end
            end
        end
    end
end