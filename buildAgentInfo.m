function [ AgentInfo ] = buildAgentInfo(infile)

    UAVTakeoff   = xlsread(infile,'InFlights');
    UAVTypeDur   = xlsread(infile,'GeneralData1');
    UAV2UAVType  = xlsread(infile,'InUAVState');

    % targetsData col values
    UAVTypeDur_UAV_ID_COL            = 1;
    UAVTakeoff_UAV_ID_COL            = 2;
    takeoff                          = 4;
    AgentInfo=zeros(size(UAVTakeoff,1),3);
    for i=1:size(UAVTakeoff,1)
        AgentInfo(i,1)= UAVTakeoff (i,UAVTakeoff_UAV_ID_COL);
        AgentInfo(i,2)= UAVTakeoff (i,UAVTakeoff_UAV_ID_COL);

        
    end
        allConfigurations = [allConfigurations , currConf];
    
end    

