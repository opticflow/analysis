clc; clear all; close all;
% Example for the method 'patternMatch'.
%   Florian Raudies, 01/18/2016, Palo Alto, CA.

flwFile         = sprintf('../Data/SleepingBag/Flow/Flw%05d.mat', 1);
[Dx, Dy]        = loadFlow(flwFile);
[nY, nX]        = size(Dx);
[DxP, DyP, opt] = flowPattern(nX, nY, struct()); % Defaults.
opt.matchType   = 'normReLuInnerProduct';
[M1, opt]       = computePatternMatch(Dx, Dy, DxP, DyP, opt);
opt.matchType   = 'normInnerProduct';
[M2, opt]       = computePatternMatch(Dx, Dy, DxP, DyP, opt); 
opt.PatternType = {'cw','exp','con','ccw','left','down','right','up'};
[DxP, DyP, opt] = flowPattern(nX, nY, opt);
opt.matchType   = 'opponent';
[M3, opt]       = computePatternMatch(Dx, Dy, DxP, DyP, opt);
Img             = flowToImage(Dx, Dy);

figure('Position',[50 50 1100 700]);
subplot(2,3,1:3); imshow(Img); title('Flow');
subplot(2,3,4); bar(M1); set(gca,'XTickLabel',opt.PatternType);
                ylabel('Match Score'); xlabel('Pattern Type');
                title('Normalized, rectified, inner product');
subplot(2,3,5); bar(M2); set(gca,'XTickLabel',opt.PatternType);
                ylabel('Match Score'); xlabel('Pattern Type');
                title('Normalized inner product');
subplot(2,3,6); bar(M3); set(gca,'XTickLabel',opt.PatternType);
                ylabel('Match Score'); xlabel('Pattern Type');
                title('Opponent');