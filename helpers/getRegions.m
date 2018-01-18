function frame = getRegions(bin,dif)
if nargin < 2
	dif = [];
end
regions = regionprops(bin,'Centroid','MajorAxisLength','Orientation','BoundingBox','PixelIdxList','PixelList');
cc = repmat(bwlabel(bin),[1 1 3]);
dist = bwdist(~bin);
offset = size(bin,1)*size(bin,2);
if isempty(regions)
	frame = [];
	return;
end

for i = 1:numel(regions)
	regions(i).Distances = dist(regions(i).PixelIdxList);
	regions(i).Radius = max(regions(i).Distances);
    regions(i).Alpha = (2*regions(i).Radius)/(regions(i).MajorAxisLength - regions(i).Radius);

	normd = regions(i).Distances/regions(i).Radius;
    regions(i).Trajectory = regions(i).PixelIdxList(normd > 0.7);
    regions(i).TrajectoryXY = regions(i).PixelList(normd > 0.7,:);
	ind = [regions(i).Trajectory ...
			 regions(i).Trajectory+offset ...
			  regions(i).Trajectory+2*offset];
	if ~isempty(dif)
		colors = dif.front(ind);
		if numel(ind) > 3
		regions(i).MixedColor = mean(colors)';
		else
			regions(i).MixedColor = colors';
		end
	end
	regions(i).Direction = [1:2];
	frame(i) = Frame(regions(i));
end

