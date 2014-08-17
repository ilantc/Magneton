function [ AgentInfo ] = buildAgentInfo(infile, UAVTypeDur)
    % build all the configurations per each drone
    % we need to get the takeoff time and the flight time
    % output is UAVID to [takeoffTime, flightTime, speed]

    UAVTakeoff   = read_excel_and_clean(infile,'FinalFlights');
    UAV2UAVType  = read_excel_and_clean(infile,'InUAVState');

    % targetsData col values
    UAVTypeDur_UAV_TYPE_COL     = 1;
    UAVTypeDur_UAV_DUR_COL      = 2;
    UAVTypeDur_UAV_SPEED_COL    = 4;
    UAVTakeoff_UAV_ID_COL       = 2;
    UAVTakeoff_FLIGHT_ID_COL    = 1;
    UAVTakeoff_UAV_TAKEOFF_COL  = 4;
    UAV2UAVType_UAV_ID_COL      = 1;
    UAV2UAVType_UAV_TYPE_COL    = 2;

    % output
    AgentInfo                   = zeros(size(UAVTakeoff,1),5);
    % build all the data per each UAV
    for i=1:size(UAVTakeoff,1)
        
        currAgentID     = UAVTakeoff(i,UAVTakeoff_UAV_ID_COL);
        currFlightID    = UAVTakeoff(i,UAVTakeoff_FLIGHT_ID_COL);
        % get the UAV TYPE
        currType        = UAV2UAVType(UAV2UAVType(:,UAV2UAVType_UAV_ID_COL) == currAgentID,UAV2UAVType_UAV_TYPE_COL);
        % get the flight time
        flightTime      = UAVTypeDur(UAVTypeDur(:,UAVTypeDur_UAV_TYPE_COL)==currType,UAVTypeDur_UAV_DUR_COL);
        % get speed
        speed           = UAVTypeDur(UAVTypeDur(:,UAVTypeDur_UAV_TYPE_COL)==currType,UAVTypeDur_UAV_SPEED_COL);
        % log the data
        AgentInfo(i,1)  = UAVTakeoff( i , UAVTakeoff_UAV_TAKEOFF_COL );
        AgentInfo(i,2)  = flightTime;
        AgentInfo(i,3)  = speed / 1000;
        AgentInfo(i,4)  = currAgentID;
        AgentInfo(i,5)  = currFlightID;
        %fprintf('i=%d,ID=%d, type=%d, flightTime=%d, toTime=%d\n',i,currID,currType,flightTime,AgentInfo(i,1));
    end
end    

