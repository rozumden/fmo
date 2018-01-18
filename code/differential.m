function [difference, mask] = differential(f1, f2, noiseThreshold)
%Function differential computes differential image and binary mask
%
%Input:
%f1             ... frame t+1
%f2             ... frame t
%noiseThreshold ... threshold for binary image
%
%Output:
%difference ... differential image
%mask       ... binary mask of moving objects
    difference = im2double(f1) - im2double(f2); 
    difference_g = im2double(rgb2gray(f1)) - ...
                   im2double(rgb2gray(f2));     
    denoise = ones(3) / 9;
    difference_g_d = conv2(abs(difference_g), denoise, 'same');
    
    %Create binary mask of moving objects    
    mask = abs(difference_g_d) > noiseThreshold;
end