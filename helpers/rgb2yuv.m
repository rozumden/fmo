function YUV=rgb2yuv(RGB,plot_flag)

R = RGB(:,:,1);
G = RGB(:,:,2);
B = RGB(:,:,3);

%Conversion Formula
Y = 0.299   * R + 0.587   * G + 0.114 * B;
U =128 - 0.168736 * R - 0.331264 * G + 0.5 * B;
V =128 + 0.5 * R - 0.418688 * G - 0.081312 * B;

YUV=cat(3,Y,U,V);
