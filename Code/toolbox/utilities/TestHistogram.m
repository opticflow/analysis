clc; clear all; close all;
% Tests the computation of histogram data.
%   Florian Raudies, 01/18/2016, Palo Alto, CA.

testCase(1).Data                = [1 2 5 7 9 10];
testCase(1).Bin                 = [1 3 9];
testCase(1).HistogramShouldBe   = [1 1 3 1]';

testCase(2).Data                = [1 1 2 2 4 4 5 5 10 10 10];
testCase(2).Bin                 = [1 2.5 5 7.5];
testCase(2).HistogramShouldBe   = [2 2 4 0 3]';

nTestCase = length(testCase);
nFailed = 0;
nPassed = 0;
for iTestCase = 1:nTestCase,
    fprintf('Working on test case %d of %d.\n', iTestCase, nTestCase);
    Data                = testCase(iTestCase).Data;
    Bin                 = testCase(iTestCase).Bin;
    HistogramShouldBe   = testCase(iTestCase).HistogramShouldBe;
    HistogramIs         = histogram(Data,Bin);
    if any(HistogramShouldBe~=HistogramIs),
        nFailed = nFailed + 1;
        fprintf(' Test FAILED!\n');
    else
        nPassed = nPassed + 1;
        fprintf(' Test PASSED!\n');
    end
end
fprintf('%d tests passed and %d tests failed.\n',nPassed,nFailed);
assert(nFailed==0,'%d tests failed.\n',nFailed);

% ALL PASSED 01/18/2016 FR