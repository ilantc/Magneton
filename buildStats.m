function [out] = buildStats(files) 
    tic
    %files = {'60Missions','60Missions_2','50Missions','50Missions_2','40Missions','40Missions_2','30Missions','30Missions_2'};
    files = {'50Missions','50Missions_2','40Missions','40Missions_2','30Missions','30Missions_2'};
    buildParamMin = 10;
    buildParamMax = 4000;
    buildParamStep = 100;
    
    runParamMin = 10;
    runParamMax = 4000;
    runParamStep = 50;
    
    dimRun = size(runParamMin:runParamStep:runParamMax,2);
    dimBuild = size(buildParamMin:buildParamStep:buildParamMax,2);
    out = {};
    
    firstRow = [0 buildParamMin:buildParamStep:buildParamMax];       
    firstCol = (runParamMin:runParamStep:runParamMax)';
    
    for file=1:size(files,2)
        csvFileName = sprintf('File_%s_stat.csv',files{file});
        
        if (exist(csvFileName, 'file') == 2)
            currFileOut = csvread(csvFileName);
            fprintf('File %s exists!\n',csvFileName);
        else 
            currFileOut = [firstRow ;firstCol zeros(dimRun,dimBuild)];
            fprintf('File %s does not exist!\n',csvFileName);
        end
        fprintf('file %d/%d\n',file,size(files,2));
        filename = sprintf('%s.xlsx',files{file});
        i=0;
        for runParam=runParamMin:runParamStep:runParamMax
            i = i+1;
            j=0;
            for buildParam=buildParamMin:buildParamStep:buildParamMax
                j = j+1;
                fprintf('\tIteration %d/%d\n',(((i-1)*dimBuild) + j),dimRun*dimBuild);
                if ((currFileOut(i+1,j+1) == 0) && (runParam <= buildParam) )
                    [~,~,~,~, ~, ~, ~, ~, ~, ~, ~,~,allStat] = evalc('mainBFS(filename,buildParam,runParam,0);');
                    currFileOut(i+1,j+1) = allStat.val;
                    %xlswrite('stat.xls',allStat.val,sprintf('File_%s',files{file}),sprintf('%s%i',char(65 + i),j + 1));
                    csvwrite(csvFileName,currFileOut,0,0);
                end
            end
        end
        out.(sprintf('File_%s',files{file})) = currFileOut;
    end
    toc
end