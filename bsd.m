% Blurred Stroke Detector
function [] = bsd(im1,im2,model)
if model.stabilize
	im1 = stabilize(im2,im1); 
end

model.next_iter(im1,im2);
available = model.next_bin();
% init
if model.frame0.empty && available == 1
	if model.thresh_n == 1
		frame0 = init_guess_fast(model.dif0.bin,model.dif.bin);
	else
		frame0 = init_guess_fast(model.dif0.bin_full,model.dif.bin_full);
	end
 	model.frame0 = model.new_detection(frame0);
end

if model.frame0.empty
	model.status = 1; 
	% no fast moving objects found
	return;
end

if ~isempty(model.Ratio) && ~isempty(model.frame0) && ~isempty(model.frame0.Last)
	model.frame = prediction_minenergy_part(model);
	% if model.frame.empty
	% 	keyboard
	% end
end

% predict movement
if model.frame.empty 
	model.regions_near = [];
	proposed = prediction(model,im2);
	model.frame = best_predictions(proposed,model);
end

if ~model.frame.empty
	model.update(model.frame,model.frame0);
end

% find object in neighbouring regions
if ~isempty(model.regions_near) && model.frame.empty && ~model.init && model.predicted > 1
	model.frame = model.find_neighbours;
end

% if ~isempty(model.frame) && rectint(frame0.BoundingBox,model.frame.BoundingBox) > 0
% 	model.frame = [];
% end

if model.frame.empty && ~model.init
	model.dif = model.dif0;
	detection_backup = model.frame0;
	model.frame0 = [];
	bsd(im1,im2,model);
	if isempty(model.frame)
		model.frame0 = detection_backup;
	end
end

if model.init && model.frame.empty
	model.frame0 = Frame();
end



