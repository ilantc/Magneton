function [out] = buildStats() 
    
    %files = {'60Missions','60Missions_2','50Missions','50Missions_2','40Missions','40Missions_2','30Missions','30Missions_2'};
    files = {'50Missions','50Missions_2','40Missions','40Missions_2','30Missions','30Missions_2'};
    buildParamMin = 1000;
    buildParamMax = 15000;
    buildParamStep = 1000;
    
    runParamMin = 1000;
    runParamMax = 15000;
    runParamStep = 500;
    
    dimRun = size(runParamMin:runParamStep:runParamMax,2);
    dimBuild = size(buildParamMin:buildParamStep:buildParamMax,2);
    out = {};
    
    for file=1:size(files,2)
        currFileOut = zeros(dimRun,dimBuild);
        fprintf('file %d/%d\n',file,size(files,2));
        i=0;
        for runParam=runParamMin:runParamStep:runParamMax
            i = i+1;
            j=0;
            for buildParam=buildParamMin:buildParamStep:buildParamMax
                j = j+1;
                fprintf('\tIteration %d/%d\n',(((i-1)*dimBuild) + j),dimRun*dimBuild);
                filename = sprintf('%s.xlsx',files{file});
                [~,~,~,~, ~, ~, ~, ~, ~, ~, ~,allStat] = evalc('mainBFS(filename,buildParam,runParam);');
                currFileOut(i,j) = allStat.val;
            end
        end
        firstRow = [0 buildParamMin:buildParamStep:buildParamMax];
        firstCol = (runParamMin:runParamStep:runParamMax)';
        currFileOut = [firstRow ;firstCol currFileOut];
        out.(sprintf('File_%s',files{file})) = currFileOut;
    end
end