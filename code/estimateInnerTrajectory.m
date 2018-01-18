function [centers, lines] = estimateInnerTrajectory(entryPointId, exitPointId, objectBoundary)
%Function estimateInnerTrajectory performs a skeletonization of blurred
%stroke
%
%Input:
%entryPointId   ... index of row of objectBoundary corresponding to entry
%                   point, if left empty, entry point is assumed to be
%                   exactly opposite to exit point
%exitPointId    ... indef of row of objectBoundary corresponding to exit
%                   point
%objectBoundary ... N-by-2 matrix containing boundary points sorted
%                   clock-wise
%
%Output:
%centers ... M-by-2 matrix containing skeleton points
%lines   ... M-by-4 matrix containing lines. Centers of these lines form
%            the skeleton

if isempty(entryPointId)
        len = floor(size(objectBoundary, 1) / 2); 
        
        if exitPointId < len
            cw = objectBoundary(exitPointId:exitPointId+len, :);
            ccw = [objectBoundary(fliplr(1:exitPointId), :); objectBoundary(fliplr(exitPointId+len:size(objectBoundary, 1)), :)];
            if mod(size(objectBoundary, 1), 2) == 1
                cw(end+1, :) = cw(end, :);
            end
        elseif exitPointId > len
            cw = [objectBoundary(exitPointId:end, :); objectBoundary(1:exitPointId-len, :)];
            ccw = objectBoundary(fliplr(exitPointId-len:exitPointId), :);
            if mod(size(objectBoundary, 1), 2) == 1
                ccw(end+1, :) = ccw(end, :);
            end
        else
            cw = objectBoundary(exitPointId:end, :);
            ccw = [objectBoundary(fliplr(1:exitPointId), :); objectBoundary(1, :)];
            if mod(size(objectBoundary, 1), 2) == 1
                ccw(end+1, :) = ccw(end, :);
            end
        end       
        cw = flipud(cw);
        ccw = flipud(ccw);        
        lines = [cw ccw];
        centers = (cw + ccw) ./ 2;
else        
    minId = min([entryPointId, exitPointId]);
    maxId = max([entryPointId, exitPointId]);
    
    line1 = objectBoundary(minId:maxId, :);
    line2 = [objectBoundary(maxId:end, :); objectBoundary(1:minId, :)];
    
    if entryPointId > exitPointId
        line2 = flipud(line2);
    else
        line1 = flipud(line1);
    end
    
    s1 = size(line1, 1);
    s2 = size(line2, 1);
    if s1 > s2
        ids = 0:s2 - 1; 
        ids = floor(ids .* (s1-1) ./ (s2-1)) + 1;
        lines = [line2 line1(ids, :)];
        centers = (line2 + line1(ids, :)) ./ 2;
    else
        ids = 0:s1-1;
        ids = floor(ids .* (s2-1) ./ (s1-1)) + 1;
        lines = [line1 line2(ids, :)];
        centers = (line1 + line2(ids, :)) ./ 2;
    end
end
