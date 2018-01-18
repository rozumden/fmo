function seq = get_seq(n)
seq = [];

seq(numel(seq)+1).name = 'volleyball1.mp4';
seq(end).show = 9;

seq(numel(seq)+1).name = 'volleyball_passing.mp4';
seq(end).show = 4;

seq(numel(seq)+1).name = 'darts1.mp4';
seq(end).show = 49;

seq(numel(seq)+1).name = 'darts_window1.mp4'; 
seq(end).show = 37;

seq(numel(seq)+1).name = 'softball.avi'; %46, 56
seq(end).show = 56;

seq(numel(seq)+1).name = 'william_tell.avi';
seq(end).show = 32;

seq(numel(seq)+1).name = 'tennis_serve_side.avi';
seq(end).problems = [9 10 36 39 41 42];
seq(end).show = 40;

seq(numel(seq)+1).name = 'tennis_serve_back.avi';
seq(end).show = 35;

seq(numel(seq)+1).name = 'tennis1.avi';
seq(end).show = 18;

seq(numel(seq)+1).name = 'hockey.avi';
seq(end).show = 28;

seq(numel(seq)+1).name = 'squash.avi';
seq(end).show = 196;

seq(numel(seq)+1).name = 'frisbee.mp4';
seq(end).show = 82;

seq(numel(seq)+1).name = 'blue.mov'; %28, 31
seq(end).problems = [20];
seq(end).show = 31;

seq(numel(seq)+1).name = 'ping_pong_paint.mov'; %42, 77
seq(end).problems = [7 11 25 91 96 147 295 510 570];
seq(end).show = 42;

seq(numel(seq)+1).name = 'ping_pong_side.mp4';
seq(end).show = 14;

seq(numel(seq)+1).name  = 'ping_pong_top.mp4';
seq(end).problems = [4 7 9 10 11 44 38 51 54 58 61 85 95 105 116 124 143 174 182 289 324];
seq(end).show = 4;

% seq(numel(seq)+1).name = 'hail.mp4';
% seq(end).show = 4;

% seq(numel(seq)+1).name = 'fireworks.mp4';
% seq(end).show = 27;

if nargin == 1
	seq = seq(n);
end
