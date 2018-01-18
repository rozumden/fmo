function out = average_vid(vid, n)
out = [];
for i = 2:size(vid,4)
	out = cat(4,out,APP.average(vid(:,:,:,i-1),vid(:,:,:,i),n));
end
out = cat(4,out,vid(:,:,:,end));