function [idx d] = knnMatch(regions0,regions,method)
if nargin < 3, method = 'center';  end;
if numel(regions0) == 1
	idx = ones(1,numel(regions));
	d = feval(str2func(method), regions0, regions);
else
	[idx d] = knnsearch(regions0,regions,'Distance',str2func(method));
end

function dist = center_area(ai,b)
dist = center(ai,b) + 0.3*area(ai,b);

function dist = color_area(ai,b)
dist = color(ai,b) + area(ai,b);

function dist = color_area_minorlen(ai,b)
dist = color_area(ai,b) + minorlen(ai,b);

function dist = color_area_center(ai,b)
dist = color_area(ai,b) + center(ai,b);

function dist = color_ori(ai,b)
dist = color(ai,b) + 40*ori(ai,b);

function dist = mixcolor_ori(ai,b)
dist = mixcolor(ai,b) + 40*ori(ai,b);

function dist = color_area_minorlen_center(ai,b)
dist = color_area_minorlen(ai,b) + center(ai,b);

function dist = color_len(ai,b)
dist = color(ai,b) + minorlen(ai,b) + majorlen(ai,b);

function dist = color_minorlen(ai,b)
dist = color(ai,b) + minorlen(ai,b);

function dist = color_minorlen_modcenter(model,b)
dist = color_minorlen(model,b) + modcenter(model,b);

function dist = color_modcenter(model,b)
dist = color(model,b) + modcenter(model,b);

function dist = center_area_minorlen(ai,b)
dist = center_area(ai,b) + 0.3*minorlen(ai,b);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function color_dist = color(ai,b)
c2 = reshape([b(:).Color],3,[]);
color_dist = sqrt((c2(1,:) - ai.Color(1)).^2 + ...
	              (c2(2,:) - ai.Color(2)).^2 + ...
	              (c2(3,:) - ai.Color(3)).^2)';

function color_dist = mixcolor(ai,b)
c2 = reshape([b(:).MixedColor],3,[]);
color_dist = sqrt((c2(1,:) - ai.MixedColor(1)).^2 + ...
	              (c2(2,:) - ai.MixedColor(2)).^2 + ...
	              (c2(3,:) - ai.MixedColor(3)).^2)';

function ori_dist = ori(ai,b)
ori_dist = (sin((pi/180).*([b.Orientation] - ai.Orientation)).^2)';

function center_dist = center(ai,b)
c2 = reshape([b(:).Centroid],2,[]);
center_dist = sqrt((c2(1,:) - ai.Centroid(1)).^2 + (c2(2,:) - ai.Centroid(2)).^2)';

function area_dist = area(ai,b)
area_dist = abs([b.Area] - ai.Area)';

function minorlen_dist = minorlen(ai,b)
minorlen_dist = abs([b.MinorAxisLength] - ai.MinorAxisLength)';

function majorlen_dist = majorlen(ai,b)
majorlen_dist = abs([b.MajorAxisLength] - ai.MajorAxisLength)';

function dist = modcenter(model,b)
given = arrayfun(@(x) rect_distance(model.BoundingBox,x.BoundingBox), b);
bbs = reshape([b(:).BoundingBox],4,[]);
len = sqrt(bbs(3,:).^2 + bbs(4,:).^2)';
expected = len./model.Ratio;
dist = abs(given - expected);
