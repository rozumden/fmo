function proposed = prediction(model,im)
repeat = 0;
frame0 = model.frame0;
while true
	if repeat, model.Ratio = []; end

	if isempty(model.regions_near)
		[model.frame0.pred_bbs, bin_near, bin_near_full] = init_prediction(frame0,model);
		model.regions_near = getRegions(bin_near_full,model.dif);
	else
		model.frame0.pred_bbs = init_prediction(frame0,model);
	end

	if ~isempty(model.regions_near)
		model.in_pred = get_regions_in_bbs(model.regions_near,model.frame0.pred_bbs,frame0.Direction);
		proposed = model.regions_near(model.in_pred > 0);
	else
		proposed = [];
		model.in_pred = [];
	end

	if ~isempty(model.Ratio) || ~isempty(proposed)
		break;
	end
	repeat = repeat + 1;
	if repeat == 1
		model.Ratio = 2/3;
	elseif repeat == 2
		model.Ratio = 1/2;
	else
		break;
	end
end

function [pred_bbs,bin_near,bin_near_full] = init_prediction(frame0,model)
[pred_bbs, move] = predictMovement(frame0, model);
if nargout == 1
	return;
end
len = 30*model.Radius;
sq = [max(1,(frame0.Centroid(1)-len)); 
      min(size(model.dif.bin,2),(frame0.Centroid(1)+len));
      max(1,(frame0.Centroid(2)-len)); 
      min(size(model.dif.bin,1),(frame0.Centroid(2)+len))];
sq = uint32(sq);
obj = frame0.BoundingBox;
obj = obj - [2 2 -4 -4];
obj(1) = max(obj(1),1); 
obj(2) = max(obj(2),1); 
obj(3) = min(obj(1)+obj(3),size(model.dif.bin,2)) - obj(1);
obj(4) = min(obj(2)+obj(4),size(model.dif.bin,1)) - obj(2);

bin_near = logical(zeros(size(model.dif.bin)));
bin_near(sq(3):sq(4),sq(1):sq(2)) = model.dif.bin(sq(3):sq(4),sq(1):sq(2));
bin_near(obj(2):(obj(2)+obj(4)),obj(1):(obj(1)+obj(3))) = 0;

if nargout == 3
	bin_near_full = logical(zeros(size(model.dif.bin_full)));
	bin_near_full(sq(3):sq(4),sq(1):sq(2)) = model.dif.bin_full(sq(3):sq(4),sq(1):sq(2));
	bin_near_full(obj(2):(obj(2)+obj(4)),obj(1):(obj(1)+obj(3))) = 0;
end


function [bbs, move] = predictMovement(object, model)
% len = object.MajorAxisLength;
len = sqrt(object.BoundingBox(3)^2 + object.BoundingBox(4)^2);
if isempty(model.Ratio)
	dist = 0;
else
	dist = len./model.Ratio;
end

move =  (len + dist);

rad = (pi/180).*(-object.Orientation);
vec = rotationMatrix(rad) * [1; 0] * move;
vec = [vec' 0 0];

inc = 3;
object.BoundingBox(1:2) = object.BoundingBox(1:2) - inc;
object.BoundingBox(3:4) = object.BoundingBox(3:4) + 2*inc;

bb1 = object.BoundingBox + vec;
bb2 = object.BoundingBox - vec;

bbs = [bb1; bb2];
bbs = bbs(object.Direction,:);

function m = rotationMatrix(rad)
m = [cos(rad) -sin(rad); sin(rad) cos(rad)]; 


function in = get_regions_in_bbs(regions,bbs,dirs)
if nargin < 3
	dirs = [];
end
in = zeros(size(regions));
for i = 1:numel(in)
	c = regions(i).PixelList;
	a = zeros(size(c'));
	for j = 1:size(bbs,1)
		a(j,:) = c(:,1) > bbs(j,1)  & c(:,2) > bbs(j,2) & ...
			     c(:,1) < (bbs(j,1)+bbs(1,3)) & c(:,2) < (bbs(j,2)+bbs(1,4));
		if ~isempty(dirs)
			a(j,:) = dirs(j)*a(j,:);
		end
	end
	lbl = setdiff(sum(a),0);
	if numel(lbl) == 1
		in(i) = lbl;
	end
end