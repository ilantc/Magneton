 function [val]=calculate_assign_value(match,targetsData)
    VAL_COL=3;
    global allConf;
    choosen_conf= allConf(:,match');
    targets=sum(choosen_conf,2)>0;
    val=(8-targetsData(:,VAL_COL)') * targets;     
 end
        
      