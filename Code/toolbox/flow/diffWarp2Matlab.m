function [Ix, Iy, It] = diffWarp2Matlab(I1, I2, Dx, Dy)
    [nH nW] = size(I1);
    [Idy Idx] = ndgrid(1:nH, 1:nW);

    Idxx = Idx + Dx;
    Idyy = Idy + Dy;
    Boundary = (Idxx > nW-1) | (Idxx < 2) | (Idyy > nH-1) | (Idyy < 2);

    Idxx = max(1,min(nW,Idxx));
    Idxm = max(1,min(nW,Idxx-0.5));
    Idxp = max(1,min(nW,Idxx+0.5));

    Idyy = max(1,min(nH,Idyy));
    Idym = max(1,min(nH,Idyy-0.5));
    Idyp = max(1,min(nH,Idyy+0.5));

    I2Warped = interp2(I2,Idxx,Idyy,'cubic');
    I2xWarped = interp2(I2,Idxp,Idyy,'cubic') - interp2(I2,Idxm,Idyy,'cubic');
    I2yWarped = interp2(I2,Idxx,Idyp,'cubic') - interp2(I2,Idxx,Idym,'cubic');

    % Use average to improve the accuracy.
    Ix = I2xWarped;
    Iy = I2yWarped;
    It = I2Warped  - I1;

    % Handle boundary.
    Ix(Boundary) = 0;
    Iy(Boundary) = 0;
    It(Boundary) = 0;