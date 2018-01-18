EVAL.init();
d = cell(1,numel(seq));
iou = cell(1,numel(seq));

parfor i = 1:numel(seq)
	video = Video(folder, seq(i).name);
	img = video.get_frame(1);
	sz = [size(img,1) size(img,2)];
	frm0 = Frame();
	for j = 1:video.size()
		frm = video.gt.get_frame(j,sz);
		if ~frm0.empty && ~frm.empty
			d{i} = [d{i} norm(frm.Centroid - frm0.Centroid)];
			iou{i} = [iou{i} numel(intersect(frm.PixelIdxList,frm0.PixelIdxList))/ ...
			   numel(unique([frm.PixelIdxList frm0.PixelIdxList]))];
		end
		frm0 = frm;
	end
	disp(seq(i).name);
end

method(1).d = d; method(1).iou = iou;
method(1).name = 'FMO';
method(1).color = [0 0 1];

[method(2).d, method(2).iou] = EVAL.calc_gt_hist_vot();
method(2).name = 'VOT';
method(2).color = [1 0 0];

[method(3).d, method(3).iou] = EVAL.calc_gt_hist_otb();
method(3).name = 'OTB';
method(3).color = [0.5 0 0];

[method(4).d, method(4).iou] = EVAL.calc_gt_hist_alov();
method(4).name = 'ALOV';
method(4).color = [1 0.5 0];

dist_bins = [0:10:150];
iou_xbins = [0:0.1:1];
for i = 1:numel(method)
	method(i).dist_h = hist([method(i).d{:}],dist_bins);
	method(i).dist_h = method(i).dist_h/sum(method(i).dist_h);

	method(i).iou_h = hist([method(i).iou{:}],iou_xbins);
	method(i).iou_h = method(i).iou_h/sum(method(i).iou_h);
end

order_iou = [1 2 3 4];
h = reshape([method(order_iou).iou_h],[],numel(method));
b = bar(iou_xbins, h, 1,'histc'); 
for i = 1:numel(method)
	set(b(i),'FaceColor',method(i).color);
end
legend(method(order_iou).name)
set(gca,'Color',[1 1 1]);
xlim([0 1.07]);
set(gca,'fontsize',30);
% xlabel('Intersection');
% ylabel('Probability');
% saveas(gcf,'iou_hist.png');

% h = [method(1).dist_h; method(2).dist_h; method(3).dist_h; method(4).dist_h]';
% bar(dist_bins, h, 1,'histc'); 
% legend('FMO','VOT','OTB','ALOV')
% set(gca,'Color',[1 1 1]);
% set(gca,'fontsize',30);
% xlim([0 160]);
% xlabel('Distance between centers');
% ylabel('Probability');
% saveas(gcf,'dist_hist.png');