clc; clear all; close all;
% Test for the method 'jointEntropy'.
% Note that the entropy for the multivariate normal distribution 
% (N(sigmaX, muX=0), N(sigmaY, muY=0)) is:
%
%   k/2*log2(2 pi) + 1/2*log2(|Sigma|) for k = 2 
%
%               / sigmaX^2 0        \
%   and Sigma = \ 0        sigmaY^2 /
%
% See, e.g. https://en.wikipedia.org/wiki/Multivariate_normal_distribution.
%   Florian Raudies, 01/18/2016, Palo Alto, CA.

th          = 0.3; % Fairly high.
SigmaX      = 1:15;
SigmaY      = 1:15;
nSigmaX     = length(SigmaX);
nSigmaY     = length(SigmaY);
nDataX      = 10^5;
nDataY      = 10^5;
DataX       = randn(nDataX,1);
DataY       = randn(nDataY,1);
nTestCase   = nSigmaX * nSigmaY;
nPassed     = 0;
nFailed     = 0;
for iTestCase = 1:nTestCase,
    fprintf('Working on test case %d of %d.\n',iTestCase,nTestCase);
    [iSigmaY iSigmaX] = ind2sub([nSigmaY nSigmaX], iTestCase);
    sigmaX      = SigmaX(iSigmaX);
    sigmaY      = SigmaY(iSigmaY);
    BinX        = linspace(-2*sigmaX, 2*sigmaX, 4*sigmaX);
    BinY        = linspace(-2*sigmaY, 2*sigmaY, 4*sigmaY);
    eIs         = jointEntropy(sigmaX*DataX, sigmaY*DataY, BinX, BinY);
    eShouldBe   = 1+log2(2*pi) + 0.5*log2(sigmaX^2 * sigmaY^2);
    
    fprintf(' Entropy is %e and should be %e.\n',eIs,eShouldBe);
    if abs(eIs-eShouldBe)<th,
        nPassed = nPassed + 1;
        fprintf('  Test PASSED!\n');
    else
        nFailed = nFailed + 1;
        fprintf('  Test FAILED!\n');
    end
end
fprintf('%d tests passed and %d tests failed.\n',nPassed,nFailed);
assert(nFailed==0,'%d tests failed.\n',nFailed);

% ALL PASSED 01/18/2016 FR