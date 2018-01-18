EVAL.init();
for i = 1:numel(seq)
	video = Video(folder, seq(i).name);

	if isempty(video.gt.frame)
		video.gt.frame = cell(1,video.size());
	end
	n = cellfun(@(x) isempty(x), video.gt.frame);
	for j = find(n)
		fprintf('Frame %d/%d\n', j, numel(n));
		img = video.get_frame(j);
		image(img);
		keyboard_pressed = waitforbuttonpress;
		if keyboard_pressed
			video.gt.frame{j} = logical(zeros(size(img,1),size(img,2)));
		else
			video.gt.frame{j} = roipoly;
		end
	end
	if sum(n) > 0
		gt = video.gt.frame;
		save(video.gt.truth,'gt');
	end
end

