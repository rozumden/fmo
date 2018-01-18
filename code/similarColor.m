function [status, nextObjectId, nextObjectRegionsId]  = similarColor(predIds, regions, objectColor)
%Function similarColor searches for most similar color in predicted area
%
%Input: 
%predIds     ... ids of regions from predicted area
%regions     ... table of connected components regions
%objectColor ... color of object being tracked
%
%Output:
%status              ... 1 if matchig failed
%                        otherwise it was successful
%nexObjectId         ... connected component id of most similar object
%mextObjectRegionsId ... regions id of most similar object

    status = 0;
    nextObjectId = [];
    nextObjectRegionsId = [];
    
    minD = Inf;
    nextObjectId = [];
    nextObjectRegionsId = [];
                       
    if isempty(predIds)
        status = 1;
        return;
    end
            
    for i = predIds'   
        regionsId = find(regions.Id(:) == i);
        if isempty(regionsId)
            continue
        end                
        cm = regions.ColorMean(regionsId, :);

        d = ((cm(1) - objectColor(1))*255).^2 + ...
            ((cm(2) - objectColor(2))*255).^2 + ...
            ((cm(3) - objectColor(3))*255).^2;         

        if d < minD
            minD = d;
            nextObjectId = i;
            nextObjectRegionsId = regionsId;
        end
    end
            
    if minD == Inf
        status = 1;
        return;
    end
end