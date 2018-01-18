function res = RDP(points, epsilon, varargin)
%Ramer-Douglas-Peucker algorithm reduces number of points by line
%approximation
%
%input:
%poits ... N-by-2 matrix containing 2D points
%epsilon ... float maximal distance
%varargin ... if 1 final points will be in opposite order
%
%output:
%res ... M-by-3 matrix (M final number of points after reduction)
%        1st.column - time in range [0; 1]
%        2nd & 3rd.column - point coordinates         

    if isempty(varargin)
        flip = false;
    else
        flip = varargin{1};
    end

    dMax = 0;
    id = [];
    for i = 2:size(points, 1)-1
        d = distanceFromLine(points(1, :), points(end, :), points(i, :));
        if d > dMax
            dMax = d;
            id = i;
        end
    end
    
    if dMax > epsilon
        r1 = RDP(points(1:id, :), epsilon);
        r2 = RDP(points(id:end, :), epsilon);
        res = [r1(1:end-1, :); r2(1:end, :)];
    else
        res = [points(1, :); points(end, :)];
    end
    
    distances = [];
    for i = 1:size(res, 1)-1
        distances(end+1) = sqrt((res(i, 1) - res(i+1, 1)).^2 + (res(i, 2) - res(i+1, 2)).^2);
    end
    
    if flip
        distances = fliplr(distances);
        res = flipud(res);
    end
    
    t = [0 cumsum(distances ./ sum(distances))];
    
    if size(res, 2) == 2
        res = [t', res];
    else
        res(:, 1) = t;
    end
end