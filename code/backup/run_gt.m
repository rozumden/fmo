folder = '/mnt/lascar/rozumden/fast_tracking';
seq = 'ping_pong_top';

hold on;
file = fullfile(folder,'input',seq);
files = dir(file);
load(fullfile(folder,'output',[seq '.mat']));
for i = 1:numel(files)
	im = imread(fullfile(file,files(i+2).name));
	imshow(im);
	region = regionprops(allMasks{i});
	if ~isempty(region)
		rectangle('pos',region.BoundingBox,'EdgeColor','r');
	end
	drawnow;
end