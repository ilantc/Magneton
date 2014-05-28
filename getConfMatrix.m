function out = getConfMatrix(confObj,numOfTargets) 
    out = zeros(numOfTargets,size(confObj,1));
    for i=1:size(confObj,1)
        if (confObj(i,1) > 0)
            for j=1:size(confObj,2)
                out(confObj(i,j),i)=1;
            end
        else 
            return
        end
    end
end