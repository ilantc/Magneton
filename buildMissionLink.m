function [ missionLink ] = buildMissionLink(infile,numOfTargets)
    
    missionLink     = zeros(numOfTargets,numOfTargets);
    missionLinkTab  = xlsread(infile,'MissionsLink');
    missionLinkTab  = missionLinkTab(:,[1 3]);
    
    for link=1:size(missionLinkTab,1)
        missionLink(missionLinkTab(link,1),missionLinkTab(link,2)) = 1;
        missionLink(missionLinkTab(link,2),missionLinkTab(link,1)) = 1;
    end
end