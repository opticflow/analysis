function [S, H, B] = computeSpeedHistogram(Dx, Dy, opt)
% computeSpeedHistogram
%   Dx  - Horizontal flow component in units of pixel/frame.
%   Dy  - Vertical flow component in units of pixel/frame.
%   opt - Structure with fields:
%         * aperture    - 'None' (default) or 'Circular'. For the circular 
%                         aperture a circle is placed around the center of 
%                         the image plane and only the measurements within 
%                         that circle are returned. The remaining 
%                         measurements of speeds within the image plane are 
%                         set to NaN.
%         * nBin        - Number of bins for the histogram. The default 
%                         value is 11.
%         * Range       - Range [minValue, maxValue] for minimum and 
%                         maximum speed in deg/secs. If no range is 
%                         given then the minValue = minimum of all speeds 
%                         and maxValue = maximum of all speeds.
%         * normalize   - Normalize the histogram (default 1).
%         * fps         - Frames per second.
%         * hFoV        - Horizontal field of view in RAD.
%
% RETURNs
%   S - Image speed in pixels/frame. This matrix has the same size as the 
%       matrices 'Dx' / 'Dy'.
%   H - Histogram for the image speeds within the aperture. The counts are 
%       within the interval Range and the centers for the bins are returned
%       in B.
%   B - Centers of the bins in pixel/frame.
%
% DESCRIPTION
%   Computes the histogram of the flow speeds for the optic flow.

%   Florian Raudies, 02/14/2016, Palo Alto, CA.

% Comute the image speeds.
S = hypot(Dx, Dy);

% Apply the circular aperture if specified.
if isfield(opt,'aperture'), aperture = opt.aperture;
else                        aperture = 'None';              end
if ~isfield(opt,'fps'),
    error('Matlab:IO','Field fps for frames per second is required!');
end
if ~isfield(opt,'hFoV'),
    error('Matlab:IO','Horizontal field of view hFoV is required!');
end
fps     = opt.fps;
hFoV    = opt.hFoV;
[nY nX] = size(Dx);

S = S * hFoV*(180/pi)/nX * fps;% (pixel/frame) x (deg/pixel) x (frame/sec) = deg/sec

if strcmp(aperture,'Circular'),
    [Y, X] = ndgrid(1:nY,1:nX);
    Y = Y - nY/2;
    X = X - nX/2;
    r = min(nY, nX)/2;
    S(hypot(X,Y)>r) = NaN;
end

if isfield(opt,'nBin'),     nBin = opt.nBin;
else                        nBin = 11;                      end
if isfield(opt,'normalize'),normalize = opt.normalize;
else                        normalize = 1;                  end
if isfield(opt,'Range'),    Range = opt.Range;
else                        Range = [min(S(:)) max(S(:))];  end

% Setup the bins and compute the histogram.
Bin     = linspace(Range(1), Range(2), nBin+1);
[H, B]  = histogram(S(~isnan(S)), Bin);
H       = H(2:end-1); % Remove the ends.
if normalize,
    H = H/(eps + sum(H));
end


