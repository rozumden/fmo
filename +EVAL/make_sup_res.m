EVAL.init();
load('dataset_eval.mat');
seq0 = seq;
seq = [];

seq(1).name = seq0(7).name;
seq(1).frame = frame{7};
seq(1).inter = [1 50];

seq(2).name = seq0(end-2).name;
seq(2).frame = frame{end-2};
seq(2).inter = [28 47];

seq(3).name = seq0(3).name;
seq(3).frame = frame{3};
for i = [51:56]
	seq(3).frame{i} = [];
end
seq(3).inter = [1 56];

seq(4).name = seq0(10).name;
seq(4).frame = frame{10};
seq(4).inter = [0 100];

seq(5).name = seq0(5).name;
seq(5).frame = frame{5};
seq(5).inter = [55 95];

seq(6).name = seq0(end-1).name;
seq(6).frame = frame{end-1};
seq(6).inter = [81 127];
for i = 1:numel(seq(6).frame)
	for j = 1:numel(seq(6).frame{i})
		seq(6).frame{i}(j).model = 1;
	end
end
seq(6).frame{87}.model = 2;
seq(6).frame{88}.model = 2;
seq(6).frame{89}.model = 3;
seq(6).frame{90}.model = 3;

seq(6).frame{94}.model = 3;
seq(6).frame{95}(1).model = 3;
seq(6).frame{96}(1).model = 3;

seq(6).frame{120}(1).model = 2;
seq(6).frame{121}(1).model = 2;
seq(6).frame{122}(1).model = 2;
seq(6).frame{123}(1).model = 2;
seq(6).frame{124}(1).model = 2;

seq(6).frame{125}(1).model = 3;

seq(7).name = seq0(1).name;
seq(7).frame = frame{1};
seq(7).inter = [1 30];

colors{1} = [0 0 1];
colors{2} = [1 0 0];
colors{3} = [0 1 0];
for i = 7:numel(seq)
	[~,name,~] = fileparts(seq(i).name);
 	video = vision.VideoFileReader(fullfile(folder,'seq',seq(i).name));
	vidWriter = VideoWriter([name '_res']); 
	vidWriter.FrameRate = 10;
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
        img = videoFrame;
        if k <= numel(seq(i).frame) && ~isempty(seq(i).frame{k})
			for kk = 1:numel(seq(i).frame{k})
				if seq(i).frame{k}(kk).model < 3 
					img = seq(i).frame{k}(kk).apply(img, colors{seq(i).frame{k}(kk).model});
				end
			end
		end
		imgs = cat(4,imgs,img);
		writeVideo(vidWriter,videoFrame);
		k = k + 1;
    end

    for k = 1:size(imgs,4)
    	writeVideo(vidWriter,imgs(:,:,:,k));
    end

	vidWriter.close;
end

