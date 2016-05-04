function ImgRGB = histogramEqualize(ImgRGB, H)
% histogramEqualize
%   ImgRGB  - Color image with RGB color space.
%   H       - Histogram that is used for equalization.
%
% RETURN
%   ImgRGB  - Equalized color image.

%   Florian Raudies, 04/24/2016, Palo Alto, CA.

ImgYCBCR    = rgb2ycbcr(ImgRGB);
ImgY        = squeeze(ImgYCBCR(:,:,1));
CDF         = cumsum(H);
minCDF      = min(CDF);
ImgYEq      = uint8(1 + floor((CDF(ImgY)-minCDF)/(numel(ImgY)-minCDF)*255));
ImgYCBCR(:,:,1) = ImgYEq;
ImgRGB      = ycbcr2rgb(ImgYCBCR);
