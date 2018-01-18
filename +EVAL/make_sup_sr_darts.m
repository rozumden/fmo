EVAL.init();
load('dataset_eval.mat');

seq(3).name = 'darts1.mp4';
seq(3).decon = 'darts_decon3.mat';
seq(3).output = 'darts_sr';
seq(3).frame = frame{3};
seq(3).inter = [45 56];
for i = [51:56]
    seq(3).frame{i} = [];
end
m = 1080; n = 1920;
seq(3).frame{50}.Last = [233.5; 503.5];

pxls = bwline2(seq(3).frame{46}.First+[20; 0], seq(3).frame{47}.First, seq(3).frame{47}.Radius+5);
seq(3).frame{46}.PixelIdxList = find(poly2mask(pxls.extended(:,1), pxls.extended(:,2), m, n));

pxls = bwline2(seq(3).frame{47}.First, seq(3).frame{48}.First, seq(3).frame{48}.Radius+5);
seq(3).frame{47}.PixelIdxList = find(poly2mask(pxls.extended(:,1), pxls.extended(:,2), m, n));

pxls = bwline2(seq(3).frame{48}.First, seq(3).frame{49}.First, seq(3).frame{49}.Radius+5);
seq(3).frame{48}.PixelIdxList = find(poly2mask(pxls.extended(:,1), pxls.extended(:,2), m, n));

pxls = bwline2(seq(3).frame{49}.First, seq(3).frame{50}.First, seq(3).frame{50}.Radius+5);
seq(3).frame{49}.PixelIdxList = find(poly2mask(pxls.extended(:,1), pxls.extended(:,2), m, n));

pxls = bwline2(seq(3).frame{50}.First, [233.5; 503.5], seq(3).frame{50}.Radius+5);
seq(3).frame{50}.PixelIdxList = find(poly2mask(pxls.extended(:,1), pxls.extended(:,2), m, n));

n = 10;
for i = 3
	d = load(fullfile(folder,'deconv',seq(i).decon));

 	video = vision.VideoFileReader(fullfile(folder,'seq',seq(i).name));
	vidWriter = VideoWriter(seq(i).output); 
	vidWriter.FrameRate = 10;
	vidWriter.open;

    k = 1;
    imgs = [];
    indx = [];
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
        indx = [indx k];
		k = k + 1;
    end

    for k = 1:numel(d.dart_img)
    	if d.frame_idx(k) <= numel(seq(i).frame) && ~isempty(seq(i).frame{d.frame_idx(k)})
    		seq(i).frame{d.frame_idx(k)}.res.fg = d.dart_img{k};
            seq(i).frame{d.frame_idx(k)}.res.f = [];
            seq(i).frame{d.frame_idx(k)}.res.m = d.dart_mask{k};
    	end
    end
    seq(i).frame{50}.res = seq(i).frame{49}.res;
    % seq(i).frame{47}.res = seq(i).frame{48}.res;
    seq(i).frame{46}.res = seq(i).frame{47}.res;

    for k = 1:size(imgs,4)
		writeVideo(vidWriter,imgs(:,:,:,k));
	end

	sr = APP.average_vid(imgs,n);
	fmos = seq(i).frame(seq(i).inter(1):seq(i).inter(2));
	sr_fmo = APP.average_fmo_vid_gen(imgs, fmos, n);

	for k = 1:size(sr,4)
		writeVideo(vidWriter,sr(:,:,:,k));
	end
	for k = 1:size(sr_fmo,4)
		writeVideo(vidWriter,sr_fmo(:,:,:,k));
	end

	close(vidWriter);
    release(video);
end
