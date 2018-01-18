EVAL.init();
addpath('~/opt/vlfeat/toolbox/');
vl_setup;

cfg.verbose = 1;
cfg.write = 0;
cfg.show = 1;
cfg.save_frames = 0;
seq = seq(end);
for i = 1:numel(seq)
	video = Video(folder, seq(i).name);
	[frame{i},result{i}] = main_loop(video, cfg);
end
