function frame = init_guess_fast(bin1,bin2)
cbin = bin1 & bin2;
cbin = bwmorph(cbin,'bridge');
regions = regionprops(bin2,'Area','Centroid','PixelIdxList','PixelList');
regions0 = regionprops(bin1,'Area','Centroid','PixelIdxList','PixelList');
regions = [regions; regions0];
scores = arrayfun(@(x) sum(cbin(x.PixelIdxList))/x.Area,regions);
inl = find(scores > 0.7);
if isempty(inl)
	frame = Frame();
	return; 
end
[~,ind] = max([regions(inl).Area]);
detection = regions(inl(ind));

% BW = zeros(size(bin2));
% BW(detection.PixelIdxList) = 1;
% BW = BW & cbin;
% detection = regionprops(BW,'Area','Centroid','PixelIdxList','PixelList');

frame = Frame(detection);
frame.Direction = [1,2];
