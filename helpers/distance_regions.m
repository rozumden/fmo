function d = distance_regions(r1,r2)
dist = pdist2(r1.PixelList',r2.PixelList');
d = min(dist(:));