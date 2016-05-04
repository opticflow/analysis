function F = cubicInterp2Matlab(X,Y, Z, Xi,Yi)

assert(ndims(X)==2 && all(size(X)==size(Y)) ...
    && ndims(Xi)==2 && all(size(Xi)==size(Yi)), ...
    'All inputs X, Y, Xi, and Yi must be 2D!');
assert(ndims(Z)==2, 'Matrix Z must be 2D!');

nY  = size(Y,1);
nX  = size(X,2);
nYi = size(Yi,1);
nXi = size(Xi,2);
S   = 1 + (Xi - X(1))/(X(end) - X(1))*(nX-1);
T   = 1 + (Yi - Y(1))/(Y(end) - Y(1))*(nY-1);
C   = zeros(nY+2,nX+2);

% The four edges.
for iY = 1:nY,
    C(1+iY,1) = 3*Z(iY,1) - 3*Z(iY,2) + Z(iY,3);
    C(1+iY,nX+2) = 3*Z(iY,nX) - 3*Z(iY,nX-1) + Z(iY,nX-2);
end
for iX = 1:nX,
    C(1,1+iX) = 3*Z(1,iX) - 3*Z(2,iX) + Z(3,iX);
    C(nY+2,1+iX) = 3*Z(nY,iX) - 3*Z(nY-1,iX) + Z(nY-2,iX);
end
% The four courners.
% C(-1,-1)      = 3*C(0,-1) - 3*C(1,-1) + C(2,-1)
C(1,1)          = 3*C(2,1) - 3*C(3,1) + C(4,1); % +2,+2
% C(N+1,-1)     = 3*C(N,-1) - 3*C(N-1,-1) + C(N-2,-1)
C(nY+2,1)       = 3*C(nY+1,1) - 3*C(nY,1) + C(nY-1,1); % +1,+2
% C(-1,M+1)     = 3*C(0,M+1) - 3*C(1,M+1) + C(2,M+1)
C(1,nX+2)       = 3*C(2,nX+2) - 3*C(3,nX+2) + C(4,nX+2); %+2,+1
% C(N+1,M+1)    = 3*C(N,M+1) - 3*C(N-1,M+1) + C(N-2,M+1)
C(nY+2,nX+2)    = 3*C(nY+1,nX+2) - 3*C(nY,nX+2) + C(nY-1,nX+2); % +1,+1
C(2:(1+nY),2:(1+nX)) = Z;

F = zeros(nYi,nXi);
for iYi = 1:nYi,
    for iXi = 1:nXi,
        t = T(iYi,iXi);
        s = S(iYi,iXi);
        
        if s<1 || s>nX || t<1 || t>nY,
            F(iYi,iXi) = NaN;
        else
            iY = floor(t);
            iX = floor(s);

            t = t - floor(t);
            s = s - floor(s);

            if iY == nY,
                iiY = nY;
                t = t + 1;
            else
                iiY = iY + 1;
            end
            
            if iX == nX,
                iiX = nX;
                s = s + 1;
            else
                iiX = iX + 1;
            end
            
            % t0 = ((2-t).*t-1).*t;
            % t1 = (3*t-5).*t.*t+2;
            % t2 = ((4-3*t).*t+1).*t;
            % t(:) = (t-1).*t.*t;            
            t0 = ((2-t)*t-1)*t;
            t1 = (3*t-5)*t*t+2;
            t2 = ((4-3*t)*t+1)*t;
            t3 = (t-1)*t*t;
            
            % s0 = (((2-s).*s-1).*s);
            % s1 = ((3*s-5).*s.*s+2);
            % s2 = (((4-3*s).*s+1).*s);
            % s3 = ((s-1).*s.*s);
            s0 = ((2-s)*s-1)*s;
            s1 = (3*s-5)*s*s+2;
            s2 = ((4-3*s)*s+1)*s;
            s3 = (s-1)*s*s;
            
            % Grab c00-c33, the 16 values.
            c00 = C(iiY-1,iiX-1);
            c10 = C(iiY+0,iiX-1);
            c20 = C(iiY+1,iiX-1);
            c30 = C(iiY+2,iiX-1);
            
            c01 = C(iiY-1,iiX+0);
            c11 = C(iiY+0,iiX+0);
            c21 = C(iiY+1,iiX+0);
            c31 = C(iiY+2,iiX+0);
            
            c02 = C(iiY-1,iiX+1);
            c12 = C(iiY+0,iiX+1);
            c22 = C(iiY+1,iiX+1);
            c32 = C(iiY+2,iiX+1);
            
            c03 = C(iiY-1,iiX+2);
            c13 = C(iiY+0,iiX+2);
            c23 = C(iiY+1,iiX+2);
            c33 = C(iiY+2,iiX+2);
            
%             % Columns first.
%             temp0 = (s0*c00 + s1*c01 + s2*c02 + s3*c03)/2;
%             temp1 = (s0*c10 + s1*c11 + s2*c12 + s3*c13)/2;
%             temp2 = (s0*c20 + s1*c21 + s2*c22 + s3*c23)/2;
%             temp3 = (s0*c30 + s1*c31 + s2*c32 + s3*c33)/2;
%             
%             % Rows second.
%             F(iYi,iXi) = (t0*temp0 + t1*temp1 + t2*temp2 + t3*temp3)/2;

            % Rows first.
            temp0 = (t0*c00 + t1*c10 + t2*c20 + t3*c30);
            temp1 = (t0*c01 + t1*c11 + t2*c21 + t3*c31);
            temp2 = (t0*c02 + t1*c12 + t2*c22 + t3*c32);
            temp3 = (t0*c03 + t1*c13 + t2*c23 + t3*c33);
            
            % Columns second.
            F(iYi,iXi) = (s0*temp0 + s1*temp1 + s2*temp2 + s3*temp3)/4;
        end
    end
end
