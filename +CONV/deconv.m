function [F,J] = deconv(im, im0, frm)
bbs = frm.BoundingBox - [10 10 -20 -20];
try
	im(bbs(2):(bbs(2)+bbs(4)),bbs(1):(bbs(1)+bbs(3)),:);
catch
	bbs = frm.BoundingBox;
end
I = im(bbs(2):(bbs(2)+bbs(4)),bbs(1):(bbs(1)+bbs(3)),:);
b = im0(bbs(2):(bbs(2)+bbs(4)),bbs(1):(bbs(1)+bbs(3)),:);
BW = zeros(size(im,1),size(im,2));
BW(frm.Trajectory) = 1;
traj = BW(bbs(2):(bbs(2)+bbs(4)),bbs(1):(bbs(1)+bbs(3)),:);
traj = double(traj);
[F,J] = CONV.get_F(I, b, traj, round(frm.Radius));