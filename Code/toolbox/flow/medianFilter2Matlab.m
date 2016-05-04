function F = medianFilter2Matlab(Z, I, type)
% Ensure that I is smaller than Z with the specified dimensions.
[nY, nX] = size(Z);
nKy = I(1);
nKx = I(2);
nHy = floor(nKy/2);
nHx = floor(nKx/2);

assert(nKy<=nY && nKx<nX,'Dimensions of kernel must be smaller than image!');
assert(strcmp(type,'symmetric'),'Type must be symmetric!');

V = zeros(nKy,nKx);
F = zeros(nY,nX);
% Implementation for symmetric boundary type.
for iY = 1 : nY,
    for iX = 1 : nX,
        for iKy = 1 : nKy,
            for iKx = 1 : nKx,
                iiY = iY + (iKy-1) - nHy;
                iiX = iX + (iKx-1) - nHx;
                if iiY<1,
                    iiY = -iiY + 1;
                end
                if iiY>nY,
                    iiY = nY - (iiY - nY) + 1;
                end
                if iiX<1,
                    iiX = -iiX + 1;
                end
                if iiX>nX,
                    iiX = nX - (iiX - nX) + 1;
                end
                V(iKy,iKx) = Z(iiY,iiX);
            end
        end
        %fprintf('\nRow: %d and column %d.\n',iY,iX);
        %V
        F(iY,iX) = selectKthMatlab(V(:),ceil(nKy*nKx/2));
    end
end
