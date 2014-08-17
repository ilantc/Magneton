function [ UAV2sensor ] = buildAgent2sensor( infile, UAVType2sensor, MissionType2Sensor,AgentInfo )
%UNTITLED Summary of this function goes here
% Detailed explanation goes here
    
    
    %MissionType2Sensor = read_excel_and_clean(infile,'GeneralData2');
    numOfSensors = size(MissionType2Sensor,2);
    %UAVType2sensor = read_excel_and_clean(infile,'GeneralData1');
    % get only the relevant cols - the type2sensor cols
    UAVType2sensor = UAVType2sensor(:,size(UAVType2sensor,2)-numOfSensors+1:size(UAVType2sensor,2));
    
    UAV2UAVType = read_excel_and_clean(infile,'InUAVState');
    numOfFlights = size(AgentInfo,1);
    
    % get only the relevant cols, id2type
    UAV2UAVType = UAV2UAVType(:,1:2);
    
    % build droneId2sensor
    UAV2sensor = zeros(numOfFlights,numOfSensors);
    for i=1:numOfFlights
        flightIDRow = AgentInfo(i,5);
        UAVId = AgentInfo(i,4);
        UAVType = UAV2UAVType(UAV2UAVType(:,1) == UAVId,2);
        UAV2sensor(flightIDRow,:) = UAVType2sensor(UAVType,:);
    end
end
