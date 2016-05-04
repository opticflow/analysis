clc; clear all; close all;
% Example for the method 'histogram'.
%   Florian Raudies, 01/18/2016, Palo Alto, CA.
nData           = 10^5;
muForData       = 2;
sigmaForData    = 4;
nBin            = 17;
Data            = sigmaForData*randn(nData,1) - muForData;
Bin             = linspace(-3*sigmaForData,3*sigmaForData,nBin);
[H, B]          = histogram(Data, Bin);
figure; bar(B,H(2:end-1));