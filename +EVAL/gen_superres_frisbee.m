load('recon_08_biggerBB.mat');
load('08_25fps_s50_result.mat');
EVAL.init();
video = Video(folder,seq(end-4).name);
nx = 10;
recon = res(10);
fmo = Frame(frames(recon.ind));
fmo0 = Frame(frames(recon.ind-1));
fmo.add_edges(fmo0);

front = video.get_frame(recon.ind);
back = video.get_frame(recon.ind-1);
backback = video.get_frame(recon.ind-2);
fmo.PixelIdxList = sub2ind([size(back,1) size(back,2)],fmo.PixelList(2,:),fmo.PixelList(1,:));

% image(front);
% hold on;
% plot(fmo.BoundaryXY(1,:),fmo.BoundaryXY(2,:),'.b');
% plot(fmo.TrajectoryXY(1,:),fmo.TrajectoryXY(2,:),'.b');

imgd = APP.remove(backback, front, fmo.PixelIdxList);

out = APP.average(back, front, nx);

u = recon.fg;
fmo.Radius = fmo.Radius + 10;
BW = logical(zeros(size(u)));
BW = BW(:,:,1);
center = [round(size(u)/2)];
BW(center(1),center(2)) = 1;
dist = bwdist(BW);
BW2 = BW | (dist <= fmo.Radius);
u(~repmat(BW2, [1 1 3])) = 0;
out2 = APP.average_fmo(imgd, u, fmo0, fmo, nx);

for i = 6
	imwrite(out(:,:,:,i),['imgs/frisbee_SR/average' int2str(i) '.jpg']);
	imwrite(out2(:,:,:,i),['imgs/frisbee_SR/average_fmo' int2str(i) '.jpg']);
end
