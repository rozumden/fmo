function dif = stabilize_dif(im,im0, n)
% dif = Inf*ones(size(im));
% sz1 = size(im,1);
% sz2 = size(im,2);
% for i = -n:n
% 	for j = -n:n
% 		rng1 = [1:sz1];
% 		rng1 = rng1 + i;
% 		rng1(rng)
% 		rng2 = [1:sz2];
% 		dif = min(dif, abs(im - im0(rng1,rng2,:) ));
% 	end
% end

dif = abs(im - im0);
dif = min(dif, abs(im - im0([2:end end], :, :)));
dif = min(dif, abs(im - im0(:, [2:end end], :)));
dif = min(dif, abs(im - im0(:, [1 1:(end-1)], :)));
dif = min(dif, abs(im - im0([1 1:(end-1)], :, :)));

dif = min(dif, abs(im - im0([2:end end], [2:end end], :)));
dif = min(dif, abs(im - im0([1 1:(end-1)], [2:end end], :)));
dif = min(dif, abs(im - im0([2:end end], [1 1:(end-1)], :)));
dif = min(dif, abs(im - im0([1 1:(end-1)], [1 1:(end-1)], :)));


% if numel(frame{i-1}) == 1 && ~frame{i-1}.empty
% 	[F,J] = CONV.deconv(im,im0,frame{i-1});
% 	if any([F(:)] > 1), F = F/max(F(:)); end
% 	traj = CONV.get_traj(im1,im,F);
% end