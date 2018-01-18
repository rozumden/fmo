function [cc, regions] = connectedComponents(mask, difference)    
%Function connectedComponents extracts connected components from mask and
%obtains additional information about regions
%
%Input: 
%mask       ... binary mask of moving objects
%difference ... differential image
%
%Output:
%cc ... matrix of connected component's labels
%regions ... table of regions 

    [cc, ~] = bwlabel(mask);
    regions = regionprops(mask ,'Area', 'Centroid', 'MajorAxisLength', 'Orientation', 'BoundingBox');  
    %Filter out small components
    
    sizeDivider = 1.0445e+04;
    smallRegionThr = (size(mask, 1) * size(mask, 2)) / sizeDivider;
    regions = regions(([regions.Area] > smallRegionThr), :);    

    colorMeans = [];
    %Compute mean color of cc
    for i = 1:numel(regions)        
        regions(i).Id = i;    
        pixels = difference(repmat([cc==i], [1 1 3])); %extract pixels of cc
        pixels = reshape(pixels, [length(pixels) / 3, 3]);    
        regions(i).ColorMean = mean(pixels, 1);
    end    
end