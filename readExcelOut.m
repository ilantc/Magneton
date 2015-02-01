function [ output_args ] = readExcelOut(excelOut, currTime)
    for excelLine = 1:size(excelOut,1):
        currAgent = excelOut(excelLine,1)
        currTarget = excelOut(excelLine,2)
        startTime = excelOut(excelLine,4)
        endTime = excelOut(excelLine,5)
    end
end

