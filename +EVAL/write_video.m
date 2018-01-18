function [] = write_video(video,file)
v = VideoWriter(file,'Motion JPEG AVI');
open(v);
for i = 1:size(video,4)
	writeVideo(v,video(:,:,:,i));
end
close(v);
