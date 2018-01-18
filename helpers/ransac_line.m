function [LinearCoeff] = ransac_line( pts,iterNum,thDist,thInlrRatio )
%RANSAC Use RANdom SAmple Consensus to fit a line
%	RESCOEF = RANSAC(PTS,ITERNUM,THDIST,THINLRRATIO) PTS is 2*n matrix including 
%	n points, ITERNUM is the number of iteration, THDIST is the inlier 
%	distance threshold and ROUND(THINLRRATIO*SIZE(PTS,2)) is the inlier number threshold. The final 
%	fitted line is RHO = sin(THETA)*x+cos(THETA)*y.
%	Yan Ke @ THUEE, xjed09@gmail.com

sampleNum = 2;
ptNum = size(pts,2);
% thInlr = round(thInlrRatio*ptNum);
inlrNum = zeros(1,iterNum);
theta1 = zeros(1,iterNum);
rho1 = zeros(1,iterNum);

for p = 1:iterNum
	% 1. fit using 2 random points
	sampleIdx = randIndex(ptNum,sampleNum);
	ptSample = pts(:,sampleIdx);
	d = ptSample(:,2)-ptSample(:,1);
	d = d/norm(d); % direction vector of the line
	
	% 2. count the inliers, if more than thInlr, refit; else iterate
	n = [-d(2),d(1)]; % unit normal vector of the line
	dist1 = n*(pts-repmat(ptSample(:,1),1,ptNum));
	inlier1 = find(abs(dist1) < thDist);
	inlrNum(p) = length(inlier1);
	% if length(inlier1) < thInlr, continue; end
	ev = princomp(pts(:,inlier1)');
	d1 = ev(:,1);
	theta1(p) = -atan2(d1(2),d1(1)); % save the coefs
	rho1(p) = [-d1(2),d1(1)]*mean(pts(:,inlier1),2);
end

% 3. choose the coef with the most inliers
[~,idx] = max(inlrNum);
theta = theta1(idx);
rho = rho1(idx);

LinearCoeff = [-sin(theta) rho]./cos(theta);
% dists = abs(LinearCoeff(1)*pts(1,:) - pts(2,:) + LinearCoeff(2))/sqrt(LinearCoeff(1)^2 + 1);
% err = max(dists);


function index = randIndex(maxIndex,len)
%INDEX = RANDINDEX(MAXINDEX,LEN)
%   randomly, non-repeatedly select LEN integers from 1:MAXINDEX

if len > maxIndex
	index = [];
	return
end

index = zeros(1,len);
available = 1:maxIndex;
rs = ceil(rand(1,len).*(maxIndex:-1:maxIndex-len+1));
for p = 1:len
	while rs(p) == 0
		rs(p) = ceil(rand(1)*(maxIndex-p+1));
	end
	index(p) = available(rs(p));
	available(rs(p)) = [];
end