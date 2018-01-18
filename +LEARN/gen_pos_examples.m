function hogp = gen_pos_examples()
n_samples = 1000;
row = 4;
col = 20;
inc = 3;
cellSize = 3;

radius = 16;
colors = distinguishable_colors(n_samples+5);
I = ones(row*cellSize*inc,col*cellSize*inc);
k = 1;
while k <= n_samples
	bgr_ind = round(n_samples*rand()+2);
	bgr_col = colors(bgr_ind,:);
	F_ind = round(n_samples*rand()+2);
	F_col = colors(F_ind,:);
	if sum((F_col - bgr_col).^2) < 0.5
		continue;
	end
	bgr = cat(3,I*bgr_col(1),I*bgr_col(2),I*bgr_col(3));
	obsticle_col = colors(round(n_samples*rand()+2),:);
	[ys,xs] = find(logical(I));
	sz = numel(xs) - 1;
	i1 = round(sz*rand()+1);
	i2 = round(sz*rand()+1);
	ind = line_ind([xs(i1);ys(i1)],[xs(i2);ys(i2)],xs,ys);
	bgr(ind) = obsticle_col(1);

	r = radius -2+mod(k,5);
	M = APP.gen_ball(r);
	T = zeros(size(I));
	T(r,(r):(end-r)) = 1;
	F = cat(3,M*F_col(1),M*F_col(2),M*F_col(3));
	len = sum(T(:))/3;
	a = conv2(T,M,'same')/len;
	Fconv = cat(3,conv2(T,F(:,:,1),'same'),conv2(T,F(:,:,2),'same'),conv2(T,F(:,:,3),'same'));
	ptch = (1 - a(:,:,[1 1 1])).*bgr + Fconv/len;
	ptch = imresize(ptch,1/inc);
	ptch = ptch.^(1/2.2);
	hogp{k} = vl_hog(im2single(real(ptch)), cellSize, 'NumOrientations', 8);
	imhog = vl_hog('render', hogp{k}, 'NumOrientations', 8);
	% imshow(imresize(ptch,20));
	imshow(imhog);
	drawnow;
	disp(k)
	k = k + 1;
end

function ind = line_ind(Q1,Q2,xs,ys)
max_d = round(15*(rand()+0.5));
d = arrayfun(@(x,y)  abs(det([Q2-Q1,[x;y]-Q1]))/abs(Q2-Q1) , xs,ys,'UniformOutput',false);
ind = arrayfun(@(x) x{1}(1) < max_d, d);