function [outMatrix] = compare_h_to_solver(files,h,outFile)
    
    params      = [1,2,3]*10;
    numFiles    = size(files,2);
    numParams   = size(params,2);
    numIter     = numParams * numFiles;
    outMatrix   = zeros(numIter,6);
    iter        = 0;
    for param=1:numParams
        allStats = Get_All_Stat(files,params(param),params(param),0);
        for i=1:size(files,2)
            iter              = iter + 1;
            fileName          = sprintf('%s',files{i});
            agent2conf        = allStats.(sprintf('f_%s',files{i})).agent2conf;
            allConf           = allStats.(sprintf('f_%s',files{i})).allConfigurations;
            targetsData       = allStats.(sprintf('f_%s',files{i})).targetsData;
            h_time            = tic;
            val               = h(agent2conf,allConf,targetsData);
            h_time            = toc(h_time);
            outMatrix(iter,1) = fileName;
            outMatrix(iter,2) = param;
            outMatrix(iter,3) = h_time;
            outMatrix(iter,4) = allStats.(sprintf('f_%s',files{i})).allStat.solverTime;
            outMatrix(iter,5) = val;
            outMatrix(iter,6) = allStats.(sprintf('f_%s',files{i})).allStat.val;
        end
    end
    
    %write output
    row_header={'file','param#','heuristic time','solver time','heuristic value','solver value'};
    xlswrite(outFile,row_header,'Sheet1','A1');
    xlswrite(outFile,outMatrix,'Sheet1','A2');
end