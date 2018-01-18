function frame = prediction_minenergy_part(model)
leng = sqrt(sum((model.frame0.Last - model.frame0.First).^2));

dx = model.frame0.Last(1) - model.frame0.First(1);
dy = model.frame0.Last(2) - model.frame0.First(2);
hyp = sqrt(dx^2 + dy^2);
sine = dy/hyp;
cosine = dx/hyp;
ang0 =  sign(asin(sine))*acos(cosine);
move0 = leng /model.Ratio;
len = move0 + leng;
ang = Energy.best_ori_global(model.frame0.Last, len, ang0, model);

first0 = model.frame0.Last + move0*[cos(ang); sin(ang)];
last0 = first0 + leng*[cos(ang); sin(ang)];
last = Energy.best_point(last0, first0, mod(ang+pi,2*pi), model);
first = Energy.best_point(first0, last, ang, model);

sz = sqrt(sum((last-first).^2));
% ang1 = Energy.best_ori_global(last, sz, mod(ang+pi,2*pi), model);
% first = last + sz*[cos(ang1); sin(ang1)];

% ang = mod(ang1+pi,2*pi);
% first = Energy.best_point(first, last, ang, model);
% last = Energy.best_point(last, first, mod(ang+pi,2*pi), model);

center = mean([first last]');
r = sz/2 + 2*model.Radius;
[x y] = meshgrid((center(1)-r):(center(1)+r),(center(2)-r):(center(2)+r));
neighbours = [x(:) y(:)];
score = Energy.calc(first', last', neighbours, model);
% if score < 0.1
	% && abs(sz - leng)/leng < 0.8
	frame = Frame.create(first', last', neighbours, model);
% else
% 	frame = Frame();
% end
