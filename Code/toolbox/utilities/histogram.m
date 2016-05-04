function [H, B] = histogram(Data, Bin)
% histogram
%   Data    - Data to calculate the histogram for.
%   Bin     - Edges of bins.
%
% RETURN
%   H       - Histogram data with nBin+1 entries.
%   B       - Centers of internal bins with nBin-1 entries.
%
% DESCRIPTION
%   This function computes the histogram for data with the bining:
%   H(1)        H(2)                    H(nBin+1)
%   Data<=Bin(1) Bin(1)<Data<=Bin(2) ... Bin(nBin)<Data
%
%   B = 0.5*(Bin(2:end)+Bin(1:end-1))
%
%   For most applications the data H(2:end-1) is enough and is displayed,
%   e.g. by
%   figure; bar(B,H(2:end-1));
%

%   Florian Raudies, 01/18/2016, Palo Alto, CA.
nBin    = length(Bin);
H       = zeros(nBin+1,1);
Data    = sort(Data(:), 1, 'ascend');
nData   = length(Data);
iBin    = 1;
Bin     = [Bin inf];
n       = 0;
iData   = 1;
while iData <= nData,
    if (Data(iData) <= Bin(iBin)),
        n       = n + 1;
        iData   = iData + 1;
    else
        H(iBin) = n;
        n       = 0;
        iBin    = iBin + 1;
    end
end
H(iBin) = n;
B = 0.5*(Bin(1:end-2) + Bin(2:end-1));
