function [target2Val] = buildTarget2Val(infile) 
    
    PRIORITY_COL    = 3;
    targets  = xlsread(infile,'InMissions');
    target2Val = targets(:,PRIORITY_COL);
    target2Val = 8 - target2Val;
    
end
