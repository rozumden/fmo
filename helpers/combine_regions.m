function region = combine(regions)
if isempty(regions)
	region = Frame();
	return
end
region = Frame(regions(1));
if numel(regions) == 1
	return
end
region.PixelIdxList = [regions.PixelIdxList];
region.PixelList = [regions.PixelList];
region.Distances = [regions.Distances];
region.Radius = max([regions.Radius]);
region.Alpha = mean([regions.Alpha]);
region.Trajectory = [regions.Trajectory];
region.TrajectoryXY = [regions.TrajectoryXY];
if ~isempty(regions(1).TrajectoryXY)
	for i = 1:(numel(regions)-1)
		dist = Inf*ones(1,numel(regions));
		for j = 1:numel(regions)
			if j > i
				[d,idx] = pdist2(regions(i).TrajectoryXY',regions(j).TrajectoryXY','euclidean','Smallest',1);
				[v,ind] = min(d);
				dist(j) = v;
				iv(j) = idx(ind);
				jv(j) = ind;
			end
		end
		[~,m] = min(dist);
		traj = bwline2(regions(i).TrajectoryXY(:,iv(m)),regions(m).TrajectoryXY(:,jv(m)));
		region.TrajectoryXY = [region.TrajectoryXY traj.pixels'];
	end
end
region.Direction = unique([regions.Direction]);
if ~isempty(region.MixedColor)
	region.MixedColor = mean(reshape([regions.MixedColor],3,[])')';
end
if ~isempty(region.Color)
	region.Color = mean(reshape([regions.Color],3,[])')';
end
if ~isempty(region.Orientation)
	[~,ind] = max([regions.Length]);
	region.Orientation = regions(ind).Orientation;
end
region.Length = sum([regions.Length]);
if ~isempty(region.Centroid)
	if numel(regions) > 1
		region.Centroid = mean(reshape([regions.Centroid],2,[])');
	else
		region.Centroid = regions.Centroid;
	end
end
if ~isempty(region.Area)
	region.Area = sum([regions.Area]);
end
if ~isempty(region.BoundingBox)
	bbs = reshape([regions.BoundingBox],4,[])';
	region.BoundingBox = zeros(1,4);
	region.BoundingBox(1:2) = [min(bbs(:,1)) min(bbs(:,2))];
	region.BoundingBox(3:4) = [max(bbs(:,1)+bbs(:,3)) max(bbs(:,2)+bbs(:,4))] - region.BoundingBox(1:2);
end
region.best = unique([regions.best]);

region.check1();
region.check2();