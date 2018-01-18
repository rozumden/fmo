function [status, id] = knnSearchBSD(regions, oldRegions, knnDistance)
%Function knnSearch performs k-nearest neighbours matching to find
%tentative blurred strokes
%
%Input:
%regions     ... regions from current frame
%oldRegions  ... regions from previous frame
%knnDistance ... maximal distance threshold
%
%Output:
%status ... if 1 matching failed
%           successful otherwise
%id     ... id of best match from regions

    id = [];
    status = 0;
    
    if(isempty(oldRegions))
        status = 1;
        return;
    end
    
    distances = [];
    ids =  []; 
    old.Centroid = reshape([oldRegions.Centroid],2,[])';   
    old.ColorMean = reshape([oldRegions.ColorMean],3,[])';               
    for i = 1:numel(regions)
    	%distance function   
        d = (old.Centroid(:, 1) - regions(i).Centroid(1)).^2 + ...
            (old.Centroid(:, 2) - regions(i).Centroid(2)).^2 + ...
            ((old.ColorMean(:, 1) + regions(i).ColorMean(1))*255).^2 + ...
            ((old.ColorMean(:, 2) + regions(i).ColorMean(2))*255).^2 + ...
            ((old.ColorMean(:, 3) + regions(i).ColorMean(3))*255).^2;               
            [distances(i), ids(i)] = min(d);          
    end   
    %Sort distances
    [distances, order] = sort(distances, 'ascend');
    ids = ids(order); 
            
    if isempty(distances) || distances(1) > knnDistance
        status = 1;
        return;
    end
    
    id = order(1);
end