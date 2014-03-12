function [ Agent2sensor,target2sensor ] = ParseInfile( infile )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    
    Agent2sensor  = buildAgent2sensor(infile);
    AgentInfo     = buildAgentInfo(infile);
    target2sensor = buildTarget2sensor(infile);

end

