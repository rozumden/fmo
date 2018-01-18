function out = change_radius(removed_front, u, fmo, xtimes, color)
if nargin < 5
	color = fmo.Color;
end
traj = fmo.Trajectory;
mask = zeros(size(removed_front,1),size(removed_front,2));
mask(traj) = 1;
u(u > 1) = 1;
u = imresize(u,xtimes);
M(:,:,1) = conv2(mask, u(:,:,1), 'same');
M(:,:,2) = conv2(mask, u(:,:,2), 'same');
M(:,:,3) = conv2(mask, u(:,:,3), 'same');
M = M/(numel(traj));

color3(:,:,1) = color(1);
color3(:,:,2) = color(2);
color3(:,:,3) = color(3);
out = removed_front.*(1 - M) + bsxfun(@mtimes, M, color3);
