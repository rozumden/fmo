EVAL.init();

cfg.verbose = 0;
cfg.write = 0;
cfg.show = 0;
cfg.save_frames = 0;
parfor i = 1:numel(seq)
	warning('off','all')
	addpath(genpath('.'))
	video = Video(folder, seq(i).name);
	disp(seq(i).name)
	try
		[frame{i},models{i},result{i},gmodel{i}] = main_loop(video, cfg);
	catch ME
		disp([int2str(i) ' ' ME.message])
	end
end

