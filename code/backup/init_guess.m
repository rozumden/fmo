function [prevDet, model] = init_guess(regions0,regions,model)
[idx d] = knnMatch(regions0,regions,'center_area_minorlen');
[v,m] = min(d);
prevDet = [];
if v < 5
	prevDet = regions0(idx(m));
	[model,prevDet] = init_model(model,prevDet);
end
if ~isempty(prevDet) && ~isfield(prevDet,'Direction'), prevDet.Direction = [1 2]; end; 