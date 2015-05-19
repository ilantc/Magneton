function [stat_obj] = Get_All_Stat(buildAmount,runAmount,write,allowPar)
    files ={'30Missions','30Missions_2','40Missions','40Missions_2','50Missions','50Missions_2','60Missions','60Missions_2','80Missions','80Missions_2'};
    for k=1:length(files)
        file=sprintf('%s.xlsx',files{k})
        [~,~,~, ~, ~, ~, ~, excelOut, ~, ~,~,~,~,allStat,~] = mainBFS(file,buildAmount,runAmount,write,allowPar);
        stat_obj.(sprintf('f_%s',files{k})).allStat = allStat;
    end
end
