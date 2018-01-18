function cl = classify_nnb(sample, p, m)
cl = [];
for kk = 1:numel(sample)
	p_dists = arrayfun(@(x) sum( ([x{1}(:)] - [sample{kk}(:)]).^2), p);
	m_dists = arrayfun(@(x) sum( ([x{1}(:)] - [sample{kk}(:)]).^2), m);
	if min(p_dists) < min(m_dists)
		cl(kk) = 1;
	else
		cl(kk) = 0;
	end
end