function out = remove(back, front, pxls)
BW = logical(zeros(size(back,1),size(back,2)));
BW(pxls) = 1;
dist = bwdist(BW);
BW2 = BW | (dist < 60);
mask = repmat(BW2,[1 1 3]);
out = front;
out(find(mask)) = back(find(mask)); 
