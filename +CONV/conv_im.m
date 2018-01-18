function out = conv_im(traj, F)
for i = 1:size(F,3)
	out(:,:,i) = conv2(traj, F(:,:,i), 'same');
end
out = out/sum(traj(:));