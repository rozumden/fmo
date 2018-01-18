function out = average_fmo_vid_gen(vid, fmos, n)
removed = APP.remove_vid(vid,fmos);
out = APP.average_vid(removed,n);

for i = 1:numel(fmos)
	if isempty(fmos{i}) || isempty(fmos{i}.res)
		continue;
	end
	u = fmos{i}.res.fg;
	m = repmat(double(fmos{i}.res.m),[1 1 3]);

	if i == numel(fmos)  || isempty(fmos{i+1})
		t = bwline2(fmos{i}.First,fmos{i}.Last,fmos{i}.Radius);
	else
		t = bwline2(fmos{i}.First,fmos{i+1}.First,fmos{i}.Radius);
	end
	full_traj = t.pixels';
	piece = floor(size(full_traj,2)/n);
	first = fmos{i}.First;
	for k = 1:(n-1)
		[~,idx] = pdist2(full_traj',first','euclidean','Smallest',piece+1);
		traj = full_traj(:,idx(1:(end-1)));
		first = full_traj(:,idx(end));
		inl = logical(ones(1,size(full_traj,2)));
		inl(idx(1:(end-1)))= 0;
		full_traj = full_traj(:,inl);
		out_ind = (i - 1)*n + k;
		if out_ind > size(out,4), return; end % dirty hack
		out(:,:,:,out_ind) = APP.add(out(:,:,:,out_ind), u, m, sub2ind(size(out),traj(2,:),traj(1,:)));
	end
	out(:,:,:,i*n) = APP.add(out(:,:,:,i*n), u, m, sub2ind(size(out),full_traj(2,:),full_traj(1,:)));
end
