clc; clear all; close all;
%   Florian Raudies, 12/29/2015, Palo Alto, CA.

% Compile the c code.
mex -v medianValue.c imagelib.c

% Setup and run the test cases.
th      = eps*10^2;
Num     = [1 2 5 8 9 10^3 10^5];
nNum    = length(Num);
nPassed = 0;
nFailed = 0;
for iNum = 1:nNum,
    nNum        = Num(iNum);
    Data        = randn(nNum,1);
    shouldBe    = medianValue(Data); 
    is          = median(Data);
    difference  = abs(shouldBe-is);
    fprintf('Testing data with %d values.\n',nNum);
    if difference<th,
        nPassed = nPassed + 1;
        fprintf('  Test PASSED!\n');
    else
        nFailed = nFailed + 1;
        fprintf('  Test FAILED!\n');
    end
end
fprintf('%d tests passed and %d tests failed.\n',nPassed,nFailed);
assert(nFailed==0,'%d tests failed.\n',nFailed);

% ALL PASSED 01/07/2016 FR