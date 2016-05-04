function [e, opt] = computeEntropyForImage(Img, opt)
% computeEntropyForImage
%   Img     - Image data, typically has dimensions: nY x nX.
%   opt     - Structure with fields:
%             * ScaleOrSize - Rescale the image by this factor or resize 
%                             the image to the size [row column].
%             * nBin        - Number of bins to compute the entropy. The 
%                             default is 11 bins.
%             *	Range       - [minValue, maxValue] Minimum and maximum 
%                             value used when computing the mutual 
%                             information. If no Range is given the default 
%                             values minValue equals minimum of all values 
%                             and maxValue equals the maximum of all values.
% RETURNs
%   e       - Entropy in bits.
%   opt     - Structure that contains the parameter information for the 
%             computation of the entropy inluding the additional fields:
%             * nY  - Rows of the image.
%             * nX  - Columns of the image.
%
% DESCRIPTION
%   Computes the entropy in bits (base two) for the image using the 
%   specified range and number of bins.
%

%   Florian Raudies, 01/18/2016, Palo Alto, CA.
if isfield(opt,'ScaleOrSize'),  ScaleOrSize = opt.ScaleOrSize;
else                            ScaleOrSize = 1;                        end
if isfield(opt,'nBin'),         nBin        = opt.nBin;
else                            nBin        = 11;                       end
if isfield(opt,'Range'),        Range       = opt.Range;
else                            Range       = [min(Img(:)) max(Img(:))];end

if length(ScaleOrSize) > 1 || ScaleOrSize(1) ~= 1,
    Img = imresize(Img, ScaleOrSize);
end

[nY, nX]    = size(Img);
Range       = double(Range);
opt.nY      = nY;
opt.nX      = nX;
opt.nBin    = nBin;
opt.Range   = Range;
opt.Bin     = linspace(Range(1), Range(2), nBin);
e           = entropy(Img(:), opt.Bin);
