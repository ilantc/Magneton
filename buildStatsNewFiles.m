function [out] = buildStatsNewFiles(files) 
    tic
    %files =
    %{'60Missions','60Missions_2','50Missions','50Missions_2','40Missions','40Missions_2','30Missions','30Missions_2'}; 
    files = {'Example_1_51','Example_2_51','Example_3_114','Example_4_133','Example_5_51'};
    buildParamMin = 10;
    buildParamMax = 3010;
    buildParamStep = 500;
    
    runParamMin = 10;
    runParamMax = 3010;
    runParamStep = 500;
    
    dimRun = size(runParamMin:runParamStep:runParamMax,2);
    dimBuild = size(buildParamMin:buildParamStep:buildParamMax,2);
    out = {};
    
    firstRow = [0 buildParamMin:buildParamStep:buildParamMax];       
    firstCol = (runParamMin:runParamStep:runParamMax)';
    
    for file=1:size(files,2)
        filename = sprintf('%s.xlsx',files{file});
        fileData = {};
        fileData.vals = [firstRow ;firstCol zeros(dimRun,dimBuild)];
        fileData.solverTime = [firstRow ;firstCol zeros(dimRun,dimBuild)];
        fileData.confBuildTime = [firstRow ;firstCol zeros(dimRun,dimBuild)];
%         if (exist(csvFileName, 'file') == 2)
%             currFileOut = csvread(csvFileName);
%             fprintf('File %s exists!\n',csvFileName);
%         else 
%             currFileOut = [firstRow ;firstCol zeros(dimRun,dimBuild)];
%             fprintf('File %s does not exist!\n',csvFileName);
%         end
        fprintf('file %d/%d\n',file,size(files,2));
        valsfilename = sprintf('%s_vals.csv',files{file});
        solverTimefilename = sprintf('%s_solverTime.csv',files{file});
        confBuildTimefilename = sprintf('%s_confBuildTime.csv',files{file});
        i=0;
        for runParam=runParamMin:runParamStep:runParamMax
            i = i+1;
            j=0;
            for buildParam=buildParamMin:buildParamStep:buildParamMax
                j = j+1;
                fprintf('\tIteration %d/%d\n',(((i-1)*dimBuild) + j),dimRun*dimBuild);
                if (runParam <= buildParam)
                    [~,~,~,~, ~, ~, ~, ~, ~, ~, ~,~,allStat] = evalc('mainBFS(filename,buildParam,runParam,0,1);');
                    fileData.solverTime(i+1,j+1) = allStat.solverTime;
                    fileData.confBuildTime(i+1,j+1) = allStat.confBuildTime;
                    fileData.vals(i+1,j+1) = allStat.val;
                    %xlswrite('stat.xls',allStat.val,sprintf('File_%s',files{file}),sprintf('%s%i',char(65 + i),j + 1));
                    csvwrite(valsfilename,fileData.vals,0,0);
                    csvwrite(solverTimefilename,fileData.solverTime,0,0);
                    csvwrite(confBuildTimefilename,fileData.confBuildTime,0,0);
                end
            end
        end
        out.(sprintf('File_%s',files{file})) = fileData;
    end
    toc
end