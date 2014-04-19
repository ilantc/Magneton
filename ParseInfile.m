function [ Agent2sensor,target2sensor, AgentInfo,target2Val, target2TargetDistance ] = ParseInfile( infile )
    
    % parse the general data sheet 
    % TODO - take from Elbit input
    [M2PLLink,~,UAVTypeProperties]  = GetOutGeneralDataParameters(infile);
    
    % convert from struct to regular matrix
    GenData1 = [];
    for i=1:size(UAVTypeProperties,2)
        row = UAVTypeProperties(i).Type;
        row = [row UAVTypeProperties(i).FlightDuration];
        row = [row UAVTypeProperties(i).GroundServiceTime];
        row = [row UAVTypeProperties(i).Speed];
        row = [row UAVTypeProperties(i).PLTypes];
        GenData1(i,:) = row;
    end
    GenData2 = M2PLLink;
    
    % Parse the input file and return the data
    Agent2sensor          = buildAgent2sensor(infile, GenData1, GenData2);
    AgentInfo             = buildAgentInfo(infile, GenData1);
    target2sensor         = buildTarget2sensor(infile, GenData2);
    target2Val            = buildTarget2Val(infile);
    target2TargetDistance = buildTarget2TargetDistance(infile, size(target2Val,1));
end

