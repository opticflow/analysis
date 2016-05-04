clc; clear all; close all;
% Tests the method jointHistogram.
%   Florian Raudies, 01/18/2016, Palo Alto, CA.

Y                   = [1 2 5 7 9 10];
X                   = [1 1 2 2 4 4 5 5 10 10 10];
BinY                = [1 3 9];
BinX                = [1 2.5 5 7.5];
HistogramShouldBe   = [2 2 4 0 3; ...
                       2 2 4 0 3; ...
                       6 6 12 0 9; ...
                       2 2 4 0 3];
[HistogramIs, Bx, By] = jointHistogram(X, Y, BinX, BinY);

if any(any(HistogramIs~=HistogramShouldBe)),
    fprintf('Test FAILED!\n');
else
    fprintf('Test PASSED!\n');
end

% ALL PASSED 01/18/2016 FR