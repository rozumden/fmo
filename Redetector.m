classdef Redetector
	properties(Constant)

	end

	methods(Static)
		function frame = redetect(frame0, regions, back, front)
			frame = [];
			sz = [size(back,1) size(back,2)];
			proposed = Redetector.find_near(frame0, regions, sz);
			if ~isempty(proposed)
				for i = 1:numel(proposed)
					frames(i) = Frame(proposed(i));
					frames(i).add_dist(sz);
					frames(i).Alpha = frame0.Alpha;
					frames(i).add_colors(back, front);
				end
				frames = frames(frame0.consist_color0(frames));
				frames = frames(frame0.consist_radius0(frames));
				if ~isempty(frames) && numel(frames) < 3
					regions = combine_regions(frames);
					frame = Frame(regions);
				end
			end
      	end

      	function regions_near = find_near(frame0, regions, sz)
      		len = 50*frame0.Radius;
			sq = [max(1,(frame0.Centroid(1)-len)); 
			      min(sz(2),(frame0.Centroid(1)+len));
			      max(1,(frame0.Centroid(2)-len)); 
			      min(sz(1),(frame0.Centroid(2)+len))];
			near = arrayfun(@(x) Redetector.inside(x.PixelList, sq), regions, 'UniformOutput', false);
			regions_near = regions([near{:}]);
      	end

      	function in = inside(pixels, sq)
      		in = any(pixels(1,:) > sq(1) & pixels(1,:) < sq(2) & pixels(2,:) > sq(3) & pixels(2,:) < sq(4));
      	end

      	function bin_near = cut(frame0,bin)
			len = 50*frame0.Radius;
			sq = [max(1,(frame0.Centroid(1)-len)); 
			      min(size(bin,2),(frame0.Centroid(1)+len));
			      max(1,(frame0.Centroid(2)-len)); 
			      min(size(bin,1),(frame0.Centroid(2)+len))];
			sq = uint32(sq);

			bin_near = logical(zeros(size(bin)));
			bin_near(sq(3):sq(4),sq(1):sq(2)) = bin(sq(3):sq(4),sq(1):sq(2));
			bin_near(frame0.PixelIdxList) = 0;
		end
	end
end
