classdef Tracker
	properties(Constant)

	end

	methods(Static)
		function frame = track(frame0, ratio, back, front, model)
			if isempty(ratio)
				ratio = Inf;
			end
			if isempty(frame0.Last) || isempty(frame0.First)
				for i = 1:2
					frame0.First = frame0.Edges(:,i); 
					frame0.Last = frame0.Edges(:,mod(i,2) + 1);
					[frame(i), score(i)] = Tracker.minenergy(frame0, ratio, back, front, model);
				end
				[~,ind] = min(score);
				frame = frame(ind);
				frame0.First = frame0.Edges(:,ind); 
				frame0.Last = frame0.Edges(:,mod(ind,2) + 1);
				if frame.empty
					frame0.Last = []; frame0.First = [];
				end
			else
				frame = Tracker.minenergy(frame0, ratio, back, front, model);
			end
      	end

      	function frame = track_deconv(frame0, im0, im, im1)
			[F,J] = CONV.deconv(im,im0,frame0);
			if any([F(:)] > 1), F = F/max(F(:)); end
			traj = CONV.get_traj(im1,im,F);
      	end

      	function [frame, score] = minenergy(frame0, ratio, back, front, model)
			leng = sqrt(sum((frame0.Last - frame0.First).^2));

			dx = frame0.Last(1) - frame0.First(1);
			dy = frame0.Last(2) - frame0.First(2);
			hyp = sqrt(dx^2 + dy^2);
			sine = dy/hyp;
			cosine = dx/hyp;
			ang0 =  sign(asin(sine))*acos(cosine);
			move0 = leng / ratio;
			len = move0 + leng;
			ang = Energy.best_ori_global(frame0.Last, len, ang0, back, front, frame0.Alpha, model);

			first0 = frame0.Last + move0*[cos(ang); sin(ang)];
			last0 = first0 + leng*[cos(ang); sin(ang)];
			last = Energy.best_point(last0, first0, mod(ang+pi,2*pi), back, front, frame0.Alpha, model);
			first = Energy.best_point(first0, last, ang, back, front, frame0.Alpha, model);
			last = Energy.best_point(last, first, mod(ang+pi,2*pi), back, front, frame0.Alpha, model);
			
			sz = sqrt(sum((last-first).^2));
			ang1 = Energy.best_ori_global(first, sz, ang, back, front, frame0.Alpha, model);
			last = first + sz*[cos(ang1); sin(ang1)];

			last = Energy.best_point(last, first, mod(ang+pi,2*pi), back, front, frame0.Alpha, model);

			center = mean([first last]');
			r = sz/2 + 2*frame0.Radius;
			[x y] = meshgrid((center(1)-r):(center(1)+r),(center(2)-r):(center(2)+r));
			neighbours = [x(:) y(:)]';
			score = Energy.calc(first, last, neighbours, back, front, frame0.Alpha, model);
			if score < 0.2
				frame = Frame.create(first, last, neighbours, model, [size(front,1) size(front,2)]);
			else
				frame = Frame();
			end
		end
	end
end
