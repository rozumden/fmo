function frame = best_predictions(proposed,model,check)
if nargin < 3
	check = true;
end
if isempty(proposed)
	frame = Frame();
	return;
end

model.status = 2;
dirs = model.in_pred(model.in_pred > 0);
for i = 1:numel(proposed)
	proposed(i) = model.add_info(proposed(i),model.dif);
end
[~,d] = knnMatch(model.frame0,proposed,'color');
d = d';
[~,m] = min(d);
best_dir = dirs(m);
same_dir = dirs == best_dir;
frame1 = proposed(d < 0.3 & same_dir);
frame2 = proposed(d < 0.3 & ~same_dir);
frame = find_best_frame(frame1,frame2,model.frame0);
loss = [];
if isempty(frame)
	frame = Frame();
end
if ~frame.empty
	if frame.best
		frame.Direction = best_dir;
	else
		frame.Direction = setdiff([1 2],best_dir);
	end
	frame = model.add_info(frame,model.dif);

	if model.Rate > 3 && ~model.check_consistency(frame, model.dif)
		frame = Frame();
	end
end

% model checking
if check && ~model.init && frame.empty
	frame = Frame(combine_regions(proposed));
	regions_backup = model.regions_near;
	in_pred_backup = model.in_pred;
	frame = model.add_info(frame,model.dif);
	[expected, front, ind] = model.calc_fmo(frame, model.dif);
	loss = sqrt(sum((expected' - front').^2))';
	in = frame.PixelIdxList(loss < 0.2 & frame.Distances < model.Radius);
	bin = logical(zeros(size(model.dif.bin)));
	bin(in) = 1;
	bin = Differential.post_process(bin);
	new = getRegions(bin,model.dif);
	model.in_pred = repmat(dirs,[numel(new) 1]);
	for i = 1:numel(new), new(i).best = true; end
	model.regions_near = new;
	new = prediction(model,model.dif.front);
	if isempty(new)
		model.regions_near = regions_backup;
		model.in_pred = in_pred_backup;
		return
	end
	frame = best_predictions(new,model,false);
	if isempty(frame)
		model.regions_near = regions_backup;
		model.in_pred = in_pred_backup;
	end
end

function frame = find_best_frame(frame1,frame2,prevDet)
frame = Frame();
len = sqrt(prevDet.BoundingBox(3)^2 + prevDet.BoundingBox(4)^2);
if numel(frame1) > 1 
	frame1 = combine_regions(frame1); 
end
if numel(frame2) > 1 
	frame2 = combine_regions(frame2); 
end
% if ~isempty(frame1)
% 	dif = len/sqrt(frame1.BoundingBox(3)^2 + frame1.BoundingBox(4)^2);
% 	if (dif < 1/3) || (dif > 3)
% 		frame1 = []; 
% 	end
% end
% if ~isempty(frame2)
% 	dif = len/sqrt(frame2.BoundingBox(3)^2 + frame2.BoundingBox(4)^2);
% 	if (dif < 1/3) || (dif > 3)
% 		frame2 = []; 
% 	end
% end
if isempty(frame1)
	frame = frame2;
	if ~isempty(frame)
		frame.best = false;
	end
elseif isempty(frame2)
	frame = frame1;
	if ~isempty(frame)
		frame.best = true;
	end
elseif isempty(frame)
	[~,d] = knnMatch(prevDet,[frame1 frame2],'ori');
	if d(1) < d(2)
		frame = frame1;
		frame.best = true;
	else
		frame = frame2;
		frame.best = false;
	end
end