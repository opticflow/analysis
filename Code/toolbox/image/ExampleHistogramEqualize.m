clc; clear all; close all;
% Example for the method 'histogramEqualize'.
%   Florian Raudies, 04/24/2016, Palo Alto, CA.

imgFile     = '../Data/HistogramEqualization/036NII_00054.png';
ImgRGB      = imread(imgFile);
ImgYCBCR    = rgb2ycbcr(ImgRGB);
ImgY        = squeeze(ImgYCBCR(:,:,1));
[H, B]      = histogram(ImgY(:),linspace(0,255,255));
CDF         = cumsum(H);
minCDF      = min(CDF);
ImgYEq      = uint8(1 + floor((CDF(ImgY)-minCDF)/(numel(ImgY)-minCDF)*255));
[HEq, BEq]  = histogram(ImgYEq(:),linspace(0,255,255));
CDFEq       = cumsum(HEq);
ImgEq       = histogramEqualize(ImgRGB, H);

figure('Position',[50 50 900 400]);
subplot(2,3,1);
    imshow(ImgRGB); title('Input Image');
subplot(2,3,2);
    bar(B,H(2:end-1)); title('Histogram');
    xlabel('Gray Value');
    ylabel('Count');
subplot(2,3,3);
    bar(B,CDF(2:end-1)); title('CDF');
    xlabel('Gray Value');
    ylabel('Cumulative Count');
    
subplot(2,3,4);
    imshow(ImgEq); title('Equalized Image');
subplot(2,3,5);
    bar(B,HEq(2:end-1)); title('Histogram Equalized');
    xlabel('Gray Value');
    ylabel('Count');
subplot(2,3,6);
    bar(B,CDFEq(2:end-1)); title('CDF Equalized');
    xlabel('Gray Value');
    ylabel('Cumulative Count');