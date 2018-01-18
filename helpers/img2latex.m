function XY = img2latex(xy,sz)
xy(1) = sz(1) - xy(1) + 1;

XY(1) = xy(1) - round(sz(1)/2);
XY(2) = xy(2) - round(sz(2)/2);
XY = XY/(sz(1)/2);