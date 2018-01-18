EVAL.init();
load('dataset_eval.mat');
seq = [];

temp = load('69_60_bird_frames.mat');
seq(1).name = '69_60_bird.mp4';
seq(1).decon = '69_60_bird_decon.mat';
seq(1).output = 'pingpong_sr';
seq(1).frame = temp.frame;
seq(1).inter = [16 29];

seq(2).name = 'frisbee.mp4';
seq(2).decon = 'frisbee_decon.mat';
seq(2).output = 'frisbee_sr';
seq(2).frame = frame{end-4};
seq(2).inter = [19 27];

seq(3).name = 'darts1.mp4';
seq(3).decon = 'darts_decon.mat';
seq(3).output = 'darts_sr';
seq(3).frame = frame{3};
seq(3).inter = [1 50];

n = 10;
for i = 3
	d = load(fullfile(folder,'deconv',seq(i).decon));
 	video = vision.VideoFileReader(fullfile(folder,'seq',seq(i).name));
	vidWriter = VideoWriter(seq(i).output); 
	vidWriter.FrameRate = 25;
	vidWriter.open;

    k = 1;
    imgs = [];
    while ~isDone(video)
        videoFrame = step(video);
        if k < seq(i).inter(1)
			k = k + 1;
        	continue
        end
        if k > seq(i).inter(2)
        	break
        end
        imgs = cat(4,imgs,videoFrame);
		k = k + 1;
    end
    for k = 1:numel(d.res)
    	if d.res(k).ind > numel(seq(i).frame), break; end
    	if ~isempty(seq(i).frame{d.res(k).ind})
    		seq(i).frame{d.res(k).ind}.res = d.res(k);
    	end
    end
    for k = 1:size(imgs,4)
		writeVideo(vidWriter,imgs(:,:,:,k));
	end

	sr = APP.average_vid(imgs,n);
	fmos = seq(i).frame(seq(i).inter(1):seq(i).inter(2));
	sr_fmo = APP.average_fmo_vid(imgs, fmos, n);

	for k = 1:size(sr,4)
		writeVideo(vidWriter,sr(:,:,:,k));
	end
	for k = 1:size(sr_fmo,4)
		writeVideo(vidWriter,sr_fmo(:,:,:,k));
	end

	close(vidWriter);
    release(video);
end
