function [M2PLLink,MissionPlanConf,UAVTypeProperties]  = GetOutGeneralDataParameters(OutFilePath)

% Get Out GeneralData Parameters
[data,text] = xlsread(OutFilePath,'GeneralData');
% Get Total Mission Plan Properties
MissionPlanConf.TakeoffPos = [data(1,1);data(2,1)]; % Km
MissionPlanConf.RefArea = [data(3,1:4);data(4,1:4)]; % Km
MissionPlanConf.GridRes = data(5,1); % Km
MissionPlanConf.PalnDuration = data(6,1); % Hours
MissionPlanConf.TimeRes = data(7,1); % Hours
MissionPlanConf.LeastPriority = data(8,1); % 1 - Hiest Priority ... data(8,1) - Least Priority
RefAreaSize = [max(MissionPlanConf.RefArea(1,:)) - min(MissionPlanConf.RefArea(1,:));...
    max(MissionPlanConf.RefArea(2,:)) - min(MissionPlanConf.RefArea(2,:))];
NumOfAreas = max(1,data(9,1)); % At least One
StandOutAreaSize = [ data(10,1); data(11,1)];
MissionPlanConf.StandOutFlightAreaDB.NumOfAreas = NumOfAreas;
AreasSpacing = RefAreaSize(1)/NumOfAreas;
Area.Area = MissionPlanConf.RefArea;
MissionPlanConf.StandOutFlightAreaDB.Area = repmat(Area,1,MissionPlanConf.StandOutFlightAreaDB.NumOfAreas);
for i  =1: NumOfAreas
    AreaCenter = [  min(MissionPlanConf.RefArea(1,:)) + AreasSpacing*(i-0.5)  ; min(MissionPlanConf.RefArea(2,:)) - StandOutAreaSize(2)];
    MissionPlanConf.StandOutFlightAreaDB.Area(i).Area = ...
        [-StandOutAreaSize(1)/2+AreaCenter(1) StandOutAreaSize(1)/2+AreaCenter(1) StandOutAreaSize(1)/2+AreaCenter(1) -StandOutAreaSize(1)/2+AreaCenter(1);...
        StandOutAreaSize(2)/2+AreaCenter(2) StandOutAreaSize(2)/2+AreaCenter(2) -StandOutAreaSize(2)/2+AreaCenter(2) -StandOutAreaSize(2)/2+AreaCenter(2)];
end

% Get UAV Types Properties
startIdx = 14;
numOfTypes = find(~isnan(data(startIdx+1:startIdx+8,1)),1,'last');
numOfPLs = find(~isnan(data(startIdx+1,1:end)),1,'last') - 4;
for i = 1: numOfTypes
    UAVTypeData.Name = text{startIdx+i+1,1}; % UAV Type Name (string)
    UAVTypeData.Type = data(startIdx+i,1); % UAV Type
    UAVTypeData.FlightDuration = data(startIdx+i,2); % UAV Flight Duration (hours)
    UAVTypeData.GroundServiceTime = data(startIdx+i,3); %  UAV Ground Service Duration (hours)
    UAVTypeData.Speed = data(startIdx+i,4); % UAV Type Speed [m/sec]
    UAVTypeData.PLTypes = data(startIdx+i,5:numOfPLs+4); % 0 - Not Exist, 1 Exist
    if i == 1
        UAVTypeProperties = repmat(UAVTypeData,1,numOfTypes);
    else
        UAVTypeProperties(i) = UAVTypeData;
    end
end

% Get Mission to Payload Link Table
startIdx = 25;
numOfMissions = find(~isnan(data(startIdx:end,1)),1,'last');
numOfPL = find(~isnan(data(startIdx,1:end)),1,'last');
M2PLLink = data(startIdx:startIdx+numOfMissions-1,1:numOfPL);
