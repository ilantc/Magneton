function [ target2sensor ] = buildTarget2sensor( infile )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    
    
    MissionType2Sensor  = xlsread(infile,'GeneralData2');
    numOfSensors = size(MissionType2Sensor,2);
    target2MissionType      = xlsread(infile,'InMissions');
   
    % get only the relevant cols, id2type
    target2MissionType = target2MissionType(:,1:2);
    numOfTargets = size(target2MissionType,1);
    
    % build droneId2sensor
    target2sensor = zeros(numOfTargets,numOfSensors);
    for i=1:numOfTargets
        targetId   = target2MissionType(i,1);
        targetType = target2MissionType(i,2);
        target2sensor(targetId,:) = MissionType2Sensor(targetType,:);
    end
    
end