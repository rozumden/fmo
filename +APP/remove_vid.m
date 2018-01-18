function out = remove_vid(vid, fmos)
out = [];
for i = 1:2
	if ~isempty(fmos{i})
		imgd = APP.remove(vid(:,:,:,i+2), vid(:,:,:,i), fmos{i}.PixelIdxList);
	else
		imgd = vid(:,:,:,i);
	end
	out = cat(4, out, imgd);
end

for i = 3:size(vid,4)
	if ~isempty(fmos{i})
		imgd = APP.remove(vid(:,:,:,i-2), vid(:,:,:,i), fmos{i}.PixelIdxList);
	else
		imgd = vid(:,:,:,i);
	end
	out = cat(4, out, imgd);
end
