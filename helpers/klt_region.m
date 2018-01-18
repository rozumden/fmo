function [pxls0, err] = klt_region(region,im_g,im0_g)
ori = 1/region.LinearCoeff(1);
ang = atan(ori);
nrm = [cos(ang); -sin(ang)];
pxls_ind = region.PixelIdxList;
pxls = region.PixelList;
T = im_g(pxls_ind);
G = abs(T - im0_g(pxls_ind));
r = ceil(3*region.Radius);
dists = [(-r):1:r];
[y x] = meshgrid(dists,dists);
h = NaN*zeros(1,numel(x));
sz = size(im_g);
for k = 1:numel(h)
	pxls0 = round(bsxfun(@plus,pxls,[x(k); y(k)]));
	pxls0_ind = sub2ind(sz,pxls0(2,:),pxls0(1,:));
	F = im0_g(pxls0_ind);
	h(k) = median(abs(F-T)./G);
end

[err,ii] = min(h);
pxls0 = round(bsxfun(@plus,pxls,[x(ii); y(ii)]));


function pxls0 = klt_grad_region(pxls,pxls_ind,im_g,im0_g)
th = .001;
T = im_g(pxls_ind);

h = fspecial('sobel');
im0x = imfilter(im0_g,h','replicate');
im0y = imfilter(im0_g,h,'replicate');
pxls0 = pxls;
pxls0_ind = pxls_ind;
sz = size(im_g);
for q = 1:20
	Ix = im0x(pxls0_ind);
	Iy = im0y(pxls0_ind);
	It = im0_g(pxls0_ind) - T;

	vel = [Ix(:),Iy(:)]\It(:);
	pxls0 = round(bsxfun(@plus,pxls0,vel));
	pxls0_ind = sub2ind(sz,pxls0(2,:),pxls0(1,:));
	if max(abs(vel))<th, break; end
end


