clc; clear all; close all;
% This runs all the tests for the functions used within the estimation
% method of optic flow and finally it runs the test for the method that
% esimtates optic flow.
%
%   Florian Raudies, 01/07/2016, Palo Alto, CA.

TestImfilter2
TestPermuteN
TestSelectKth
TestMedian
TestMedianFilter2
TestPeakFilter2
TestImresize2
TestNearestInterp2
TestCubicInterp2
TestDiffWarp2
TestTvL1PrimalDual2
TestComputeFlow2
clc;

fprintf('ALL TESTS PASSED!\n');

% ALL PASSED 01/12/2016 FR