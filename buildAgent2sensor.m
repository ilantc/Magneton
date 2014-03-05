function [ UAV2sensor ] = buildAgent2sensor( infile )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    
    
    MissionType2Sensor  = xlsread(infile,'GeneralData2');
    numOfSensors = size(MissionType2Sensor,2);
    UAVType2sensor      = xlsread(infile,'GeneralData1');
    % get only the relevant cols - the type2sensor cols
    UAVType2sensor = UAVType2sensor(:,size(UAVType2sensor,2)-numOfSensors+1:size(UAVType2sensor,2));
    
    UAV2UAVType         = xlsread(infile,'InUAVState');
    numOfUAV = size(UAV2UAVType,1);
    
    % get only the relevant cols, id2type
    UAV2UAVType = UAV2UAVType(:,1:2);
    
    % build droneId2sensor
    UAV2sensor = zeros(numOfUAV,numOfSensors);
    for i=1:numOfUAV
        UAVId   = UAV2UAVType(i,1);
        UAVType = UAV2UAVType(i,2);
        UAV2sensor(UAVId,:) = UAVType2sensor(UAVType,:);
    end
    
end

