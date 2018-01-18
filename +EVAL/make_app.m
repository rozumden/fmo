EVAL.init();

seq = [];
seq.name = '69_60_bird.mp4';
video = Video(folder, seq.name);
frm_n = 35;
nx = 10;

load('69_60_bird_frames.mat');
load('ball_69_60_frame35.mat');

back = (video.get_frame(frm_n-1));
front = (video.get_frame(frm_n));

rect = [1 1 size(back,2)-1 size(back,1)-1];
rect2 = rect;

fmo0 = frame{frm_n-1};
fmo = frame{frm_n};
fmo1 = frame{frm_n+1};
fmo1.add_edges(fmo);
fmo.inter_traj = bwline2(fmo.First,fmo1.First,fmo.Radius);
full_traj = sub2ind(size(back),fmo.inter_traj.pixels(:,2),fmo.inter_traj.pixels(:,1));

imgd = APP.remove(back, front, fmo.PixelIdxList);
imga = APP.add(imgd, u, fmo.Color, fmo.Trajectory);
imga2 = APP.add(imgd, u, fmo.Color, full_traj);
imgc = APP.change_color(imgd, u, fmo.Trajectory,[0 1 0]);
imgr = APP.change_radius(imgd, u, fmo, 2);
imgr2 = APP.change_radius(imgd, u, fmo, 0.5);
imgrc = APP.change_radius(imgd, u, fmo, 1.5, [1 0 1]);

x = rect(1); y = rect(2);
x2 = rect(3); y2 = rect(4);
imwrite(front(y:(y+y2),x:(x+x2),:),'imgs/apps/fmo.png');
imwrite(imgd(y:(y+y2),x:(x+x2),:),'imgs/apps/remove.png');
imwrite(imga(y:(y+y2),x:(x+x2),:),'imgs/apps/add.png');
imwrite(imga2(y:(y+y2),x:(x+x2),:),'imgs/apps/add_full.png');
imwrite(imgc(y:(y+y2),x:(x+x2),:),'imgs/apps/color.png');
imwrite(imgr(y:(y+y2),x:(x+x2),:),'imgs/apps/radius.png');
imwrite(imgr2(y:(y+y2),x:(x+x2),:),'imgs/apps/radius2.png');
imwrite(imgr2(y:(y+y2),x:(x+x2),:),'imgs/apps/radius2.png');
imwrite(imgrc(y:(y+y2),x:(x+x2),:),'imgs/apps/radius_color.png');

out = APP.average(back, front, nx);
out2 = APP.average_fmo(imgd, u, fmo0, fmo, nx);

fmo0.Color = [198 237 44]/255;
fmo0.Radius = (10/4)*fmo0.Radius + 3;
u2 = imresize(u,10/4);

BW = logical(zeros(size(u2)));
BW = BW(:,:,1);
center = [round(size(u2)/2)];
BW(center(1),center(2)) = 1;
dist = bwdist(BW);
BW2 = BW | (dist <= fmo0.Radius);
u2(~repmat(BW2, [1 1 3])) = 0;
out3 = APP.average_fmo(imgd, u2, fmo0, fmo, nx);

x = rect2(1); y = rect2(2);
x2 = rect2(3); y2 = rect2(4);
% for i = 1:size(out,4)
for i = 6
	imwrite(out(y:(y+y2),x:(x+x2),:,i),['imgs/apps/average' int2str(i) '.jpg']);
	imwrite(out2(y:(y+y2),x:(x+x2),:,i),['imgs/apps/average_fmo' int2str(i) '.jpg']);
	imwrite(out3(y:(y+y2),x:(x+x2),:,i),['imgs/apps/average_fmo_change' int2str(i) '.jpg']);
end
