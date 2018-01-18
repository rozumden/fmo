classdef GroundTruth < handle
   properties
      video
      result
      frame
      truth

      tp 
      tn
      fp
      fn
      ol
   end

   methods
      function this = GroundTruth(file, write)
         [a,b,ext] = fileparts(file);
         this.truth = fullfile(a,[b '_gt.mat']);
         if exist(this.truth,'file') == 2
            t = load(this.truth); 
            this.frame = t.gt;
         end
         this.result = fullfile(a,[b '_result.mat']);
         if write
            this.video = VideoWriter(fullfile(a,[b '_result.avi']));
            this.video.FrameRate = 5;
            open(this.video);
         end
         sz = numel(this.frame);
         this.tp = logical(zeros(1,sz));
         this.tn = logical(zeros(1,sz));
         this.fp = logical(zeros(1,sz));
         this.fn = logical(zeros(1,sz));
         this.ol = -ones(1,sz);
      end

      function result = calc_stats(this, frame)
         result = [];
         if ~all(this.tp | this.tn | this.fp | this.fn)
            error('Not all frames were checked!');
         end
         if ~all((this.tp + this.tn + this.fp + this.fn) == 1)
            % error('Inconsistent stats!');
         end   
         tp = sum(this.tp);
         tn = sum(this.tn);
         fp = sum(this.fp);
         fn = sum(this.fn);

         precision = tp/(tp + fp);
         recall = tp/(tp + fn);
         fscore = 2/(1/precision + 1/recall);
         non = arrayfun(@(x) ~isempty(x{1}),frame);

         mean_ol = mean(this.ol(this.ol ~= -1));
         [~,name,~] = fileparts(this.truth);
         fprintf('%s Precision %.2f, recall %.2f, F-score %.2f, mean overlap %.2f\n', ...
            name,100*precision,100*recall,100*fscore,100*mean_ol);
         result.precision = precision;
         result.recall = recall;
         result.fscore = fscore;
         result.mean_ol = mean_ol;
      end

      function frame = get_frame(this,n,sz)
         frame = Frame();
         if isempty(this.frame) || isempty(this.frame{n})
            return;
         end
         this.frame{n} = imfill(this.frame{n},'holes');
         region.PixelIdxList = find(this.frame{n})';
         if isempty(region.PixelIdxList)
            return
         end
         frame = Frame(region);
         if nargin >= 3
            frame.add_dist(sz);
         end
      end

      function [maxerr, frame_gt] = control_traj(this, n, detection, sz)
         maxerr = Inf;
         frame_gt = Frame();
         if isempty(this.frame) || isempty(this.frame{n})
            return;
         end
         this.frame{n} = imfill(this.frame{n},'holes');
         region.PixelIdxList = find(this.frame{n});
         frame_gt = Frame(region);
         frame_gt.add_dist(sz);
         if detection.empty
            return
         end
         detection.add_dist(sz);
         [d,idx] = pdist2(frame_gt.Edges,detection.Edges,'euclidean','Smallest',1);
         if ~isempty(d)
            [maxerr,m] = max(d);
         end
      end

      function [detections, str] = control_all(this, n, detections)
         str = [];
         if isempty(detections)
            if isempty(this.frame{n}) || isempty(find(this.frame{n}))
               str = '+ tn';
               this.tn(n) = true;
            else
               str = '- fn';
               this.fn(n) = true;
            end
            return
         end

         for j = 1:numel(detections)
            if detections(j).empty
               error('Empty detection!');
            end
            [detections(j),strt] = this.control_iter(n, detections(j));
            str = [str strt];
         end
         if this.tp(n)
            this.fp(n) = false; 
         end
         if (this.tp(n) + this.fp(n) + this.tn(n) + this.fn(n)) ~= 1
            error('Wrong stats!');
         end
      end

      function [detection, state] = control_iter(this, n, detection)
         state = [];
         detection.GTBoundingBox = [];

         regions = regionprops(this.frame{n},'BoundingBox','PixelIdxList');
         if isempty(regions)
            cc = [];
         end
         for i = 1:numel(regions)
            cc(i) = Frame(regions(i));
         end
         if numel(cc) > 1
            [~,ind] = max([cc.Area]);
            cc = cc(ind);
         end
         if ~isempty(cc)   
            detection.GTBoundingBox = cc.BoundingBox;
            ind = find(this.frame{n})';
            inter = numel(intersect(ind,detection.PixelIdxList));
            uni = numel(unique([ind detection.PixelIdxList]));
            iou = inter/uni;
            if iou > 0.1
               this.tp(n) = true;
               state = '+ tp';
            else
               this.fp(n) = true;
               state = '- fp';
            end
            this.ol(n) = max(this.ol(n),iou);
         else
            this.fp(n) = true;
            state = '- fp';
         end
      end

      function [] = close(this)
         close(this.video);
      end
   end

   methods(Static)
      function [] = make(file,n)
         global check_file;
         v = check_file(file);
         gtruth = GroundTruth(file,0);
         if isempty(gtruth.frame)
            gtruth.frame = cell(1,v.NumberOfFrames);
         end
         n = unique([[n-1] n]);
         for i = n
            if isempty(gtruth.frame{i})
               gtruth.frame{i} = roipoly(v.read(i));
            end
         end
         gt = gtruth.frame;
         save(gtruth.truth,'gt');
      end
   end   

end