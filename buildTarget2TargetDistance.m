function [target2TargetDistance] = buildTarget2TargetDistance(infile, nTargets)
    %a20MinDistance = 48000;
    %target2TargetDistance = ones(nTargets + 1, nTargets + 1) * a20MinDistance;
    target2TargetDistance = read_excel_and_clean(infile,'MissionsRange');
    % add distnace from source to all targets
    target2TargetDistance = [zeros(size(target2TargetDistance,1),1) target2TargetDistance];
    target2TargetDistance = [zeros(1,size(target2TargetDistance,2)); target2TargetDistance];
end