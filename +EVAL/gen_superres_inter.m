EVAL.init();

file = fullfile(folder,seq{3});
file_fmo = fullfile(folder,'superres/69_60_slow8x_fmo.avi');

video = Video(file);
video_fmo = Video(file_fmo);

inc = 8;
n = 35;
img = video.get_frame(n);
img1 = video.get_frame(n+1);

if ~exist('rect','var') || isempty(rect)
	imshow(img/2 + img1/2);
	rect = round(getrect());
	x = rect(1); y = rect(2); u = x + rect(3); v = y + rect(4);
end

for i = 0:inc
	inter = (i/inc)*img1 + ((inc-i)/inc)*img;
	interfmo = video_fmo.get_frame((n-1)*inc+i);

	imwrite(interfmo(y:v,x:u,:),['imgs/superres_fmo' sprintf('%02d',i) '.png']);
	imwrite(inter(y:v,x:u,:),['imgs/superres_inter' sprintf('%02d',i) '.png']);
end