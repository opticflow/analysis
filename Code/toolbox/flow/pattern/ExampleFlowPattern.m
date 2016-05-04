clc; clear all; close all;
% Example for method 'flowPattern'.
%   Florian Raudies, 01/18/2016, Palo Alto, CA.

% Constructs expansion, contraction, clockwise, counter clockwise, and 
% laminar flow patterns.
nX = 320; % pixels
nY = 240; % pixels
[DxP, DyP, opt] = flowPattern(nX, nY, struct()); % Use default values.
nP = size(DxP,3);
figure('Name','8 Flow Patterns','Position',[50 50 800 400]);
for iP = 1:nP,
	Dx  = squeeze(DxP(:,:,iP));
	Dy  = squeeze(DyP(:,:,iP));
    Img = flowToImage(Dx, Dy);
	patternType = opt.PatternType{iP};
	subplot(2,4,iP); imshow(Img); title(sprintf('%s',patternType));
end

% Constructs expansion, contraction, clockwise, and counter 
% clockwise patterns for nine positions.
nX = 32; % pixels
nY = 24; % pixels
opt.PatternType     = {'exp','con','cw','ccw'};
opt.PatternPosition = [	-0.5 -0.5; 0 -0.5; 0.5 -0.5; ...
                        -0.5 0; 0 0; 0.5 0; ...
                        -0.5 0.5; 0 0.5; 0.5 0.5];
[DxP, DyP]  = flowPattern(nX, nY, opt);
nPattern    = length(opt.PatternType);
nPosition   = length(opt.PatternPosition);
nP          = size(DxP,3); % There are 4 x 9 = 36 patterns.
figure('Name','36 Flow Patterns','Position',[50 50 1200 600]);
for iP = 1:nP,
	Dx  = squeeze(DxP(:,:,iP));
	Dy  = squeeze(DyP(:,:,iP));
    Img = flowToImage(Dx, Dy);
	[iPosition, iPattern]   = ind2sub([nPosition nPattern], iP);
	patternType             = opt.PatternType{iPattern};
	PatternPosition         = opt.PatternPosition(iPosition,:);
	subplot(4,9,iP); imshow(Img);
	title(sprintf('%s @(%1.1f,%1.1f)',...
		patternType,PatternPosition(1),PatternPosition(2)));
end
