% Abstract class for creating FMO detector
classdef (Abstract) IDetector < handle
   properties
      noise_t_b = 0.05
      noise_t = [0.1 0.08 0.11]
      fmo_t = 0.9
      traj_t = 0.7

      min_area = 100
      min_radius = 3
      min_length = 10
      max_area_dif = 0.2
      strokiness_th = 0.7

      do_stabilize = false
      do_post_process = true
      scale_factor = 1/2

      Size
      Size_r
   end

   methods (Abstract)
      detect(this, im)
   end
   
   methods
      function bin = binarize(this, delta)
         bin = delta(:,:,1) > this.noise_t(1) | ...
               delta(:,:,2) > this.noise_t(2) | ...
               delta(:,:,3) > this.noise_t(3);
         % bin = rgb2gray(delta) > this.noise_t_b;
      end

      function [delta_bin, delta_pm_bin, delta_plus_bin, delta_minus_bin] = get_deltas(this,im,im0,im1)
         if this.do_stabilize
            im1t = stabilize(im,im1);
            im0t = stabilize(im,im0);
         else
            im1t = im1;
            im0t = im0;
         end

         delta_plus = abs(im - im0t);
         delta_minus = abs(im1t - im);
         delta0 = abs(im1t - im0t);

         delta_plus_bin = this.binarize(delta_plus);
         delta_minus_bin = this.binarize(delta_minus);
         delta0_bin = this.binarize(delta0);

         delta_pm_bin = delta_plus_bin & delta_minus_bin;
         if this.do_post_process
            delta_pm_bin = Differential.post_process(delta_pm_bin);
         end

         delta_bin = delta_pm_bin & ~delta0_bin;
         if this.do_post_process
            delta_bin = Differential.post_process(delta_bin);
         end
      end

      function regions_fmo = get_regions_fmo(this,delta_bin, delta_pm_bin)
         regions_fmo = regionprops(delta_pm_bin, 'MajorAxisLength', ...
            'PixelList', 'PixelIdxList','Area', 'Orientation', 'BoundingBox');
         scores = arrayfun(@(x) sum(delta_bin(x.PixelIdxList))/x.Area,regions_fmo);
         regions_fmo = regions_fmo(scores > this.fmo_t);
      end

   end
end 