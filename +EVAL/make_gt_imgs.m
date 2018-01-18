EVAL.init();
write_to = false;
dilate_to = true;
if write_to
	file1 = fopen('imgs/gt/dataset_defs.tex','w');
	file2 = fopen('imgs/gt/dataset_names.tex','w');
end
parfor i = 1:numel(seq)
	video = Video(folder, seq(i).name);
	addpath(genpath('.'))	
	% if isempty(video.gt.frame)
	% 	error('No GT');
	% end

	if ~isempty(seq(i).show)
		n = seq(i).show;
	else
		n = find(~cellfun(@(x) isempty(x) | sum(sum(x)) == 0, video.gt.frame));
	end
	for j = n
		[~,name,~] = fileparts(seq(i).name);
		img = video.get_frame(j);
		sz = [size(img,1) size(img,2)];
		offset = sz(1) * sz(2);
		if ~isempty(video.gt.frame)
			t = video.gt.get_frame(j,sz);
			if dilate_to
				se = strel('square',2);
				BW = logical(zeros(sz));
				BW(t.Boundary) = 1;
				BW2 = imdilate(BW,se);
				t.Boundary = find(BW2);
			end
			img(t.Boundary) = 255;
			img(t.Boundary+offset) = 0;
			img(t.Boundary+2*offset) = 0;
		end
		if numel(n) > 1
			image(img);
			keyboard_pressed = waitforbuttonpress;
			if ~keyboard_pressed
				imwrite(img,['imgs/gt/seq' sprintf('%02d',i) '_gt.jpg']);
				fprintf('%s - frame%d\n',seq(i).name, j);
				break;
			end
		else
			imwrite(img,['imgs/gt/' sprintf('%s',name) '_gt.jpg']);
		end
	end
	if write_to
		[x y] = ind2sub(sz,t.PixelIdxList);
		xy = [mean(x) mean(y)];
		XY = img2latex(xy,sz);
		filename = ['gt/' sprintf('%s',name) '_gt.png'];
		fprintf(file1,'\\newcommand{\\%sCoor}{(%.4f, %.4f)}\n',name(isletter(name)),XY(2),XY(1));
		if mod(i,5) == 0
			fprintf(file2,'\\imgZoom{%s}{\\%sCoor} \\\\\n\n',filename,name(isletter(name)));
		else
			fprintf(file2,'\\imgZoom{%s}{\\%sCoor} &\n',filename,name(isletter(name)));
		end
	end
	fprintf('%s - %d frames\n',name,video.size());
end

if write_to
	fclose(file1);
	fclose(file2);
end