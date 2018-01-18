function [] = make_tracker_imgs(frame0, ratio, back, front, model)
% frame0 = frame{n};
% ratio = gmodel.Ratio;
% back = im0;
% front = im;
% model = models(frame0.model);
ratio = 2;
lw = 6;
ms = 35;

image(front);
hold on;
show(frame0,1,0,'b',ms);
% frm = Tracker.track(frame0, ratio, back, front, model);

leng = sqrt(sum((frame0.Last - frame0.First).^2));

dx = frame0.Last(1) - frame0.First(1);
dy = frame0.Last(2) - frame0.First(2);
hyp = sqrt(dx^2 + dy^2);
sine = dy/hyp;
cosine = dx/hyp;
ang0 =  sign(asin(sine))*acos(cosine);
move0 = leng / ratio;
len = move0 + leng;

% ang = Energy.best_ori_global(frame0.Last, len, ang0, back, front, frame0.Alpha, model);
p1 = frame0.Last;
alpha = frame0.Alpha;
score = [];

e = pi/180; 
inter = [-15:1:15];
len = round(len);
[x y] = meshgrid((p1(1)-len):(p1(1)+len),(p1(2)-len):(p1(2)+len));
neighbours = [x(:) y(:)]';
for i = 1:numel(inter)
	p2 = p1 + len*[cos(ang0 + inter(i)*e); sin(ang0 + inter(i)*e)];
	score(i) = Energy.calc(p1, p2,neighbours, back, front, alpha, model);
end
colors = (score - min(score));
colors = colors/max(colors);
colors = 1 - colors;
colors(colors > 0.99) = 0.99;
colors = [colors' colors' colors'];
for i = 1:numel(inter)
	p2 = p1 + len*[cos(ang0 + inter(i)*e); sin(ang0 + inter(i)*e)];
	plot(p2(1),p2(2),'.','Color',colors(i,:),'MarkerSize',ms);
end
ind = Energy.best(score);
rot = inter(ind);
ang = ang0 + rot*e;
p2 = p1 + len*[cos(ang); sin(ang)];
plot(p2(1),p2(2),'xg','MarkerSize',ms,'LineWidth',lw);
p2 = p1 + len*[cos(ang0); sin(ang0)];
plot(p2(1),p2(2),'xr','MarkerSize',ms,'LineWidth',lw);

set(gca,'xtick',[]);
set(gca,'xticklabel',[]);
set(gca,'ytick',[]);
set(gca,'yticklabel',[]);
set(gca,'color','none');
saveas(gcf,'ori.png');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55
score = [];
image(front);
hold on;
show(frame0,1,0,'b',ms);

first0 = frame0.Last + move0*[cos(ang); sin(ang)];
last0 = first0 + leng*[cos(ang); sin(ang)];
% last = Energy.best_point(last0, first0, mod(ang+pi,2*pi), back, front, frame0.Alpha, model);
% p1n = best_point(p1, p2, ang, back, front, alpha, model)
p1 = last0; p2 = first0; ang = mod(ang+pi,2*pi);

len = sqrt(sum((p1 - p2).^2));
len = min(len/3, 8*model.Radius);
d = [(-len):1:len];
[x y] = meshgrid((p1(1)-len):(p1(1)+len),(p1(2)-len):(p1(2)+len));
neighbours = [x(:) y(:)]';
cosine = cos(ang); sine = sin(ang);
for i = 1:numel(d)
	p1n = p1 + d(i)*[cosine; sine];
	score(i) = Energy.calc(p1n, p2,neighbours, back, front, alpha, model);
end
colors = (score - min(score));
colors = colors/max(colors);
colors = 1 - colors;
colors(colors > 0.99) = 0.99;
colors = [colors' colors' colors'];
for i = 1:numel(d)
	p2 = p1 + d(i)*[cosine; sine];
	plot(p2(1),p2(2),'.','Color',colors(i,:),'MarkerSize',ms);
end

ind = Energy.best(score);
last = p1 + d(ind)*[cosine; sine];
plot(last(1),last(2),'xg','MarkerSize',ms,'LineWidth',lw);

plot(p1(1),p1(2),'xr','MarkerSize',ms,'LineWidth',lw);

set(gca,'xtick',[]);
set(gca,'xticklabel',[]);
set(gca,'ytick',[]);
set(gca,'yticklabel',[]);
set(gca,'color','none');
saveas(gcf,'end.png');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
image(front);
hold on;
show(frame0,1,0,'b',ms);
score = [];
% first = Energy.best_point(first0, last, ang, back, front, frame0.Alpha, model);
% p1n = best_point(p1, p2, ang, back, front, alpha, model)
p1 = first0;  p2 = last; ang = mod(ang+pi,2*pi);

len = sqrt(sum((p1 - p2).^2))/3;
% len = min(len/3, 8*model.Radius);
d = [(-len):1:len];
[x y] = meshgrid((p1(1)-len):(p1(1)+len),(p1(2)-len):(p1(2)+len));
neighbours = [x(:) y(:)]';
cosine = cos(ang); sine = sin(ang);
for i = 1:numel(d)
	p1n = p1 + d(i)*[cosine; sine];
	score(i) = Energy.calc(p1n, p2,neighbours, back, front, alpha, model);
end
colors = (score - min(score));
colors = colors/max(colors);
colors = 1 - colors;
colors(colors > 0.99) = 0.99;
colors = [colors' colors' colors'];
for i = 1:numel(d)
	p2 = p1 + d(i)*[cosine; sine];
	plot(p2(1),p2(2),'.','Color',colors(i,:),'MarkerSize',ms);
end

ind = Energy.best(score);
p2 = p1 + d(ind)*[cosine; sine];
plot(p2(1),p2(2),'xg','MarkerSize',ms,'LineWidth',lw);

p2 = p1;
plot(p2(1),p2(2),'xr','MarkerSize',ms,'LineWidth',lw);

set(gca,'xtick',[]);
set(gca,'xticklabel',[]);
set(gca,'ytick',[]);
set(gca,'yticklabel',[]);
set(gca,'color','none');
saveas(gcf,'start.png');

function [] = show(this,alpha,show,color,lw)
 if nargin < 2
    alpha = 1;
 end
 if nargin < 3
    show = 1;
 end
 if nargin < 4
    color = 'b';
 end
 if nargin < 5
    lw = [];
 end
 lw = 20;
 if ~isempty(this.GTBoundingBox) && show
    rectangle('Position',this.GTBoundingBox,'EdgeColor','y'); 
 end
 if ~isempty(this.Length)
    s = plot(this.TrajectoryXY(1,:), ...
          this.TrajectoryXY(2,:), ...
          '.','MarkerSize',lw,'MarkerEdgeColor',color);
    % set(s,'MarkerEdgeAlpha',alpha);
    % if ~isempty(this.inter_traj) && ~isempty(this.inter_traj.pixels)
    %    s = scatter(this.inter_traj.pixels(1,:), ...
    %        this.inter_traj.pixels(2,:), ...
    %        '.','LineWidth',lw,'MarkerEdgeColor',[0 0.5 1]);
    %    % set(s,'MarkerEdgeAlpha',alpha);
    % end
    s = plot(this.BoundaryXY(1,:), ...
          this.BoundaryXY(2,:), ...
          '.','MarkerSize',lw,'MarkerEdgeColor',color);
    % set(s,'MarkerEdgeAlpha',alpha);
 end
