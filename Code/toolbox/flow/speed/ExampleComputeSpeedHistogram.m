clc; clear all; close all;
% Example for the method 'computeSpeedHistogram'.
%   Florian Raudies, 02/14/2016, Palo Alto, CA.

[Dx, Dy]        = loadFlow(sprintf(...
                    '../Data/SleepingBag/Flow/Flw%05d.mat',1));
opt.nBin        = 17;
opt.aperture    = 'Circular';
opt.hFoV        = 170/180*pi; % degrees per pixel.
opt.fps         = 59.94; % frames per second.
[S, H, B]       = computeSpeedHistogram(Dx, Dy, opt);

figure('Position',[50 50 800 500]);
subplot(2,2,1); imshow(Dx,[]); title('Dx');
subplot(2,2,2); imshow(Dy,[]); title('Dy');
subplot(2,2,3); imshow(S,[]); title('S');
subplot(2,2,4); bar(B,H); xlabel('speed (pixel/frame)'); 
                ylabel('normalized count'); title('Historam');