function [allMasks, trajectory] = BSD(path)
%Function detectBlurredStrokes detects blurred strokes in given video
%sequence
%
%Input:
%path ... path to video file
%
%Output: 
%allMasks   ... cell array of frame-by-frame binary masks of detected blurred
%               strokes
%trajectory ... N-by-4 matrix containing information about trajectory
%               each line contains 1 point, the start of a line, this
%               line's end is same as next line's start
%               1st column:       timestamp of start of current line
%                                 if NaN, camera shutter was closed  
%               2nd & 3rd column: x & y coordinates of start of line
%               4th column: object id of current trajectory

noiseThreshold = 5 / 255;
knnDistance = 10;
overlapThr = 0.05;
interactive = true;
showSR = true;

if interactive
    figure;
    title('Press any key to continue');
    drawnow;
end

% in = VideoReader(path, 'CurrentTime', 0);
frames = {};
allRegions = {};
allPredictions = {};
allBounaries = {};
allDirections = {};
allCenters = {};
allMasks = {};
trajectory = [];
objectFound = false;
objectConfirmed = false;
trajectoryId = 0;

folder = '/mnt/lascar/rozumden/fast_tracking';
seq1 = 'kick_serve-cut.mp4';
seq2 = 'hockey_shots/L_02_28';
seq3 = 'pingpong/69_60_bird';
seq4 = 'pingpong/70_100_bird';

seq = seq3;
file = fullfile(folder,seq);
files = dir(file);

%Load first frame
tic;
frameNum = 1;
frames{frameNum} = imread(fullfile(file,files(3).name));
display(sprintf('Frame %d, currTime %f', frameNum, toc));
frameNum = frameNum + 1;

