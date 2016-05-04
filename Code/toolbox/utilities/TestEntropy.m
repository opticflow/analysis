clc; clear all; close all;
% Test the method 'entropy'.
% Note that the entropy for the normal distribution N(sigma,mu=0) is
%   1/2*log2(2 pi exp(1) sigma^2)
% See, e.g. https://en.wikipedia.org/wiki/Normal_distribution.
%
%   Florian Raudies, 01/18/2016, Palo Alto, CA.

th          = 0.5; % Fairly high.
Sigma       = 1:20;
nData       = 10^7;
Data        = randn(nData,1);
nTestCase   = length(Sigma);
nPassed     = 0;
nFailed     = 0;
for iTestCase = 1:nTestCase,
    fprintf('Working on test case %d of %d.\n',iTestCase,nTestCase);
    sigma       = Sigma(iTestCase);
    Bin         = linspace(-2*sigma, 2*sigma, 4*sigma);
    eIs         = entropy(sigma*Data, Bin);
    eShouldBe   = 0.5*log2(2*pi*exp(1)*sigma^2);
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