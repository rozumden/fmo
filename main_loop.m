function [frame,result] = main_loop(video, cfg)
im = video.get_frame(1);
im1 = video.get_frame(2);
sz = [size(im,1) size(im,2)];

time = [];
detec = DET.OneFrameDetector(sz);
% detec = DET.BackForwardDetector(sz);
% detec = DET.Detector(sz);
for k = 1:video.size()
	im = video.get_frame(k); % next step 
	tic; 
	frame{k} = fmo2(im,detec);
	time(k) = toc;
	if cfg.show, show_main(im,frame,k); end
	
	if numel(frame{k}) == 0, continue; end
	im_g = rgb2gray(im);
	im0_g = rgb2gray(detec.IM00);
	pxls0 = [];
	err = [];
	for kkk = 1:numel(frame{k})
		if frame{k}(kkk).empty, continue; end
		[pxls0,err(kkk)] = klt_region(frame{k}(kkk),im_g,im0_g);
		plot(pxls0(1,:),pxls0(2,:),'.g');
		errs = num2str(round(100*err(kkk))/100);
		text(frame{k}(kkk).Centroid(1),frame{k}(kkk).Centroid(2),errs,'Color','r');
	end
	frame{k} = frame{k}(err >= 0.5);

	[frame{k}, str] = video.gt.control_all(k,frame{k});
	if cfg.verbose
		fprintf('Frame %d/%d, %.3f sec, status %s.\n',k,video.size(),time(k),str);
	end
end

if cfg.write
	F = getframe(gcf);
	[imgs,~] = frame2im(F);
	for kk = 1:30
		writeVideo(video.gt.video,uint8(imgs));
	end
	video.gt.close();
	for i = 1:numel(frame)
		if ~isempty(frame{i})
			[~,b] = unique( reshape([frame{i}.Centroid],2,[])','rows');
			frames(i) = struct(frame{i}(b));
		end
	end
	save(video.gt.result, 'frames');
end

result = video.gt.calc_stats(frame);

function [] = show_main(im0,frame,n)
clf;
image(im0);
hold on;
for kk = 0:min(0,n-1)
	% colors = {'b','r','g','m'};
	colors = {'b'};
	for kkk = 1:numel(frame{n-kk})
		frame{n-kk}(kkk).show(1/((kk+1)^2),0, colors{1});
		colors = circshift(colors,1);
	end
end
drawnow;
% if cfg.write
% 	F = getframe(gcf);
% 	[imgs,~] = frame2im(F);
% 	writeVideo(video.gt.video,uint8(imgs));
% end