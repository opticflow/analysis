function printMatrix(X)

[nY, nX] = size(X);
for iY = 1:nY,
    for iX = 1:nX,
        fprintf('%e, ', X(iY,iX))
    end
    fprintf('\n');
end