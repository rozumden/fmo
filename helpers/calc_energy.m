function energy = calc_energy(detection, detection0, ratio)
exp_loss = 0;
if nargin == 3
	exp_fr = ratio/(ratio+1);
	ratio0 = detection.Length/size(detection.inter_traj.pixels,1);
	exp_fr0 = ratio0/(ratio0+1);
	exp_loss = exp(10*abs(exp_fr - exp_fr0));
end

len_loss = 20*(detection0.Length - detection.Length)/detection0.Length;
if len_loss < 0
	% len_loss = exp(-len_loss);
	len_loss = -len_loss;
end

angle0 = (detection0.Last(2) - detection0.First(2))/...
		 (detection0.Last(1) - detection0.First(1));

angle1 = (detection.First(2) - detection0.First(2))/...
		 (detection.First(1) - detection0.First(1));

angle2 = (detection.Last(2) - detection0.First(2))/...
		 (detection.Last(1) - detection0.First(1));

angle0 = atan(angle0);
angle1 = atan(angle1);
angle2 = atan(angle2);

angle1_loss = 100*sin(abs(angle1 - angle0));
angle2_loss = 20*sin(abs(angle2 - angle0));

radius_loss = 10*abs(detection.Radius-detection0.Radius)/detection0.Radius;

color_loss = 20*sqrt(sum((detection.Color - detection0.Color).^2));

energy = len_loss + angle1_loss + angle2_loss + radius_loss + exp_loss;
