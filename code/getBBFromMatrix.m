function out = getRectBBMatrix(matrix, bb)
%Function getRectBBMatrix returns a matrix area specified by axis-aligned
%bounding box
%
%input: 
%matrix ... matrix from which the rectangle area will be extracted
%bb ... axis-aligned bounding box specifying extraction rectangle area
%
%output:
%out ... extracted matrix

    rStart = max(1, floor(bb(2)));
    rEnd = min(floor(bb(2) + bb(4)), size(matrix, 1));
    cStart = max(1, floor(bb(1)));
    cEnd = min(floor(bb(1) + bb(3)), size(matrix, 2));
    out = matrix(rStart:rEnd, cStart:cEnd);
end