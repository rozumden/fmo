EVAL.init();

thresh = 7;
updt = 1;
direc = 'imgs/results';
if updt
	if exist(direc,'dir')
		rmdir(direc,'s');
	end
	detector = fullfile(direc,'detector');
	redetector = fullfile(direc,'redetector');
	tracker = fullfile(direc,'tracker');
	mkdir(detector);
	mkdir(redetector);
	mkdir(tracker);
	mkdir(fullfile(detector,'solved'));
	mkdir(fullfile(redetector,'solved'));
	mkdir(fullfile(tracker,'solved'));
end

cfg.verbose = 1;
cfg.write = 0;
cfg.show = 0;
cfg.save_frames = 0;

det0 = [];
det1 = [];
tr = [];
for i = 1:numel(seq)
	if isempty(prob{i})
		continue
	end
	file = fullfile(folder,seq{i});
	gt = GroundTruth(file,0);
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
	video = v.read;
	for j = 1:numel(prob{i})
		model = Model();
		model.reset();
		k = prob{i}(j);
		
		im00 =  im2double(video(:,:,:,k-2));
		im0 =  im2double(video(:,:,:,k-1));
		im =  im2double(video(:,:,:,k));
		im1 =  im2double(video(:,:,:,k+1));
		sz = [size(im,1) size(im,2)];
		dif00 = Differential(im00,im0);
		model.dif0 = Differential(im0,im);
		model.dif = Differential(im,im1);
		model.next_bin;model.next_bin;
		model.offset = size(im,1)*size(im,2);
		% frame0 = init_guess_fast(model.dif0.bin,model.dif.bin);
		[fmo,dI,dI0,bin, bin_fmo] = Detector.detect(im,im0,im1);
		frame0 = Frame();
		if ~isempty(fmo)
			frame0 = Frame(fmo);
		end
		[det0{i}(j),model.frame] = gt.control_traj(k,frame0, sz);
		frame0.BoundingBox = Frame.combine_bbs(frame0.BoundingBox,model.frame.BoundingBox - [50 50 -100 -100]);
		model.init = 0;
		model.dif = model.dif0;
		model.dif0 = dif00;
		model.next_bin;model.next_bin;
		model.frame0 = gt.get_frame(k-1,sz);
		model.frame = model.add_info(model.frame,model.dif);
		model.frame0.add_colors(dif00);
		if false
			if det0{i}(j) < thresh
				frame0.save(sprintf('%s/detector/solved/seq%.2d_frame%.2d.png',direc,i,j),im,model.frame0,dI,dI0,bin);
			else
				frame0.save(sprintf('%s/detector/seq%.2d_frame%.2d.png',direc,i,j),im,model.frame0,dI,dI0,bin);
			end
		end
		
		% Re-detection
		model.Radius = model.frame.Radius+2;
		model.Color = model.frame0.Color;
		len = model.frame0.Length;
		dist = sqrt(sum((model.frame.First - model.frame0.Last).^2));
		model.Ratio = len/dist;
		model.regions_near = [];
		frame = Redetector.redetect(model.frame0, bin_fmo, model);
		det1{i}(j) = gt.control_traj(k,frame, sz);
		bbs = frame.BoundingBox;
		frame.BoundingBox = Frame.combine_bbs(model.frame.BoundingBox,model.frame0.BoundingBox);
		frame.BoundingBox = Frame.combine_bbs(frame.BoundingBox,bbs);
		if false
			if det1{i}(j) < thresh
				frame.save(sprintf('%s/redetector/solved/seq%.2d_frame%.2d.png',direc,i,j),im,model.frame0,dI,dI0,bin);
			else
				frame.save(sprintf('%s/redetector/seq%.2d_frame%.2d.png',direc,i,j),im,model.frame0,dI,dI0,bin);
			end
		end

		% Tracking
		frame1 = Tracker.track(model.frame0, model.Ratio, model);
		tr{i}(j) = gt.control_traj(k,frame1, sz);
		bbs = frame1.BoundingBox;
		frame1.BoundingBox = Frame.combine_bbs(model.frame.BoundingBox,model.frame0.BoundingBox);
		frame1.BoundingBox = Frame.combine_bbs(frame1.BoundingBox,bbs);
		if true
			if tr{i}(j) < thresh
				frame1.save(sprintf('%s/tracker/solved/seq%.2d_frame%.2d.png',direc,i,j),im,model.frame0,dI,dI0,bin);
			else
				frame1.save(sprintf('%s/tracker/seq%.2d_frame%.2d.png',direc,i,j),im,model.frame0,dI,dI0,bin);
			end
		end
	end
end

score = sum([det0{:}] < thresh | [det1{:}] < thresh | [tr{:}] < thresh)/numel([tr{:}]);