function F = nearestInterp2Matlab(X,Y, Z, Xi,Yi)

assert(size(X,2)>1 && all(size(X)==size(Y)) ...
    && size(Xi,2)>1 && all(size(Xi)==size(Yi)), ...
    'All inputs X, Y, Xi, and Yi must be 2D!');
assert(ndims(Z)==2, 'Matrix Z must be 2D!');

nY = size(Y,1);
nX = size(X,2);

X   = X(1,:)';
Xi  = Xi(1,:)';
Y   = Y(:,1);
Yi  = Yi(:,1);

nYi = size(Yi,1);
nXi = size(Xi,1);

U = 1 + (Xi - X(1))/(X(end) - X(1))*(nX-1);
V = 1 + (Yi - Y(1))/(Y(end) - Y(1))*(nY-1);

F = zeros(nYi, nXi);

for iYi = 1:nYi,
    v = V(iYi);
    for iXi = 1:nXi,
        u = U(iXi);
        if (v < 0.5) || (v >= (nY + 0.5)) || (u < 0.5) || (u >= (nX + 0.5)),
            F(iYi,iXi) = NaN;
        else
            iX = round(u);
            iY = round(v);
            F(iYi,iXi) = Z(iY,iX);
        end
    end
end