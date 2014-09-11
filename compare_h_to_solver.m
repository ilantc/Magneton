function [outMatrix,firstCol] = compare_h_to_solver(files,h,outFile)
    
    params      = [1,2,3]*1000;
    numFiles    = size(files,2);
    numParams   = size(params,2);
    numIter     = numParams * numFiles;
    outMatrix   = zeros(numIter,5);
    firstCol    = {};
    size(outMatrix)
    iter        = 0;
    for param=1:numParams
        allStats = Get_All_Stat(files,params(param),params(param),0);
        for i=1:numFiles
            iter              = iter + 1
            fileName          = sprintf('%s',files{i});
            agent2conf        = allStats.(sprintf('f_%s',files{i})).agent2conf;
            allConf           = allStats.(sprintf('f_%s',files{i})).allConfigurations;
            targetsData       = allStats.(sprintf('f_%s',files{i})).targetsData;
            h_time            = tic;
            val               = h(agent2conf,allConf,targetsData);
            h_time            = toc(h_time);
            firstCol{iter}    = fileName;
            outMatrix(iter,1) = param
            outMatrix(iter,2) = h_time
            outMatrix(iter,3) = allStats.(sprintf('f_%s',files{i})).allStat.solverTime
            outMatrix(iter,4) = cell2mat(val)
            outMatrix(iter,5) = allStats.(sprintf('f_%s',files{i})).allStat.val
        end
    end
    
    %write output
    row_header={'file','param#','heuristic time','solver time','heuristic value','solver value'};
    xlswrite(outFile,row_header,'Sheet1','A1');
    xlswrite(outFile,firstCol','Sheet1','A2');
    xlswrite(outFile,outMatrix,'Sheet1','B2');
end