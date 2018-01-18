function X = hog2feature(hog)
X = [];
for kk = 1:numel(hog)
	X(kk,:) = [hog{kk}(:)];
end 