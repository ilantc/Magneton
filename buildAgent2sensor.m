function [ UAV2sensor ] = buildAgent2sensor( infile, UAVType2sensor, MissionType2Sensor )
%UNTITLED Summary of this function goes here
% Detailed explanation goes here
    
    
    %MissionType2Sensor = read_excel_and_clean(infile,'GeneralData2');
    numOfSensors = size(MissionType2Sensor,2);
    %UAVType2sensor = read_excel_and_clean(infile,'GeneralData1');
    % get only the relevant cols - the type2sensor cols
    UAVType2sensor = UAVType2sensor(:,size(UAVType2sensor,2)-numOfSensors+1:size(UAVType2sensor,2));
    
    UAV2UAVType = read_excel_and_clean(infile,'InUAVState');
    numOfUAV = size(UAV2UAVType,1);
    
    % get only the relevant cols, id2type
    UAV2UAVType = UAV2UAVType(:,1:2);
    
    % build droneId2sensor
    UAV2sensor = zeros(numOfUAV,numOfSensors);
    for i=1:numOfUAV
        UAVId = UAV2UAVType(i,1);
        UAVType = UAV2UAVType(i,2);
        UAV2sensor(UAVId,:) = UAVType2sensor(UAVType,:);
    end
    
end
