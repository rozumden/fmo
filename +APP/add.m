function out = add(removed_front, u, m, traj)
gam = 2.2;

mask = zeros(size(removed_front,1),size(removed_front,2));
mask(traj) = 1;
u(u > 1) = 1;
HF(:,:,1) = conv2(mask, u(:,:,1), 'same');
HF(:,:,2) = conv2(mask, u(:,:,2), 'same');
HF(:,:,3) = conv2(mask, u(:,:,3), 'same');
HF = HF/(numel(traj));
HF(HF > 1) = 1;
HF(HF < 0) = 0;

HM(:,:,1) = conv2(mask, m(:,:,1), 'same');
HM(:,:,2) = conv2(mask, m(:,:,2), 'same');
HM(:,:,3) = conv2(mask, m(:,:,3), 'same');
HM = HM/(numel(traj));
HM(HM > 1) = 1;
HM(HM < 0) = 0;

out = removed_front.^gam.*(1 - HM) + HF;
out = out.^(1/gam);

out(out > 1) = 1;
out(out < 0) = 0;