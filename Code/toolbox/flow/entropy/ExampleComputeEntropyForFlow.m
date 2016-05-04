clc; clear all; close all;
% Example for the method 'computeEntropyForFlow'.
%   Florian Raudies, 01/19/2016, Palo Alto, CA.

[Dx, Dy] = loadFlow(sprintf('../Data/SleepingBag/Flow/Flw%05d.mat',1));
opt.nBin = 11;
[E, opt] = computeEntropyForFlow(Dx, Dy, opt);
figure;
subplot(2,2,1); 
    imshow(Dx,[]); title(sprintf('Dx entropy = %2.2f bits', E(1)));
subplot(2,2,2); 
    imshow(Dy,[]); title(sprintf('Dy entropy = %2.2f bits', E(2)));
subplot(2,2,3:4); 
    imshow([Dx Dy],[]); title(sprintf('Dx-Dy joint entropy = %2.2f bits', E(3)));
