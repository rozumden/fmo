function [] = run_baselines(seq_name, method)
dataset = '/mnt/home/rozumden/projects/fast_tracking/dataset/dataset_bbx';
folder = '/mnt/home/rozumden/projects/fast_tracking/dataset/baseline_results';


imgs = dir(fullfile(dataset,seq_name));
imgs = imgs(3:end);
[x,y,u,v] = textread(fullfile(folder,method,[seq_name '.txt']),'%f,%f,%f,%f');

for i = 1:numel(imgs)
	img = imread(fullfile(dataset,seq_name,imgs(i).name));
	image(img);
	hold on;
	rectangle('Position',[x(i) y(i) u(i) v(i)]);
	drawnow;
end

