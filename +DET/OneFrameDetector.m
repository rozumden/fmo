classdef OneFrameDetector < DET.IDetector
	properties
		im0 = []
		im00 = []
		im000 = []

		IM0 = []
		IM00 = []
		IM000 = []
	end

	methods
		function this = OneFrameDetector(sz)
			this.Size = sz;
			this.Size_r = round(sz * this.scale_factor);
		end

		function frame = detect(this, IM)
			frame = Frame.empty;
			im = imresize(IM,this.scale_factor);
			bgr = this.get_bgr(im);
			if isempty(bgr)
				this.proceed(im, IM);
				return; 
			end
			delta = this.binarize(abs(im - bgr)) & this.binarize(abs(im - this.im0)) ;
			regions = regionprops(delta, 'PixelList', 'PixelIdxList', 'Area', 'BoundingBox', 'Centroid');
			regions = regions([regions.Area] > 10);
			dt = round(bwdist(~delta));
			lm = (dt >= imdilate(dt, [1 1 1; 1 0 1; 1 1 1])).*logical(dt);
			lm = bwconnlines(lm);
			conn = conv2(double(lm), ones(3,3), 'same');
			strokiness_loss = ones(1,numel(regions));
			for k = 1:numel(regions)
				regions(k).Trajectory = regions(k).PixelIdxList(lm(regions(k).PixelIdxList));
				regions(k).Distances = dt(regions(k).PixelIdxList);
				regions(k).DistancesTrajectory = dt(regions(k).Trajectory);
				regions(k).Radius = median(regions(k).DistancesTrajectory);
				regions(k).MaxRadius = max(regions(k).DistancesTrajectory);
				if regions(k).Radius < 2, continue; end
				if regions(k).MaxRadius - regions(k).Radius > 3, continue; end 
				maxs = regions(k).DistancesTrajectory - 0.8*regions(k).Radius >= 0;
				regions(k).Trajectory = regions(k).Trajectory(maxs);
				regions(k).DistancesTrajectory = regions(k).DistancesTrajectory(maxs);
				regions(k).Length = numel(regions(k).Trajectory);
				if regions(k).Length < 5, continue; end
				
				regions(k).WeightsTrajectory = 3./conn(regions(k).Trajectory);
				% exp_area = 2*regions(k).Radius*regions(k).Length + pi*regions(k).Radius^2;
				exp_area = 2*sum(regions(k).WeightsTrajectory.*regions(k).DistancesTrajectory) + ...
								pi*regions(k).Radius^2;
			    strokiness_loss(k) = abs(exp_area/regions(k).Area - 1);
			    regions(k).strokiness = strokiness_loss(k);
			end
			fmos = regions(strokiness_loss < this.max_area_dif*2);
			fmos = this.get_linear(fmos);
			ptch = []; hog = [];
			% B = this.get_bgr_full_part(IM,[1 1 size(IM,2) size(IM,1)]);
			for k = 1:numel(fmos)
				try
					frame(k) = Frame(this.scale_back(fmos(k)));
				catch
					continue
				end
				frame(k).LinearCoeff = fmos(k).LinearCoeff;
				frame(k).add_boundary(this.Size);
				% [hog{k},ptch{k}] = bbs_patch(abs(IM-B),frame(k).BoundingBox,frame(k).LinearCoeff,frame(k).Radius);
			end
			this.proceed(im, IM);
		end

		function bgr = get_bgr(this, im)
			if isempty(this.im0) 
				bgr = [];
			elseif isempty(this.im00)
				bgr = [];
			elseif isempty(this.im000)
				bgr = fast_median(im,this.im0,this.im00);
			else
				bgr = fast_median(this.im0,this.im00,this.im000);
			end
		end

		function B = get_bgr_full_part(this, IM_C, bbx)
			x = bbx(2):bbx(4);
			y = bbx(1):bbx(3);
			if isempty(this.IM00)
				B = this.IM0(x,y,:);
			elseif isempty(this.IM000)
				B = fast_median(IM_C,this.IM0(x,y,:),this.IM00(x,y,:));
			else
				B = fast_median(this.IM0(x,y,:),this.IM00(x,y,:),this.IM000(x,y,:));
			end
		end

		function [] = proceed(this, im, IM)
			this.im000 = this.im00; 
			this.im00 = this.im0;
			this.im0 = im;

			this.IM000 = this.IM00; 
			this.IM00 = this.IM0;
			this.IM0 = IM;
		end

		function fmos = scale_back(this, fmos)
			fmos.LinearCoeff(2) = fmos.LinearCoeff(2)/this.scale_factor;
			fmos.Centroid = fmos.Centroid/this.scale_factor;
			fmos.PixelList = region_change_scale(fmos.PixelList',1/this.scale_factor);
			fmos.Distances = [];
			fmos.Area = fmos.Area/this.scale_factor; 
			fmos.Radius = fmos.Radius/this.scale_factor; 
			fmos.MaxRadius = fmos.MaxRadius/this.scale_factor; 
			fmos.Length = fmos.Length/this.scale_factor;
			fmos.PixelIdxList = sub2ind(this.Size,fmos.PixelList(2,:),fmos.PixelList(1,:));
			fmos.BoundingBox = fmos.BoundingBox - [1 1 -2 -2];
			fmos.BoundingBox = round(fmos.BoundingBox/this.scale_factor);
			[y,x] = ind2sub(this.Size_r,fmos.Trajectory);
			minx = floor(min(x)/this.scale_factor);
			maxx = ceil(max(x)/this.scale_factor);
			xs = minx:maxx;
			ys = polyval(fmos.LinearCoeff, xs);
			fmos.TrajectoryXY = [xs; ys];
			fmos.Trajectory = sub2ind(this.Size, ys, xs);
		end	

		function fmos = get_linear(this, regi)
			loss = zeros(1,numel(regi));
			for kk = 1:numel(regi)
				[y x] = ind2sub(this.Size_r, regi(kk).Trajectory);
				% regi(kk).LinearCoeff = polyfit(x, y, 1);
				regi(kk).LinearCoeff = ransac_line([x';y'],20,1);
				c = regi(kk).LinearCoeff;
				dists = abs(c(1)*x - y + c(2))/sqrt(c(1)^2 + 1);
				loss(kk) = max(dists);
			end
			fmos = regi(loss <= 2);
		end
	end

end