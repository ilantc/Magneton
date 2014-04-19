function goodOptions = RunSchedulAssignment()

maxNumOfOptions = 1500;

[FileName,FolderName] = uigetfile('C:\*.xlsx', 'SensorsSchedulerOut.xlsx File');
InFilePath = [FolderName,'\',FileName];
% InFilePath = 'C:\Users\dp23489\Documents\MATLAB\Algomop\SensorsScheduler\SensorsSchedulerOut.xlsx';

% Read Flight Plan From File
[MissionsData,~] = xlsread(InFilePath,'InMissions');
NumOfMissions = length(MissionsData(:,1));
for i = 1:NumOfMissions
    M = MissionsData(i,:);
    m.ID = M(1);
    m.Type = M(2);
    m.Priority = M(3);
    m.StartAfter = M(4);
    m.EndBefore = M(5);
    m.Duration = M(6);
    m.TimePortion2Accomplish = M(7);
    m.MissionArea = reshape(M(8:15),[2,4]);
    m.FlightArea =reshape(M(16:23),[2,4]);
    if i == 1
        MissionsDB = repmat(m,1,NumOfMissions);
    else
        MissionsDB(i) = m;
    end
end

% Read Flight Plan From File
[Flights,~] = xlsread(InFilePath,'FinalFlights');
NumOfFlights = length(Flights(:,1));
for i = 1:NumOfFlights
    F = Flights(i,:);
    f.ID = F(1);
    f.UAVID = F(2);
    f.Type = F(3);
    f.TakeoffTime = F(4);
    f.LandingTime = F(5);
    f.Pos = F(6:7)';
    f.TOL_Pos = F(8:9)';
    f.PredefinedMissionsList = F(10:19);
    if i == 1
        FlightsDB = repmat(f,1,NumOfFlights);
    else
        FlightsDB(i) = f;
    end
end

% Get Out GeneralData Parameters
[M2PLLink,~,UAVTypeProperties]  = GetOutGeneralDataParameters(InFilePath);

outstrct.goodOptions2 = zeros(maxNumOfOptions,2);
outstrct.goodOptions3 = zeros(maxNumOfOptions,3);
outstrct.goodOptions4 = zeros(maxNumOfOptions,4);
outstrct.goodOptions5 = zeros(maxNumOfOptions,5);
goodOptions = repmat(outstrct,1,NumOfFlights);

for flightNum=1:NumOfFlights
    disp(['Find Possible Missions for UAV(', num2str(flightNum),')']);
    UAVTypeIdx = find([UAVTypeProperties.Type] == FlightsDB(flightNum).Type,1);
    PL_types = UAVTypeProperties(UAVTypeIdx).PLTypes;
    temp = sum(M2PLLink(:,PL_types == 1),2);
    RelevantMissionTypes = temp > 0;
    [goodOptions2, goodOptions3, goodOptions4, goodOptions5] = ...
        SchedulAssignment(maxNumOfOptions, MissionsDB, FlightsDB, RelevantMissionTypes, flightNum);
    goodOptions(flightNum).goodOptions2 = goodOptions2;
    goodOptions(flightNum).goodOptions3 = goodOptions3;
    goodOptions(flightNum).goodOptions4 = goodOptions4;
    goodOptions(flightNum).goodOptions5 = goodOptions5;
end



