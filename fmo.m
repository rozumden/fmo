function [frame0, frame, models] = fmo(im,im0,im1,frame0,models,gmodel)
[fmo, regions_fmo] = Detector.detect(im,im0,im1);

frame = Frame.empty;
for i = 1:numel(fmo)
	frame(i) = Frame(fmo(i));
	frame(i).Status = 0;
	frame(i).add_dist(gmodel.Size);
	frame(i).add_colors(im0,im);
	for j = 1:numel(frame0)
		loss = Frame.consist_color(frame(i), frame0(j)) + ...
		       Frame.consist_radius(frame(i), frame0(j));
		if loss < Model.consistency_threshold
			frame(i).add_edges(frame0(j));
		    if gmodel.consist(frame(i), frame0(j));
		    	frame(i).remove_edges();
				continue
			end
			if isempty(frame0(j).model)
				models(numel(models)+1) = Model(frame0(j),frame(i));
				frame(i).model = numel(models);
				frame0(j).model = numel(models);
				gmodel.update(frame0(j), frame(i));
			else
				frame(i).model = frame0(j).model;
				models(frame0(j).model).update(frame(i));
				gmodel.update(frame0(j), frame(i));
			end
			break;
		end
	end		
	if isempty(frame(i).model) && ~isempty(models)
		loss = Frame.consist_color(frame(i), models) + ...
		 	   Frame.consist_radius(frame(i), models);
		[v,ind] = min(loss);
		if v < Model.consistency_threshold && all(frame(i).model ~= [frame(1:(i-1)).model])
			frame(i).model = ind;
			models(ind).update(frame(i));
		end
	end
end

tracked = logical(zeros(1,numel(frame0)));
for i = 1:numel(frame0)
	if ~isempty(frame0(i).model) && any(frame0(i).model == [frame.model])
		tracked(i) = 1;
		continue; 
	end 
	t = Redetector.redetect(frame0(i), regions_fmo, im0, im);
	if isempty(t) && ~isempty(frame0(i).model) && ~isempty(gmodel.Ratio) && gmodel.Ratio > 0.5
		mdl = models(frame0(i).model);
		t = Tracker.track(frame0(i), gmodel.Ratio, im0, im, mdl);
		if t.empty
			t = [];
		end
	end
	if isempty(t)
		continue
	end
	tracked(i) = 1;

	frame(numel(frame)+1) = t;
	frame(end).add_dist(gmodel.Size);
	frame(end).add_colors(im0,im);
	frame(end).add_edges(frame0(i));
	if isempty(frame0(i).model)
		models(numel(models)+1) = Model(frame0(i),frame(end));
		frame0(i).model = numel(models);
	else
		models(frame0(i).model).update(frame(end));
		gmodel.update(frame0(i), frame(end));
	end
	frame(end).model = frame0(i).model;
end

empty_model = arrayfun(@(x) isempty(x.model), frame0);
frame0 = frame0(~empty_model);

if ~isempty(frame)
	[~,b] = unique( reshape([frame.Centroid],2,[])','rows');
	frame = frame(b);
end
