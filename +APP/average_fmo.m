function out = average_fmo(imgd,u,fmo,fmo1,n)
t = bwline2(fmo.First,fmo1.First,fmo.Radius);
% full_traj = [fmo.inter_traj.pixels' fmo.PixelList];
full_traj = t.pixels';
piece = floor(size(full_traj,2)/n);
first = fmo.First;
for k = 1:(n-1)
	[~,idx] = pdist2(full_traj',first','euclidean','Smallest',piece+1);
	traj = full_traj(:,idx(1:(end-1)));
	first = full_traj(:,idx(end));
	inl = logical(ones(1,size(full_traj,2)));
	inl(idx(1:(end-1)))= 0;
	full_traj = full_traj(:,inl);
	out(:,:,:,k) = APP.add(imgd, u, fmo.Color, sub2ind(size(imgd),traj(2,:),traj(1,:)));
end
out(:,:,:,n) = APP.add(imgd, u, fmo.Color, sub2ind(size(imgd),full_traj(2,:),full_traj(1,:)));
