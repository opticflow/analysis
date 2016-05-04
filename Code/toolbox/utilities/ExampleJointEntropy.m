clc; clear all; close all;
% Example for the method 'jointEntropy'.
%   Florian Raudies, 01/18/2016, Palo Alto, CA.
sigmaX      = 3;
sigmaY      = 7;
nDataX      = 10^5;
nDataY      = 10^5;
DataX       = sigmaX*randn(nDataX,1);
DataY       = sigmaY*randn(nDataY,1);
BinX        = linspace(-2*sigmaX, 2*sigmaX, 4*sigmaX);
BinY        = linspace(-2*sigmaY, 2*sigmaY, 4*sigmaY);
eIs         = jointEntropy(DataX, DataY, BinX, BinY);
eShouldBe   = 1+log2(2*pi) + 0.5*log2(sigmaX^2 * sigmaY^2);
fprintf(' Entropy is %e and should be %e.\n', eIs, eShouldBe);
