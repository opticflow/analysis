clc; clear all; close all;
% Example for the method jointHistogram.
%   Florian Raudies, 01/18/2016, Palo Alto, CA.
sigmaX      = 5;
sigmaY      = 7;
muX         = -2;
muY         = 3;
nX          = 1*10^4;
nY          = 2*10^4;
nBinX       = 13;
nBinY       = 15;
X           = sigmaX * randn(nX,1) - muX;
Y           = sigmaY * randn(nY,1) - muY;
BinX        = linspace(-2*sigmaX,2*sigmaX,nBinX);
BinY        = linspace(-2*sigmaY,2*sigmaY,nBinY);
[H, Bx, By] = jointHistogram(X, Y, BinX, BinY);
figure; imagesc(H(2:end-1,2:end-1),'XData',Bx,'YData',By); colormap gray;

