function J = get_traj(im, im0, F)
J = deconvwnr(rgb2gray(im - im0), rgb2gray(F), 30);
J = J/max(J(:));