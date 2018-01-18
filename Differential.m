classdef Differential < handle
   properties(Constant)
      min_cc = 8
      thresh = [0.1 0.07 0.02]
      max_f =  [400 700 700];
      min_f =  [300  700   1000];     
      noise_t = 0.1;
      noise_t_b = 0.05;
   end

   properties
      dI
      dI3
      back
      front

      bin
      bin_full

      bin_all
      bin_full_all

      regions_full
   end

   methods
      function this = Differential(im1,im2)
      	this.back = im1;
         this.front = im2;
         this.dI3 = abs(this.front - this.back);

         denoise = ones(3) / 9;
         this.dI = abs(conv2(rgb2gray(this.dI3), denoise, 'same'));
         this.bin_all = cell(1,numel(this.thresh));
         this.bin_full_all = this.bin_all;
      end

      function available = get(this, n)
         available = 1;
         if n > numel(this.thresh)
            available = 0;
            return;
         end
         if isempty(this.bin_full_all{n}) || isempty(this.bin_all{n})
            [this.bin_full_all{n},this.bin_all{n}] = Differential.post_process(this.dI > this.thresh(n));
         end
         this.bin_full = this.bin_full_all{n};
         this.bin = this.bin_all{n};
         f = sum(this.bin_full(:));
         if f < this.min_f(n)
            available = 2;
         elseif f > this.max_f(n)
            available = 1;
         end
      end

      function dist_trans = get_dist(this,pixels)
         bin = logical(ones(size(this.bin)));
         bin(pixels) = 0;
         dist_trans = bwdist(bin);
         dist_trans = dist_trans(pixels);
      end

      function regions_full = get_regions_full(this)
         if isempty(this.regions_full)
            this.regions_full = regionprops(this.bin_full,'BoundingBox','PixelIdxList','PixelList');
         end
         regions_full = this.regions_full;
      end
   end

   methods(Static)
      function [bin_full,bin] = post_process(bin_full)
         bin_full = ~bwareaopen(~bin_full,Differential.min_cc);
         bin_full = bwmorph(bin_full,'bridge');
         bin_full = bwareaopen(bin_full,Differential.min_cc);
         bin_full = imfill(bin_full,'holes');
         if nargout == 2
            bin = bwmorph(bin_full,'thin',Inf);
            bin = bwareaopen(bin,Differential.min_cc);
         end
      end

      function [bin_full] = remove_noise(bin_full)
         bin_full = bwareaopen(bin_full,Differential.min_cc);
      end

      function [fmo, dI, d, bin]  = get_fmo(im, im0, im1)
         fmo = [];
         im_int = rgb2gray(im);
         im1_int = rgb2gray(im1);
         im0_int = rgb2gray(im0);
         sz = size(im1_int);
         d = abs(im1 - im0);
         B = zeros([sz 3]);
         inl = abs(im1_int - im0_int) < Differential.noise_t_b;
         inl3 = repmat(inl,[1 1 3]);
         B(inl3) = im1(inl3);
         dI = abs(im - B);
         dI(~inl3) = 0;
         bin = dI(:,:,1) > Differential.noise_t | ...
               dI(:,:,2) > Differential.noise_t | ...
               dI(:,:,3) > Differential.noise_t;
         bin = Differential.post_process(bin);
         regions = regionprops(bin,'PixelIdxList','Area');
         if isempty(regions)
            return;
         end
         dist = bwdist(~bin);
         loss = NaN*ones(size(regions));
         for i = 1:numel(regions)
            regions(i).Distances = dist(regions(i).PixelIdxList);
            regions(i).Radius = max(regions(i).Distances);
            normd = regions(i).Distances/regions(i).Radius;
            regions(i).Trajectory = regions(i).PixelIdxList(normd > 0.8,:)';
            regions(i).Length = 0;
            if ~Frame.is_connected(regions(i).Trajectory,sz)
               loss(i) = Inf;
               regions(i).Trajectory = [];
            end
         end
         bin_traj = logical(zeros(sz));
         bin_traj([regions.Trajectory]) = 1;   
         dist = bwdist(bin_traj);
         bin_traj_thin = bwmorph(bin_traj,'thin',Inf);
         for i = 1:numel(regions)
            if isinf(loss(i))
               continue;
            end
            md = max(dist(regions(i).PixelIdxList));
            if abs(md - regions(i).Radius) > 7
               loss(i) = Inf;
            else
               regions(i).Trajectory = regions(i).Trajectory(bin_traj_thin(regions(i).Trajectory));
               regions(i).Length = numel(regions(i).Trajectory);
               exp_area = 2*regions(i).Radius*regions(i).Length + pi*regions(i).Radius^2;
               loss(i) = abs(regions(i).Area/exp_area - 1);
            end
         end
         fmo = regions(loss < 0.2);
         [~,ind] = max([fmo.Length]);
         fmo = fmo(ind);
      end
   end
end

