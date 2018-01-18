addpath('helpers');

warning('off','all');
global check_file;
if isempty(check_file)
	check_file = containers.Map;
end

% folder = '/mnt/lascar/rozumden/fast_tracking';
% folder = '/home/rozumnyi/lascar/projects/fast_tracking/mnt_copy/';
folder = '/mnt/home/rozumden/projects/fast_tracking/dataset/';

seq = get_seq();

cfg.verbose = 1;
cfg.write = 0;
cfg.show = 1;
cfg.save_frames = 0;