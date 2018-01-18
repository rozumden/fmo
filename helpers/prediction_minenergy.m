function frame = prediction_minenergy(model)
dx = model.frame0.Last(1) - model.frame0.First(1);
dy = model.frame0.Last(2) - model.frame0.First(2);
hyp = sqrt(dx^2 + dy^2);
sine = dy/hyp;
cosine = dx/hyp;

move0 = model.frame0.Length/model.Ratio;

first0 = model.frame0.Last + move0*[cosine; sine];
last0 = first0 + model.frame0.Length*[cosine; sine];

r = round(model.Radius)+1;
a = [1 1];

[x y] = meshgrid((first0(1)-a(1)*r):(first0(1)+a(1)*r),(first0(2)-a(1)*r):(first0(2)+a(1)*r));
firsts = [x(:) y(:)];
% firsts = first0';

[x y] = meshgrid((last0(1)-a(2)*r):(last0(1)+a(2)*r),(last0(2)-a(2)*r):(last0(2)+a(2)*r));
lasts = [x(:) y(:)];

bbs = [min([firsts(:,1); lasts(:,1)]) min([firsts(:,2); lasts(:,2)])] ;
bbs = [bbs [[max([firsts(:,1); lasts(:,1)]) max([firsts(:,2); lasts(:,2)])] - bbs] ];
ma = max(a);
bbs = bbs - [ma*r ma*r -2*ma*r -2*ma*r];
[x y] = meshgrid(bbs(1):(bbs(1)+bbs(3)),bbs(2):(bbs(2)+bbs(4)));
neighbours = [x(:) y(:)];
for i = 1:size(firsts,1)
	first = firsts(i,:);
	for j = 1:size(lasts,1)
		last = lasts(j,:);
		score(i,j) = Energy.calc(first, last, neighbours, model);
	end
end
if ~exist('score','var') | all(isnan(score))
	frame = Frame();
	return
end
[i,j] = find(score == min(score(:)));
i = i(1); j = j(1);


if score(i,j) < 0.1
	first = firsts(i,:);
	last = lasts(j,:);
	frame = Frame.create(first,last,neighbours,model);
else
	frame = Frame();
end
% imshow(model.dif.front);
% plot(lasts(:,1),lasts(:,2),'.r');
% plot(firsts(:,1),firsts(:,2),'.r');

% plot(firsts(i,1),firsts(i,2),'.g');
% plot(lasts(j,1),lasts(j,2),'.g');