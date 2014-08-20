function [stat_matrix] = stat_segev_3000X3000_all_stat(file1,file2,file3,file4,file5,file6)

files={file1,file2,file3,file4,file5,file6};
    write=1;
    buildAmount=3000;
    runAmount=3000;
    stat_matrix=[];
    
    for k=1:length(files)
        file=char(files(k));
        [model,outConf,AgentInfo, allConfigurations, agent2conf, Agent2target, AllConf, excelOut, Agent2sensor, target2sensor,allStat] = mainBFS(file,buildAmount,runAmount,write);
        temp=[allStat.val,allStat.solverTime,allStat.confBuildTime,allStat.confDupRemovalTime,allStat.inputParsingTime];
        stat_matrix=[stat_matrix;temp];
    end
end
