classdef Detector
	properties(Constant)
		noise_t_b = 0.05
		noise_t = [0.1 0.08 0.11]
		fmo_t = 0.9
		traj_t = 0.7

		min_area = 100
		min_radius = 3
		min_length = 10
		max_area_dif = 0.2

		do_stabilize = false
	end

	methods(Static)
		function bin = binarize(delta)
			bin = delta(:,:,1) > Detector.noise_t(1) | ...
				  delta(:,:,2) > Detector.noise_t(2) | ...
				  delta(:,:,3) > Detector.noise_t(3);
			% bin = rgb2gray(delta) > Detector.noise_t_b;
		end

		function [fmo, delta_plus, delta_minus, delta_plus_minus_bin, regions_fmo] = detect(im, im0, im1)
			sz = [size(im,1) size(im,2)];
			if Detector.do_stabilize
				im1t = stabilize(im,im1);
				im0t = stabilize(im,im0);
			else
				im1t = im1;
				im0t = im0;
			end

			delta_plus = abs(im - im0t);
			delta_minus = abs(im1t - im);
			delta0 = abs(im1t - im0t);

			delta_plus_bin = Detector.binarize(delta_plus);
			delta_minus_bin = Detector.binarize(delta_minus);
			delta0_bin = Detector.binarize(delta0);

			delta_plus_minus_bin = delta_plus_bin & delta_minus_bin;
			delta_plus_minus_bin = Differential.post_process(delta_plus_minus_bin);

			delta_bin = delta_plus_minus_bin & ~delta0_bin;
			delta_bin = Differential.post_process(delta_bin);
			% delta_bin_fmo = logical(zeros(sz));

			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%555
			% ind = repmat(delta_bin,[1 1 3]); 
			% B = zeros(size(im));
			% B(ind) = im0(ind);
			% B(~ind) = im(~ind);
			% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

			% regions = regionprops(delta_bin,'PixelIdxList','Area');
			regions = regionprops(delta_plus_minus_bin,'PixelList', 'PixelIdxList','Area','Centroid');
			scores = arrayfun(@(x) sum(delta_bin(x.PixelIdxList))/x.Area,regions);
			regions = regions(scores > Detector.fmo_t);
			regions_fmo = regions;

			fmo = [];
			if isempty(regions)
				return;
			end
			dist = bwdist(~delta_bin);
			loss = NaN*ones(size(regions));
			for i = 1:numel(regions)
				regions(i).PixelIdxList = regions(i).PixelIdxList';
				regions(i).PixelList = regions(i).PixelList';
				regions(i).Distances = dist(regions(i).PixelIdxList);
				regions(i).Radius = max(regions(i).Distances);
				normd = regions(i).Distances/regions(i).Radius;
				regions(i).Trajectory = regions(i).PixelIdxList(normd > Detector.traj_t);
				regions(i).TrajectoryXY = regions(i).PixelList(:,normd > Detector.traj_t);
				regions(i).Length = 0;
				if ~Frame.is_connected(regions(i).Trajectory,sz)
				   loss(i) = Inf;
				   regions(i).Trajectory = [];
				   regions(i).PixelIdxList = [];
				end
			end
			delta_fmo_bin = logical(zeros(size(delta_bin)));
			delta_fmo_bin([regions.PixelIdxList]) = 1;

			fast = ~isinf(loss);

			bin_traj = logical(zeros(sz));
			bin_traj([regions.Trajectory]) = 1;   
			bin_traj_thin = bwmorph(bin_traj,'thin',Inf);
			for i = 1:numel(regions)
				if isinf(loss(i))
				   continue;
				end
				loss(i) = Inf;

				bin_traj1 = logical(zeros(sz));
				bin_traj1(regions(i).Trajectory) = 1;   
				dist = bwdist(bin_traj1);
				inl = dist(regions(i).PixelIdxList) <= regions(i).Radius;
				
				regions(i).PixelIdxList = regions(i).PixelIdxList(inl);
				regions(i).PixelList = regions(i).PixelList(:,inl);
				regions(i).Distances = regions(i).Distances(inl);

				regions(i).Trajectory = regions(i).Trajectory(bin_traj_thin(regions(i).Trajectory));
				regions(i).Length = numel(regions(i).Trajectory);
			    if regions(i).Length > Detector.min_length && ...
			       regions(i).Area > Detector.min_area && ...
			       regions(i).Radius > Detector.min_radius

				   exp_area = 2*regions(i).Radius*regions(i).Length + pi*regions(i).Radius^2;
				   loss(i) = abs(regions(i).Area/exp_area - 1);
				end
			end
			regions_fmo = regions(fast);
			fmo = regions(loss < Detector.max_area_dif);
      	end
	end
end
