function [all_d, all_iou] = calc_gt_hist_alov()
folder = '/mnt/home/rozumden/projects/fast_tracking/dataset/alov';
files = dir(folder);
files = files(3:end);

d = cell(1,numel(files));
iou = cell(1,numel(files));

parfor i = 1:numel(files)
	files_gt = dir(fullfile(folder,files(i).name));
	files_gt = files_gt(3:end);
	d{i} = cell(1,numel(files_gt));
	iou{i} = cell(1,numel(files_gt));
	for j = 1:numel(files_gt)
		[frame, x1,y1,x2,y2,x3,y3,x4,y4] = textread(fullfile(folder,files(i).name,files_gt(j).name));
		centers = [mean([x1 x2 x3 x4]'); mean([y1 y2 y3 y4]')];
		m = ceil(max([x1; x2; x3; x4;]));
		n = ceil(max([y1; y2; y3; y4;]));
		for k = 2:numel(frame)
			dif = (frame(k) - frame(k-1));
			edges0 = [[x1(k-1) x2(k-1) x3(k-1) x4(k-1)]; [y1(k-1) y2(k-1) y3(k-1) y4(k-1)]];
			edges1 = [[x1(k) x2(k) x3(k) x4(k)]; [y1(k) y2(k) y3(k) y4(k)]];
			edges = edges0 + (1/dif)*(edges1 - edges0);
			BW0 = poly2mask(edges0(1,:), edges0(2,:), n,m);
			BW = poly2mask(edges(1,:), edges(2,:), n,m);
			px0 = find(BW0);
			px = find(BW);
			d{i}{j} = [d{i}{j} norm(centers(:,k-1) - centers(:,k))/dif];
			iou{i}{j}  = [iou{i}{j} numel(intersect(px,px0))/ ...
			   numel(unique([px; px0]))];
		end
	end
	disp(files(i).name);
end
all_d = cellfun(@(x) [x{:}], d, 'UniformOutput',false);
% h = hist([all_d{:}],100);
% h = h/sum(h); % normalize to unit length. Sum of h now will be 1.
% bar(h, 'DisplayName', 'Travel Distance'); 
% xlim([0 50]);
% saveas(gcf,'dist_hist.png');

all_iou = cellfun(@(x) [x{:}], iou, 'UniformOutput',false);
% h = hist([all_iou{:}],100);
% h = h/sum(h); % normalize to unit length. Sum of h now will be 1.
% bar(h, 'DisplayName', 'Travel Distance'); 
% xlim([0 50]);
% saveas(gcf,'iou_hist.png');

