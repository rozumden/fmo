baselines = '/mnt/home/rozumden/projects/fast_tracking/dataset/baseline_results';
bs = dir(baselines);
bs = bs(3:7);

EVAL.init();
rc = cell(1,numel(seq));

parfor i = 1:numel(seq)
	warning('off','all')
    seq_file = seq(i).name;
    [~,seq_name,~] = fileparts(seq_file);
    video = Video(folder, seq_file);
    x = cell(1,numel(bs));
    y = cell(1,numel(bs));
    u = cell(1,numel(bs));
    v = cell(1,numel(bs));
    tp = cell(1,numel(bs));
    fp = cell(1,numel(bs));
    for k = 1:numel(bs)
    	[x{k},y{k},u{k},v{k}] = textread(fullfile(baselines,bs(k).name,[seq_name '.txt']),'%f,%f,%f,%f');
    end
    img = video.get_frame(1);
    sz = [size(img,1) size(img,2)];
    first = [];
    for j = 1:video.size()
    	frm = video.gt.get_frame(j,sz);
    	if frm.empty
    		continue;
    	end
    	if isempty(first)
    		first = j-1;
    		continue;
    	end
    	bbx = frm.BoundingBox;
    	BW_gt = logical(zeros(sz));
    	BW_gt(bbx(2):(bbx(2)+bbx(4)),bbx(1):(bbx(1)+bbx(3))) = 1;
    	BW_gt = BW_gt(1:sz(1),1:sz(2));
    	for k = 1:numel(bs)
    		BW = logical(zeros(sz));
    		ind = j - first;
    		xlims = y{k}(ind):(y{k}(ind)+v{k}(ind));
    		ylims = x{k}(ind):(x{k}(ind)+u{k}(ind));
    		xlims = xlims(xlims > 0 & xlims <= sz(1));
    		ylims = ylims(ylims > 0 & ylims <= sz(2));
    		xlims = int32(xlims); ylims = int32(ylims);
    		BW(xlims,ylims) = 1;
    		iou = sum(sum(BW & BW_gt))/sum(sum(BW | BW_gt));
    		if iou > 0.5
    			tp{k} = [tp{k} 1];
    		else
    			fp{k} = [fp{k} 1];
    		end
    	end
    end
    for k = 1:numel(bs)
    	rc{i} = [rc{i} sum(tp{k})/(sum(tp{k}) + sum(fp{k}))];
    end
    disp(seq_name);
end

mean(reshape([rc{:}],5,[])')