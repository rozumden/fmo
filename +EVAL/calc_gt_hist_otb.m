function [d, iou] = calc_gt_hist_otb()
folder = '/mnt/home/rozumden/projects/fast_tracking/dataset/otb/anno';
files = dir(folder);
files = files(3:end);

d = cell(1,numel(files));
iou = cell(1,numel(files));
parfor i = 1:numel(files)
	[~,name,ext] = fileparts(files(i).name);
	if ~strcmp(ext,'.txt')
		continue
	end
	try
		[x1,y1,u,v] = textread(fullfile(folder,files(i).name), '%f,%f,%f,%f');
	catch
		[x1,y1,u,v] = textread(fullfile(folder,files(i).name), '%f\t%f\t%f\t%f');
	end
	x2 = x1+u; y2 = y1;
	x3 = x1+u; y3 = y1+v;
	x4 = x1; y4 = y1;
	centers = [mean([x1 x2 x3 x4]'); mean([y1 y2 y3 y4]')];
	m = ceil(max([x1; x2; x3; x4;]));
	n = ceil(max([y1; y2; y3; y4;]));
	for k = 2:numel(x1)
		dif = 1;
		edges0 = [[x1(k-1) x2(k-1) x3(k-1) x4(k-1)]; [y1(k-1) y2(k-1) y3(k-1) y4(k-1)]];
		edges1 = [[x1(k) x2(k) x3(k) x4(k)]; [y1(k) y2(k) y3(k) y4(k)]];
		edges = edges0 + (1/dif)*(edges1 - edges0);
		BW0 = poly2mask(edges0(1,:), edges0(2,:), n,m);
		BW = poly2mask(edges(1,:), edges(2,:), n,m);
		px0 = find(BW0);
		px = find(BW);
		d{i} = [d{i} norm(centers(:,k-1) - centers(:,k))/dif];
		iou{i}  = [iou{i} numel(intersect(px,px0))/ ...
		   numel(unique([px; px0]))];
	end
	disp(name)
end