function ReadMissionSqedulerOut(OutFilePath)

% Read Flight Plan From File
[MissionsData,~] = read_excel_and_clean(OutFilePath,'InMissions');
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

% Read Mission Link Table
[MissionsLink,~] = read_excel_and_clean(OutFilePath,'MissionsLink');
% Range Between Missions Table
[FlightBetweenMissionsRange,~] = read_excel_and_clean(OutFilePath,'MissionsRange');

% Read Flight Plan From File
[Flights,~] = read_excel_and_clean(OutFilePath,'FinalFlights');
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
[M2PLLink,MissionPlanConf,UAVTypeProperties]  = GetOutGeneralDataParameters(OutFilePath);

% Option 6.b data ================
% Read Flight Plan From File
[InFlights,~] = read_excel_and_clean(OutFilePath,'InFlights');
NumOfFlights = length(InFlights(:,1));
for i = 1:NumOfFlights
    F = InFlights(i,:);
    f.ID = F(1);
    f.UAVID = F(2);
    f.Type = F(3);
    f.TakeoffTime = F(4);
    f.LandingTime = F(5);
    f.Pos = F(6:7)';
    f.TOL_Pos = F(8:9)';
    f.PredefinedMissionsList = F(10:19);
    if i == 1
        InFlightsDB = repmat(f,1,NumOfFlights);
    else
        InFlightsDB(i) = f;
    end
end
% Get UAV State 
[InUAVState,NumOfUAVs] = GetUAVState(OutFilePath,'InUAVState');
% ===================================

% Create Assignment - TODO
[Assinment,FinalFlightPlan] = CreateAssinment(MissionsDB,MissionsLink,FlightBetweenMissionsRange,...
    FlightsDB,M2PLLink,MissionPlanConf,UAVState,UAVTypeProperties);







