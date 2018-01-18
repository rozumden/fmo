t = load('dataset/deconv/volleyball_sr_decon.mat');

vidWriter = VideoWriter('volleyball_sr'); 
vidWriter.FrameRate = 2;
vidWriter.open;

for i = 1:3
	temp = t.img_full;
	temp(:,end-300:end,:) = double(t.frames_ours(:,end-300:end,:,1))/255;
	writeVideo(vidWriter,temp);
end

for i = 1:size(t.frames_ours, 4)
	temp = t.frames_ours(:,:,:,i);
	temp(end-700:end,:,:) = t.img_full(end-700:end,:,:)*255;
	writeVideo(vidWriter,temp);
end

close(vidWriter);