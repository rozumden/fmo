function frame = fmo2(im,detec)
frame = detec.detect(im);

if numel(frame) == 0, return; end
% load('svm_art');
% cl = predict(svm, hog2feature(hog));
% frame = frame(logical(cl));

% clf;
% image(im);
% hold on;
% sz = size(im);
% imhog = [];
% load('svm_art');
% for k = 1:numel(frame)
% 	[y x] = ind2sub(sz,frame(k).Trajectory);
% 	plot(frame(k).BoundaryXY(1,:), frame(k).BoundaryXY(2,:),'.b');
% 	plot(x,y,'.r');
% 	[hog{k}, ptch] = bbs_patch(im,frame(k).BoundingBox,frame(k).LinearCoeff,frame(k).Radius);
% 	cl = predict(svm, hog2feature(hog(k)));
% 	imhog0 = vl_hog('render', hog{k}, 'NumOrientations',8);
% 	cllab = ones(5,3*7*20,3); cllab(:,:,3) = 0; 
% 	cllab(:,:,1) = cl == 0; 
% 	cllab(:,:,2) = cl == 1; 
% 	imhog = cat(1,imhog,cllab,imresize(ptch,7),repmat(imhog0,[1 1 3]),cllab);
% end
% drawnow;

% load('svm_art');
% cl1 = predict(svm, hog2feature(hog));
% figure;
% imshow(imhog)

% % if sum(cl ~= cl1') ~= 0, keyboard; end
% close all

