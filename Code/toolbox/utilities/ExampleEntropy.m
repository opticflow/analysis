clc; clear all; close all;
% Example for the method 'entropy' using a normal distribution.
%   Florian Raudies, 01/18/2016, Palo Alto, CA.
sigma       = 5;
nData       = 10^7;
Data    	= sigma*randn(nData,1);
Bin         = linspace(-2*sigma, 2*sigma, 4*sigma);
eIs         = entropy(Data, Bin);
eShouldBe   = 0.5*log2(2*pi*exp(1)*sigma^2);
fprintf(' Entropy is %e and should be %e.\n',eIs,eShouldBe);