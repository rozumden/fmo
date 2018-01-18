classdef Model < handle
   properties
      Rate
      predicted
      dif
      dif0
      regions_near
      in_pred
      regions_full
      frame0
      frame
      init
      status

      Color
      Ratio
      Radius
      Size

      thresh_n
      offset
      stabilize = 0
   end

   methods
      function [] = reset(this)
         this.Rate = 0;
         this.Ratio = [];
         this.predicted = 0;
         this.thresh_n = 1;
         this.frame = Frame();
      end

      function same = next_iter(this,im1,im2)
         this.frame0 = this.frame;
         this.frame = Frame();
         this.status = [];
         this.init = 0;
         this.regions_full = [];
         this.dif0 = this.dif;
         this.dif = Differential(im1,im2);
         this.offset = size(im1,1)*size(im1,2);
      end

      function available = next_bin(this)
         ns = [1:numel(this.dif.thresh)];
         ns = [this.thresh_n ns(ns ~= this.thresh_n)];
         for i = ns
            available = this.dif.get(i); 
            if available == 1
               if ~isempty(this.dif0)
                  this.dif0.get(i); 
               end
               this.thresh_n = i;
               break
            end
         end
         if available == 2
            this.dif = this.dif0;
         end
      end

      function frame = new_detection(this, frame)
         if frame.empty
            return;
         end
        
         frame = this.add_info(frame,this.dif0);
         this.init = 1;
         if this.Rate < 4  
            this.Rate = 1;
            this.Color = frame.Color;
            this.Radius = frame.Radius;
            this.Ratio = [];
         else
            if ~this.check_consistency(frame, this.dif0)
               frame = Frame();
            end
         end
      end

      function [check,energy] = check_consistency(this, frame, dif)
         energy = Inf;
         check = true;
         % check = check && abs(frame.Radius-this.Radius)/this.Radius < 0.5;
         % check = check && frame.Alpha > 0.01 && frame.Alpha < 0.9;
         % check = check && this.check_fmo(frame, dif) < 0.2;
         % check = check && frame.Orientation ~= 0;
         exp_area = 2*frame.Radius*frame.Length + pi*frame.Radius^2;
         check = check && frame.Area/exp_area < 1.3 && frame.Area/exp_area > 0.7;
         if ~this.frame0.empty && check
            energy = calc_energy(frame, this.frame0, this.Ratio);
            check = check && energy < 40;
         end
      end

      function err = check_fmo(this,frame, dif)
         [expected, front, ind] = this.calc_fmo(frame, dif);
         loss = sqrt(sum((expected' - front').^2));
         err = mean(loss);
      end

      function [expected, front, ind] = calc_fmo(this, frame, dif)
         f = frame.Distances;
         f = f + max(0,min(this.Radius - f));
         f(f > this.Radius) = this.Radius;
         f = sin(pi/2*f/this.Radius);
         obj = repmat(this.Color,[1 numel(f)])';
         f = repmat(f,[1 3]);
         ind = [frame.PixelIdxList ...
                frame.PixelIdxList+this.offset ...
                frame.PixelIdxList+2*this.offset];
         a = frame.Alpha;
         expected = (a*f).*obj + (1 - (a*f)).*dif.back(ind);
         front = dif.front(ind);
      end

      function frame = add_info(this, frame, dif)
         if frame.empty
            return
         end
         if isempty(frame.Distances)
            regions_full = dif.get_regions_full();
            inl = arrayfun(@(x) ~isempty(intersect(x.PixelIdxList,frame.PixelIdxList)),regions_full);
            found = regions_full(inl);
            bbs = reshape([found.BoundingBox],4,[])';
            BoundingBox(1:2) = [min(bbs(:,1)) min(bbs(:,2))];
            BoundingBox(3:4) = [max(bbs(:,1)+bbs(:,3)) max(bbs(:,2)+bbs(:,4))] - BoundingBox(1:2);
            frame.PixelIdxList = [];
            frame.PixelList = [];
            for i = 1:numel(found)
               frame.PixelIdxList = [frame.PixelIdxList; found(i).PixelIdxList];
               frame.PixelList = [frame.PixelList; found(i).PixelList];
            end
            frame.BoundingBox = BoundingBox;
            frame.Distances = dif.get_dist(frame.PixelIdxList);
            frame.Radius = max(frame.Distances);
            normd = frame.Distances/frame.Radius;
            frame.TrajectoryXY = frame.PixelList(normd > 0.7,:);
         end
         frame.Trajectory = sub2ind(size(this.dif.bin),frame.TrajectoryXY(:,2),frame.TrajectoryXY(:,1));
         bin = logical(zeros(size(this.dif.bin)));
         bin(frame.Trajectory) = 1;
         bin = bwmorph(bin,'thin',Inf);
         frame.Trajectory = find(bin);
         frame.Length = numel(frame.Trajectory);
         if ~isfield(frame,'Orientation')
            regions = regionprops(bin,'Orientation');
            frame.Orientation = regions.Orientation;
         end
         frame.Alpha = (2*frame.Radius)/(frame.Length + 2*frame.Radius);

         [y x] = ind2sub(size(this.dif.bin),frame.Trajectory);
         frame.TrajectoryXY = [x y];
         [d,idx] = pdist2(frame.TrajectoryXY,frame.TrajectoryXY,'euclidean','Largest',1);
         [~,m] = max(d);
         frame.Edges = frame.TrajectoryXY([m idx(m)],:);

         ind = [frame.Trajectory ...
                frame.Trajectory+this.offset ...
                frame.Trajectory+2*this.offset];
         colors = (dif.front(ind) - (1-frame.Alpha)*dif.back(ind))/frame.Alpha;
         frame.Color = mean(colors)';
         frame.Color = max(min(frame.Color, [1 1 1]'),[0 0 0]');
         if numel(ind) > 3
            frame.MixedColor = mean(dif.front(ind))';
         else
            frame.MixedColor = dif.front(ind)';
         end
         frame.Area = numel(frame.PixelIdxList);
         if ~this.frame0.empty
            if isempty(this.frame0.Last)
               [d,idx] = pdist2(frame.Edges,this.frame0.Edges,'euclidean','Smallest',1);
               [~,m] = min(d);
               this.frame0.Last = this.frame0.Edges(m,:)';
               this.frame0.First = this.frame0.Edges(setdiff([1 2],m),:)';
            else
               [d,idx] = pdist2(frame.Edges,this.frame0.Last','euclidean','Smallest',1);
               [~,m] = min(d);
            end
            last = this.frame0.Last;
            frame.First = frame.Edges(idx(m),:)';
            frame.Last = frame.Edges(setdiff([1 2],idx(m)),:)';
            frame.inter_traj = bwline2(frame.First,last);
         end
      end

      function frame = find_neighbours(this)
         this.status = 3;
         regions_nb = this.regions_near(~this.in_pred);
         frame = Frame();
         if ~isempty(regions_nb)
            [~,d] = knnMatch(this.frame0,regions_nb,'mixcolor');
            regions = regions_nb(d < 0.3);
            regions = regions([regions.Alpha] > 0.05 & [regions.Alpha] < 0.95);
            if ~isempty(regions)
               v = abs([regions.Radius] - this.Radius);
               regions = regions(v < 4);
            end
            for i = 1:numel(regions)
               frame(i) = Frame(regions(i));
               frame(i) = this.add_info(frame(i),this.dif);
               [~,err(i)] = this.check_consistency(frame(i), this.dif);
            end
            if ~isempty(regions)
               [v,ind] = min(err);
               if v < 100
                  frame = frame(ind);
               else
                  frame = Frame();
               end
            end
            if ~frame.empty
               this.predicted = 0;
            end
         end
      end

      function [] = update(this, frame0, frame)
         this.predicted = this.predicted + 1;
         if Rate == 0
            this.Radius = frame0.Radius;
            this.Color = frame0.Color;
            return
         end
         if this.predicted < 2
            return;
         end
         this.Rate = this.Rate + 1;
         
         alpha = 1/2;
         this.Color = (1-alpha)*this.Color + alpha*frame.Color;
         this.Radius = (1-alpha)*this.Radius +alpha*frame.Radius;

         len = sqrt(sum((frame.Last - frame.First).^2));
         dist = sqrt(sum((frame.First - frame0.Last).^2));
         ratio = len/dist;
         if isempty(this.Ratio) 
            this.Ratio = ratio;
         else
            this.Ratio = (1-alpha).*this.Ratio + alpha*ratio;
         end
      end
   end

end

