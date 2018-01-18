function traj = bwline2(first,last,radius)
dif = first - last;
if dif(1) ~= 0
	m = dif(2)/dif(1); 
	x = first(1):last(1);
	if isempty(x)
		x = first(1):-1:last(1);
	end
	pixels = [x; m*(x-first(1))+first(2)]';
elseif dif(2) ~= 0
	m = dif(1)/dif(2); 
	y = first(2):last(2);
	if isempty(y)
		y = first(2):-1:last(2);
	end
	pixels = [m*(y-first(2))+first(1); y]';
else
	traj.pixels = [];
	traj.extended = [];
	return;
end

pixels = [floor(pixels); ceil(pixels)];
pixels = unique(pixels,'rows');

mask = logical(zeros(max(pixels(:,1))+100,max(pixels(:,2))+100));
mask(sub2ind(size(mask),pixels(:,1),pixels(:,2))) = 1;
mask_thin = bwmorph(mask,'thin',Inf);
[x,y] = find(mask_thin);
traj.pixels = [x y];

se = strel('square',10);
mask_ext = imdilate(mask,se);
[x,y] = find(mask_ext);
traj.extended = [x y];

if nargin == 3
	[x y] = meshgrid((min(x)-radius):(max(x)+radius),(min(y)-radius):(max(y)+radius));
	neighbours = [x(:) y(:)];
	d = pdist2(traj.pixels,neighbours,'euclidean','Smallest',1);
	inl = round(neighbours(d < radius,:));
	traj.PixelList = neighbours(inl,:);
end