function d = remake_recon(d , phase)
if phase == 1
	for i = 1:4
		img = d.dart_img{i};
		mask = d.dart_mask{i};

		imshow(img);
		[y,x] = ginput;
		center = round([x; y]);
		sz = size(img);
		rad = y;

		img = [img zeros(sz(1), 2*y-sz(2), 3)];
		mask = [mask zeros(sz(1), 2*y-sz(2))];

		sz = size(img);
		img = [img; zeros(y - sz(1) + x, sz(2), 3)];
		mask = [mask; zeros(y - sz(1) + x, sz(2))];

		img = [zeros(rad - x, sz(2), 3); img];
		mask = [zeros(rad - x, sz(2)); mask];

		d.dart_img{i} = img;
		d.dart_mask{i} = mask;
	end
elseif phase == 2
	for i = 1:4
		img = d.dart_img{i};
		mask = d.dart_mask{i};

		imshow(img);
		BW = roipoly;
		img(repmat(~BW,[1 1 3])) = 0;
		mask(repmat(~BW,[1 1 1])) = 0;

		d.dart_img{i} = img/2;
		d.dart_mask{i} = mask;
	end
end