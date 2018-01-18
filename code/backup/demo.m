function [frame,result] = demo(file, cfg)
model = Model();
model.reset();
gt = GroundTruth(file,cfg.write);

if exist(file,'file') == 2
	global check_file;
	if check_file.isKey(file)
		v = check_file(file);
		if ~isvalid(v)
			v = VideoReader(file);
			check_file(file) = v;
		end
	else
		v = VideoReader(file);
		check_file = [check_file; containers.Map(file, v)];
	end
	im1 =  im2double(v.read(1));
	im2 =  im2double(v.read(2));
	model.dif = Differential(im1,im1);
	model.next_iter(im1,im2);
	available = model.next_bin();
	frame(v.NumberOfFrames) = Frame();
	for i = 3:(v.NumberOfFrames)
		im3 = im2double(v.read(i));
		tic;
		bsd(im2,im3,model);
		frame(i).time = toc;
		n = i-1;	
		if ~model.frame0.empty
			frame(n).add(model.frame0);
			frame(n) = gt.control_iter(n, frame(n));
			if cfg.save_frames 
				frame(n).add_crop(im1,im2);
			end
		end
		[frame(n),str] = gt.control_iter(n, frame(n));
		if cfg.show
			hold on;
			clf;
			imshow(im2);
			hold on;
			for kk = 0:min(6,n-1)
				frame(n-kk).show(1/((kk+1)^2),kk == 0);
			end
			drawnow;
			if cfg.write
				F = getframe(gcf);
				[imgs,~] = frame2im(F);
				writeVideo(vres,uint8(imgs));
			end
		end
		
		fprintf('Took %.3f seconds with status %d. %s\n',frame(n).time,model.status,str);
		% if strcmp(str,'- fp'), keyboard; end
		% if strcmp(str,'- fn'), keyboard; end
		im1 = im2;	
		im2 = im3;
		n
	end
else
	frame = [];
end

color = [];
color(1,1,1:3) = model.Color;
imshow(repmat(color,[size(im1,1) size(im1,2) 1]));

if cfg.write
	F = getframe(gcf);
	[imgs,~] = frame2im(F);
	for kk = 1:30
		writeVideo(vres,uint8(imgs));
	end
	close(vres);
end

if ~isempty(gt)
	tp = sum([frame.tp]);
	fp = sum([frame.fp]);
	fn = sum([frame.fn]);
	tn = sum([frame.tn]);
	precision = tp/(tp + fp);
	recall = tp/(tp+fn);
	fscore = 2/(1/precision + 1/recall);
	mean_ol = mean([frame.overlap]);
	fprintf('Precision %.2f, recall %.2f, F-score %.2f, mean overlap %.2f\n', ...
		100*precision,100*recall,100*fscore,100*mean_ol);
	result.precision = precision;
	result.recall = recall;
	result.fscore = fscore;
	result.mean_ol = mean_ol;
end



