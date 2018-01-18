function [trajectory, objects] = connectTrajectories(frameNum, objects, maxGap)

    trajectory = table;    
    
    if numel(objects) == 0
        return
    end
    
    %for each detection in current frame find matching trajectory in prev frame
    currF = (objects.frame == frameNum); 
    for i = find(currF)'
        
        points1 = objects.trajectory{i};
        
        if isempty(points1)
            continue;
        end
        
        pt3 = points1(1, :);
        pt4 = points1(end, :);

        %previous frame
        prevF = (objects.frame == frameNum - 1); 
        pt1 = [];
        pt2 = [];
        minGap = Inf;
        dir = [];
        id = [];

        %Find cc with smallest gap
        for j = find(prevF)'
            points2 = objects.trajectory{j};
            
            if isempty(points2)
                continue;
            end
            
            pt1_ = points2(1, :);
            pt2_ = points2(end, :);

            %check gap width & direction
            gap = [pointsDistance(pt1_, pt4), pointsDistance(pt2_, pt3)]
            
            %Direction 
            %[] = gap too big
            %1 = from right to left
            %2 = from left to right
            
            dir_ = find(gap < maxGap);
            
            if length(dir_) > 1
                [~, dir_] = min(gap);
            end
            
            if ~isempty(dir_) && gap(dir_) < minGap
                pt1 = pt1_;
                pt2 = pt2_;
                minGap = gap(dir_);
                dir = dir_;
                id = j;
            end  
        end           
        
        if isempty(dir)
            continue
        end   

        %Assign object id
        objects.objectId(i) = objects.objectId(id);

        %intersection point
        %int = lineIntersection(pt1, pt2, pt3, pt4);

%         keyboard;
%         figure();hold on;
%         set(gca,'YDir','Reverse');
%         scatter([pt1(1) pt2(1)], [pt1(2) pt2(2)]);
%         scatter([pt3(1) pt4(1)], [pt3(2) pt4(2)]);
%         scatter(int(1), int(2));
        
        if dir == 1
            %right to left
            points = [pt2; pt1; pt4; pt3;]'; 
        else    
            %left to right
            points = [pt1; pt2; pt3; pt4]';
        end

        distances = [pointsDistance(points(:, 1), points(:, 2)), ...
                 pointsDistance(points(:, 2), points(:, 3)), ...
                 pointsDistance(points(:, 3), points(:, 4))];
        t = [0 cumsum(distances ./ sum(distances))];

        T = table;
        T.objectId = objects.objectId(i);
        T.objectRow = i;
        T.t = {t};
        T.pt = {points(:, 1:4)'};
        
        if ~exist('trajectory')            
            trajectory = T;
        else            
            trajectory = [trajectory; T];
        end 
    end
    
function d = pointsDistance(pt1, pt2)
    d = sqrt((pt1(1)-pt2(1)).^2 + (pt1(2)-pt2(2)).^2);