for i = 4:numel(files)
    %Load next frame    
    if frameNum > length(frames)
        frames{frameNum} = imread(fullfile(file,files(i).name));
    end    
    display(sprintf('Frame %d, currTime %f', frameNum, toc));
  
    %% Differential image
    [difference, mask] = differential(frames{frameNum}, frames{frameNum - 1}, noiseThreshold);
    
    %% Connected components extraction
    %Label connected components
    [cc, regions] = connectedComponents(mask, difference);
    allRegions{frameNum} = regions;
    
    %Get objects boundaries
    boundaries = bwboundaries(mask, 'noholes');
    
    if frameNum > 2 
        
        %% Knn
        if ~objectFound             
            [status, bestKnn] = knnSearchBSD(regions, allRegions{frameNum - 1}, knnDistance);
            
            if(status == 1)
                frameNum = frameNum + 1;
                continue
            end;
                       
            trajectoryId = trajectoryId + 1;            
            objectId = regions.Id(bestKnn); 
            bb = regions.BoundingBox(bestKnn, :);
            tmp = mask;    
            tmp(cc ~= objectId) = 0;     
            allMasks{frameNum-1} = tmp;
            objectMask = getBBFromMatrix(tmp, bb);
            objectColor = regions.ColorMean(bestKnn, :);
            objectArea = regions.Area(bestKnn);
            objectMajor = regions.MajorAxisLength(bestKnn);

            %Predict object movement        
            predictions = predictMovement(regions.MajorAxisLength(bestKnn), ...
                                          regions.Orientation(bestKnn), bb);
            allPredictions{frameNum-1} = predictions;

            direction = [1, 2];        
            allDirections{frameNum-1} = direction;
            objectBoundary = boundaries{objectId};
            allBoundaries{frameNum-1} = objectBoundary;
            entryPointId = [];

            %Show input results    
            if interactive   
                imshow(frames{frameNum-1}); 
                title('Press any key to continue');
                hold on;
                rectangle('Position', predictions(1, :), 'EdgeColor', 'y', 'LineWidth', 2);
                rectangle('Position', predictions(2, :), 'EdgeColor', 'y', 'LineWidth', 2);
                plot(objectBoundary(:, 2), objectBoundary(:, 1), 'g', 'LineWidth', 2); 
                drawnow;
                pause;
            end
            
            objectFound = true;
            objectConfirmed = false;
        else %Motion prediction
            
            %% Extract objects ids from predicted areas
            if length(direction) > 1
                predIds1 = unique(getBBFromMatrix(cc, predictions(1, :)));
                s = size(predIds1);
                if s(1) < s(2)
                    predIds1 = predIds1';
                end
                predIds2 = unique(getBBFromMatrix(cc, predictions(2, :)));
                s = size(predIds2);
                if s(1) < s(2)
                    predIds2 = predIds2';
                end
                predIds = unique([predIds1; predIds2]);
            else
                predIds = unique(getBBFromMatrix(cc, predictions(direction, :)));
            end
            
            %% Predicted areas are empty
            if isempty(predIds)
                objectFound = false;
                continue
            end

            %% Ignore background
            if predIds(1) == 0
                predIds = predIds(2:end);
            end

            %% Select object with most similar color
            [status, nextObjectId, nextObjectRegionsId]  = similarColor(predIds, regions, objectColor);
            
            if status == 1
                objectFound = false;
                if ~objectConfirmed
                    allMasks{frameNum-2} = [];
                end
                continue
            end        
            nextObjectArea = regions.Area(nextObjectRegionsId);        
            
            %% Check for significant object size change
            if 2.5*objectArea < nextObjectArea || (1/2.5) * objectArea > nextObjectArea
                objectFound = false;
                if ~objectConfirmed
                    allMasks{frameNum-2} = [];
                end
                continue;
            end
            
            %% Check for overlap
            tmp = mask;    
            tmp(cc ~= nextObjectId) = 0;            
            prevMask = allMasks{frameNum-2};
            if ~isempty(prevMask)
                union = tmp | prevMask;
                intersection = tmp & prevMask;
                overlap = sum(intersection(:)) / sum(union(:));
                if overlap > overlapThr
                    objectFound = false;
                    if ~objectConfirmed
                        allMasks{frameNum-2} = [];
                    end
                    continue;
                end
            end
            objectArea = nextObjectArea;
            
            %% Preserve direction of motion from previous frame
            if length(direction) > 1            
                if any(predIds1 == nextObjectId) 
                    direction = 1;
                else
                    direction = 2;
                end
            end          

            %% Extract object mask
            bb1 = regions.BoundingBox(nextObjectRegionsId, :);               
            allMasks{frameNum-1} = tmp;
            objectMask1 = getBBFromMatrix(tmp, bb1);

            %% Predict object movement        
            predictions = predictMovement(regions.MajorAxisLength(nextObjectRegionsId), ...
                                          regions.Orientation(nextObjectRegionsId), bb1);
            
            allPredictions{frameNum-1} = predictions;
            allDirections{frameNum-1} = direction;
                                      
            %% Get objects boundaries
            nextObjectBoundary = boundaries{nextObjectId};        
            allBoundaries{frameNum-1} = nextObjectBoundary;
            objectBoundary = allBoundaries{frameNum-2};
            
            %% Find closest points (entry and exit points)
            minD = Inf;
            pair = [];        
            for i = 1:size(objectBoundary, 1)
                d = (objectBoundary(i, 1) - nextObjectBoundary(:, 1)).^2 + ...
                    (objectBoundary(i, 2) - nextObjectBoundary(:, 2)).^2;

                [m, id] = min(d);

                if m < minD
                    minD = m;
                    pair = [i; id];
                end
            end    
            
            %% Estimate object's inner trajectory
            points = [objectBoundary(pair(1), :); nextObjectBoundary(pair(2), :)];
            [centers, lines] = estimateInnerTrajectory(entryPointId, pair(1), objectBoundary); 
            
            %% Perform RDP reduction
            allCenters{frameNum-2} = centers;
            T = RDP(centers, 2, false); 
            T = [T; NaN, points(2, :)];
            T(:, 1) = T(:, 1) + frameNum - 1;
            T = [T, repmat(trajectoryId, size(T, 1), 1)];
            trajectory = [trajectory; T];
            
            objectConfirmed = true;
                        
            if interactive            
                imshow(frames{frameNum-1});
                title('Press any key to continue');
                hold on;
                b = allBoundaries{frameNum-2};
                plot(b(:, 2), b(:, 1), 'r', 'LineWidth', 2);
                b = allBoundaries{frameNum-1};
                plot(b(:, 2), b(:, 1), 'g', 'LineWidth', 2);
                d = allDirections{frameNum-1};
                p = allPredictions{frameNum-1};
                rectangle('Position', p(d, :), 'EdgeColor', 'y', 'LineWidth', 2);
                to = find(trajectory(:, 1) == frameNum);
                from = find(trajectory(:, 4) == trajectoryId, 1);
                for i = from:to(1)
                    if isnan(trajectory(i+1, 1))
                        color = 'c';
                    else
                        color = 'b';
                    end
                    line([trajectory(i, 3), trajectory(i+1, 3)], [trajectory(i, 2), trajectory(i+1, 2)], ...
                        'Color', color, 'LineStyle', '-', 'LineWidth', 2);
                end 
                drawnow;
                pause;
            end
            
            if showSR            
                %%Super resolution
                supMask = allMasks{frameNum-2};
                i = round(0.5 * size(lines, 1));
                supMask = printLine(supMask, lines(i, [2 4]), lines(i, [1 3]));
                supL = bwlabel(supMask, 4);
                first = supL(centers(1, 1), centers(1, 2));
                second = supL(centers(end, 1), centers(end, 2));
                
                im = frames{frameNum-2};
                im2 = im;
                bg = frames{frameNum-1};
                mask1 = repmat(supL == second, 1, 1, 3);
                im(mask1) = bg(mask1);
                mask2 = repmat(supL == first, 1, 1, 3);
                im2(mask2) = bg(mask2); 
                
                figure();
                subplot(2, 1, 1), imshow(im), subplot(2, 1, 2), imshow(im2);  drawnow;
            end
        end
    end    
    frameNum = frameNum + 1;    
end %end while hasFrame(in)