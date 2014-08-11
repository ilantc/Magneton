
function [data,text] = read_excel_and_clean(file,sheet)
    [data,text] = xlsread(file,sheet);
    [~, computer] = system('hostname');
    [~, user] = system('whoami');
    pause(0.5);
    [~, alltask] = system(['tasklist /S ', computer, ' /U ', user]);
    excelPID = regexp(alltask, 'EXCEL.EXE\s*(\d+)\s', 'tokens');
    for i = 1 : length(excelPID)
      killPID = cell2mat(excelPID{i});
      system(['taskkill /f /pid ', killPID]);
    end
end
    