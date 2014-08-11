function [UAVState,numOfUAVs] = GetUAVState(OutFilePath,Sheet)
% Get UAV State 
startIdx = 0;
[data,text] = read_excel_and_clean(OutFilePath,Sheet);
numOfUAVs = sum(~isnan(data(:,1)));
for i = 1: numOfUAVs
    UAVStateData.Name = text{startIdx+i+2,1}; % UAV Type Name (string)
    UAVStateData.ID = data(startIdx+i,1); % UAV Type
    UAVStateData.Type = data(startIdx+i,2); % UAV Type
    UAVStateData.NextFlightReadyTime = data(startIdx+i,3); % UAV Next Flight Ready Time (hours)
    UAVStateData.Pos = [data(startIdx+i,4);data(startIdx+i,5)]; %  UAV (x,y) position [m]
    UAVStateData.TOL_Pos = [data(startIdx+i,7);data(startIdx+i,8)]; %  UAV (x,y) Takeoff & Landingposition [m]
    UAVStateData.TimeInFlight = data(startIdx+i,6); % UAV Time in Flight (hours)
    if i == 1
        UAVState = repmat(UAVStateData,1,numOfUAVs);
    else
        UAVState(i) = UAVStateData;
    end
end