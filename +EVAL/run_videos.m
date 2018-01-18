EVAL.init();

for i = 1:numel(seq)
	file = fullfile(folder,seq{i});
	if exist(file) == 7 || exist(file) == 0
		disp(file)
		continue
	end
	gt = GroundTruth(file,0);
	video = Video(file);

	img = video.get_frame(round(video.size()/2));
			
	imwrite(img,['imgs/seq' sprintf('%02d',i) '.png']);
end

