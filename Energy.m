classdef Energy
   properties

   end

   methods

   end

   methods(Static)
      function ind = best(scores)
         [~,ind] = min(scores);
      end

      function [score,ind,expected,loss] = calc(first, last, neighbours, back, front, alpha, model)
         score = NaN;
         sz = size(front);
         offset = sz(1)*sz(2);
         r = round(model.Radius);
         dx = last(1) - first(1);
         dy = last(2) - first(2);
         hyp = sqrt(dx^2 + dy^2);
         if hyp < 1.5
            return;
         end
         sine = dy/hyp;
         cosine = dx/hyp;
         traj = bsxfun(@plus, first, bsxfun(@mtimes, [1:hyp],[cosine; sine]));
         d = pdist2(traj',neighbours','euclidean','Smallest',1);
         inl = round(neighbours(:,d < r));
         dist = d(d < r);
         dist = dist(inl(2,:) > 0 & inl(1,:) > 0 & inl(2,:) <= sz(1) & inl(1,:) <= sz(2));
         inl = inl(:,inl(2,:) > 0 & inl(1,:) > 0 & inl(2,:) <= sz(1) & inl(1,:) <= sz(2));
         if numel(inl) < 4
            return; 
         end
         inl = sub2ind(sz,inl(2,:),inl(1,:));

         % f = cos(pi/2*dist/r);
         f = sqrt(1 - (dist.^2)./(r^2));
         obj = repmat(model.Color,[1 numel(f)]);
         f = repmat(f,[3 1]);
         ind = [inl; ...
                inl+offset; ...
                inl+2*offset];
         a = alpha + norm(model.Color)/6; 
         expected = (a*f).*obj + (1 - (a*f)).*back(ind);
         loss = sqrt(sum((expected - front(ind)).^2));
         loss(loss > 0.3) = 0.3;
         score = mean(loss);
      end

      % function score = calc_fast(first,last, model)
      %    r = round(model.Radius);
      %    t = linspace(0, 2*pi, 10); 
      %    c1 = [r*cos(t)+first(1); r*sin(t)+first(2)];
      %    c2 = [r*cos(t)+last(1); r*sin(t)+last(2)];
      %    c = double([c1 c2]);
      %    k = convhull(c(1,:),c(2,:));
      %    BW = poly2mask(c(1,k), c(2,k), sz(1), sz(2));
      %    inl = find(BW);
      %    obj = repmat(model.Color,[1 numel(inl)])';
      %    ind = [inl ...
      %           inl+model.Offset ...
      %           inl+2*model.Offset];
      %    a = model.frame0.Alpha; 
      %    expected = (a).*obj + (1 - (a)).*model.back(ind);
      %    front = model.front(ind);
      %    loss = sqrt(sum((expected' - front').^2));
      %    score = mean(loss);
      % end

      function ang = best_ori(p1, len, ang0, back, front, alpha, model)
         e = pi/180; 
         inter = [-4:1:4];
         len = round(len);
         [x y] = meshgrid((p1(1)-len):(p1(1)+len),(p1(2)-len):(p1(2)+len));
         neighbours = [x(:) y(:)]';
         for i = 1:numel(inter)
            p2 = p1 + len*[cos(ang0 + inter(i)*e); sin(ang0 + inter(i)*e)];
            score(i) = Energy.calc(p1, p2, neighbours, back, front, alpha, model);
         end
         ind = Energy.best(score);
         rot = inter(ind);
         if sum(rot == [-1 0 1]) == 1
            ang = ang0 + rot*e;
            return
         elseif rot < 0
            inter = -[2:45];
            score = score(3:-1:1);
         else
            inter = [2:45];
            score = score(7:9);
         end
         k = 0;
         for i = 4:numel(inter)
            p2 = p1 + len*[cos(ang0 + inter(i)*e); sin(ang0 + inter(i)*e)];
            score(i) = Energy.calc(p1, p2, neighbours, back, front, alpha, model);
            if all(score(i-3) < [score((i-2):i)])
               k = i;
               break;
            end
         end
         if k == 0
            ind = Energy.best(score);
            ang = ang0 + inter(ind)*e;
         else
            ang = ang0 + inter(k)*e;
         end
      end

      function ang = best_ori_global(p1, len, ang0, back, front, alpha, model)
         e = pi/180; 
         inter = [-30:1:30];
         len = round(len);
         [x y] = meshgrid((p1(1)-len):(p1(1)+len),(p1(2)-len):(p1(2)+len));
         neighbours = [x(:) y(:)]';
         for i = 1:numel(inter)
            p2 = p1 + len*[cos(ang0 + inter(i)*e); sin(ang0 + inter(i)*e)];
            score(i) = Energy.calc(p1, p2,neighbours, back, front, alpha, model);
         end
         ind = Energy.best(score);
         rot = inter(ind);
         ang = ang0 + rot*e;
      end

      function p1n = best_point(p1, p2, ang, back, front, alpha, model)
         len = sqrt(sum((p1 - p2).^2));
         len = min(len/2, 8*model.Radius);
         d = [(-len):1:len];
         [x y] = meshgrid((p1(1)-len):(p1(1)+len),(p1(2)-len):(p1(2)+len));
         neighbours = [x(:) y(:)]';
         cosine = cos(ang); sine = sin(ang);
         for i = 1:numel(d)
            p1n = p1 + d(i)*[cosine; sine];
            score(i) = Energy.calc(p1n, p2,neighbours, back, front, alpha, model);
         end
         ind = Energy.best(score);
         p1n = p1 + d(ind)*[cosine; sine];
      end

   end

end