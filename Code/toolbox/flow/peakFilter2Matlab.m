function Z = peakFilter(Z)
    ZSmooth     = medfilt2(Z,[3 3],'symmetric');
    Replace     = abs(Z-ZSmooth) > mean(abs(ZSmooth(:)));
    Z(Replace)  = ZSmooth(Replace);