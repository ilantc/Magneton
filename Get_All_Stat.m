function [stat_obj] = Get_All_Stat(files,buildAmount,runAmount,write)
    for k=1:length(files)
        file=sprintf('%s.xlsx',files{k})
        [~,~,~, allConfigurations, agent2conf, ~, ~, ~, ~, ~,targetsData,allStat] = mainBFS(file,buildAmount,runAmount,write);
        stat_obj.(sprintf('f_%s',files{k})).allStat = allStat;
        stat_obj.(sprintf('f_%s',files{k})).allConfigurations = allConfigurations;
        stat_obj.(sprintf('f_%s',files{k})).agent2conf = agent2conf;
        stat_obj.(sprintf('f_%s',files{k})).targetsData = targetsData;
    end
end
