function mask = gen_ball(r)
sz = 2*r - 1;
mask = zeros(sz,sz);
[xx yy] = meshgrid(1:sz,1:sz);
S = sqrt((xx-r).^2+(yy-r).^2)<=(r-1);
mask(S) = 1;