function [ Agent2sensor,target2sensor, AgentInfo,target2Val ] = ParseInfile( infile )
    
    % Parse the input file and return the data
    Agent2sensor  = buildAgent2sensor(infile);
    AgentInfo     = buildAgentInfo(infile);
    target2sensor = buildTarget2sensor(infile);
    target2Val    = buildTarget2Val(infile);

end

