classdef GlobalModel < handle
   properties(Static)
      alpha = 1/3
   end

   properties
      Ratio
      Size
      Offset
   end

   methods
      function this = GlobalModel(sz)
         this.Size = sz;
         this.Offset = sz(1)*sz(2);
         this.Ratio = [];
      end

      function is = consist(this, frame0, frame)
         is = true;
         if isempty(this.Ratio)
            return
         end
         len = sqrt(sum((frame.Last - frame.First).^2));
         dist = sqrt(sum((frame.First - frame0.Last).^2));
         exp_dist = len/this.Ratio;
         loss = (dist - exp_dist)/exp_dist/2;
         is = loss < 2;
      end

      function [] = update(this, frame0, frame)
         if isempty(frame0)
            return
         end
         len = sqrt(sum((frame.Last - frame.First).^2));
         dist = sqrt(sum((frame.First - frame0.Last).^2));
         ratio = len/dist;
         if isempty(this.Ratio) 
            this.Ratio = ratio;
         else
            this.Ratio = (1-this.alpha).*this.Ratio + this.alpha*ratio;
         end
      end
   end

end

