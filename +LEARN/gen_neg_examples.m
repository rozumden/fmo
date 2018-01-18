function hogm = gen_neg_examples()
folder = '/mnt/home/rozumden/projects/fast_tracking/dataset/vot';
files = dir(folder);
files = files(3:end);
inl = find(arrayfun(@(x) strcmp(x.name,'ball1') || ...
						 strcmp(x.name,'hand') || ...
						 strcmp(x.name,'soldier') || ...
						 strcmp(x.name,'tiger') , files));
hogm = [];
for k = inl'
	imgs = dir(fullfile(folder,files(k).name));
	im = im2double(imread(fullfile(folder,files(k).name,imgs(3).name)));
	detec = DET.OneFrameDetector([size(im,1) size(im,2)]);
	frame = [];
	for kk = 3:numel(imgs)
		name = fullfile(folder,files(k).name,imgs(kk).name);
		if ~strcmp(name((end-2):end),'jpg'), continue; end
		im = im2double(imread(name));
		frame{kk} = detec.detect(im);

		for kkk = 1:numel(frame{kk})
			frame{kk}(kkk).add_dist(detec.Size);
			frame{kk}(kkk).add_colors(detec.IM00,im);
			hog = bbs_patch(im,frame{kk}(kkk).BoundingBox,frame{kk}(kkk).LinearCoeff,frame{kk}(kkk).Radius);
			hogm{end+1} = hog;
		end
		show_main(im,frame,kk);
	end
	disp(files(k).name);
end

function [] = show_main(im0,frame,n)
clf;
image(im0);
hold on;
for kk = 0:min(0,n-1)
	colors = {'b','r','g','m'};
	for kkk = 1:numel(frame{n-kk})
		frame{n-kk}(kkk).show(1/((kk+1)^2),0, colors{1});
		colors = circshift(colors,1);
	end
end
drawnow;