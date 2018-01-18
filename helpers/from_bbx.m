function frame = from_bbx(this, bbx, IM)
	bbx(3:4) = bbx(1:2) + bbx(3:4);
	bbx(bbx < 1) = 1; 
	if bbx(3) > this.Size(2), bbx(3) = this.Size(2); end
	if bbx(4) > this.Size(1), bbx(4) = this.Size(1); end  
	IM_C = IM(bbx(2):bbx(4),bbx(1):bbx(3),:);
	B = this.get_bgr_full_part(IM_C, bbx);
	dif = abs(IM_C - B);
	bin1 = this.binarize(dif);
	region = regionprops(bin1, 'PixelList', 'Area');
	region = region([region.Area] == max([region.Area])); region = region(1);
	region.PixelList = bsxfun(@plus, region.PixelList', (bbx(1:2) - 1)');
	region.PixelIdxList = sub2ind(this.Size, region.PixelList(2,:), ...
	                                       region.PixelList(1,:));
	frame = Frame(region);
	frame.add_dist(this.Size);
	frame.add_colors(this.IM0,IM);
end