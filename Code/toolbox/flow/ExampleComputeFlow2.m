clc; clear all; close all;
% Example for the usage of the method 'computeFlow2'.
%   Florian Raudies, 01/16/2016, Palo Alto, CA.

% Read the input files.
imgFile = '../Data/SleepingBag/Image/Img%05d.png';
Img1    = double(rgb2gray(imread(sprintf(imgFile, 1))))/255;
Img2    = double(rgb2gray(imread(sprintf(imgFile, 2))))/255;
% Compute the flow.
[Dx, Dy] = computeFlow2(Img1, Img2, struct());
Img = flowToImage(Dx,Dy);

% Dislpay the images and computed flow.
figure;
subplot(3,2,1); imshow(Img1); title('Image 1');
subplot(3,2,2); imshow(Img2); title('Image 2');
subplot(3,2,3); imshow(Dx,[]); title('Dx');
subplot(3,2,4); imshow(Dy,[]); title('Dy');
subplot(3,2,5:6); imshow(Img); title('Dx/Dy as color');
