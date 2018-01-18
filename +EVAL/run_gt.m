EVAL.init();
fid = fopen(fullfile(folder,'seq/first_bbx.txt'),'w');
for i = 1:numel(seq)
	video = Video(folder, seq(i).name);
	img = video.get_frame(1);
	sz = [size(img,1) size(img,2)];
	offset = sz(1) * sz(2);
	[~,name,ext] = fileparts(seq(i).name);
	for j = 1:video.size()
		t = video.gt.get_frame(j,sz);
		if ~t.empty
			fprintf(fid,'%s %d %.1f %.1f %.1f %.1f\n',[name ext],j,t.BoundingBox);
			break;
		end
	end
	disp(seq(i).name);
end

fclose(fid);