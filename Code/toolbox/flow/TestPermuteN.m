clc; clear all; close all;
%   Florian Raudies, 12/29/2015, Palo Alto, CA.

% Compile the c function.
mex -v permuteN.c imagelib.c

% Setup and run the test cases.
th          = eps;
nTestCase   = 11;
TestCase    = cell(nTestCase,1);
TestCase{1}.DimData     = [5 1];
TestCase{1}.NewOrder    = [1 2];
TestCase{2}.DimData     = [6 15];
TestCase{2}.NewOrder    = [2 1];
TestCase{3}.DimData     = [8 8];
TestCase{3}.NewOrder    = [1 2];
TestCase{4}.DimData     = [8 8];
TestCase{4}.NewOrder    = [2 1];
TestCase{5}.DimData     = [7 9 20];
TestCase{5}.NewOrder    = [2 3 1];
TestCase{6}.DimData     = [8 4 2];
TestCase{6}.NewOrder    = [1 3 2];
TestCase{7}.DimData     = [5 3 2 4];
TestCase{7}.NewOrder    = [2 1 3 4];
TestCase{8}.DimData     = [7 7 3 4];
TestCase{8}.NewOrder    = [2 3 4 1];
TestCase{9}.DimData     = [9 2 3 7 4];
TestCase{9}.NewOrder    = [2 1 3 5 4];
TestCase{10}.DimData    = [9 2 5 4 3];
TestCase{10}.NewOrder   = [1 2 3 4 5];
TestCase{11}.DimData    = [2 5 6 4 3 9];
TestCase{11}.NewOrder   = [2 3 1 6 5 4];
nPassed = 0;
nFailed = 0;
for iTestCase = 1:nTestCase,
    DimData     = TestCase{iTestCase}.DimData;
    NewOrder    = TestCase{iTestCase}.NewOrder;
    fprintf('Testing data with dimensions: ');
    fprintf('%d, ',DimData);
    fprintf('\n');
    fprintf('With the permutation is: ');
    fprintf('%d, ',NewOrder);
    fprintf('\n');
    Data        = randn(DimData);
    ShouldBe    = permute(Data, NewOrder);
    Is          = permuteN(Data, NewOrder);
    difference  = max(abs(ShouldBe(:)-Is(:)));
    if (difference<th),
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