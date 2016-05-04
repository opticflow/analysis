function [Dx, Dy, Dt, P] = tvL1PrimalDual2Matlab(I1, I2, Dx, Dy, Dt, P, ...
                                                 lambda, nWarp, nIter)
                                      
% Save flow variables.
DxOld = Dx;
DyOld = Dy;
DtOld = Dt;
% Set parameters.
TAU     = 1/sqrt(8); % 1/stepwidth
SIGMA   = 1/sqrt(8);
%EPS_XY  = 0;
%EPS_T   = 0;
GAMMA   = 0.02;
% Iterate over the number of warps.
for iWarp = 1:nWarp
    Dx0 = Dx;
    Dy0 = Dy;
    % Warping of image I2 toward I1.
    [Ix, Iy, It] = diffWarp2Matlab(I1, I2, Dx0, Dy0);
    % Compute the gradient.
    GradSq = max(1e-09, Ix.^2 + Iy.^2 + GAMMA*GAMMA);
    
    % fprintf('GradSq = \n\n');
    % printMatrix(GradSq);
    
    % All iterations.
    for iter = 0:nIter-1
        % *****************************************************************
        % DUAL Problem.
        % *****************************************************************
        % Compute the partial derivatives for Dx, Dy, and Dt.
        u_x = dxPlus(DxOld);
        u_y = dyPlus(DxOld);
        v_x = dxPlus(DyOld);
        v_y = dyPlus(DyOld);
        w_x = dxPlus(DtOld);
        w_y = dyPlus(DtOld);
        % Update the dual variable.
        P(1,:,:) = (P(1,:,:) + SIGMA*shiftdim(u_x,-1)); % /(1 + SIGMA*EPS_XY);
        P(2,:,:) = (P(2,:,:) + SIGMA*shiftdim(u_y,-1)); % /(1 + SIGMA*EPS_XY);
        P(3,:,:) = (P(3,:,:) + SIGMA*shiftdim(v_x,-1)); % /(1 + SIGMA*EPS_XY);
        P(4,:,:) = (P(4,:,:) + SIGMA*shiftdim(v_y,-1)); % /(1 + SIGMA*EPS_XY);
        P(5,:,:) = (P(5,:,:) + SIGMA*shiftdim(w_x,-1)); % /(1 + SIGMA*EPS_T);
        P(6,:,:) = (P(6,:,:) + SIGMA*shiftdim(w_y,-1)); % /(1 + SIGMA*EPS_T);
        % Re-project to |pu| <= 1.
        Reproject = max(1, sqrt(sum(P(1:4,:,:).^2,1)));
        P(1,:,:) = P(1,:,:)./Reproject;
        P(2,:,:) = P(2,:,:)./Reproject;
        P(3,:,:) = P(3,:,:)./Reproject;
        P(4,:,:) = P(4,:,:)./Reproject;
        Reproject = max(1, sqrt(sum(P(5:6,:,:).^2,1)));
        P(5,:,:) = P(5,:,:)./Reproject;
        P(6,:,:) = P(6,:,:)./Reproject;
        % *****************************************************************
        % PRIMAL problem.
        % *****************************************************************
        % Calculate divergence.
        DivDx = dxMinus(squeeze(P(1,:,:))) + dyMinus(squeeze(P(2,:,:)));
        DivDy = dxMinus(squeeze(P(3,:,:))) + dyMinus(squeeze(P(4,:,:)));
        DivDt = dxMinus(squeeze(P(5,:,:))) + dyMinus(squeeze(P(6,:,:)));        
        % Store the old Dx, Dy, and Dt.
        DxOld = Dx;
        DyOld = Dy;
        DtOld = Dt;
        % Update the Dx, Dy, and Dt.
        Dx = Dx + TAU*(DivDx);
        Dy = Dy + TAU*(DivDy);
        Dt = Dt + TAU*(DivDt);        
        % Proxy for operator of Dx, Dy, Dt.
        Rho = It + (Dx-Dx0).*Ix + (Dy-Dy0).*Iy + GAMMA*Dt;
        Index1 = Rho      < - TAU*lambda*GradSq;
        Index2 = Rho      >   TAU*lambda*GradSq;
        %Index3 = abs(Rho) <=  TAU*lambda*GradSq;
        Index3 = ~(Index1 | Index2);
        % Update for all Index1 values.
        Dx(Index1) = Dx(Index1) + TAU*lambda*Ix(Index1);
        Dy(Index1) = Dy(Index1) + TAU*lambda*Iy(Index1);
        Dt(Index1) = Dt(Index1) + TAU*lambda*GAMMA;
        % Update for all Index2 values.
        Dx(Index2) = Dx(Index2) - TAU*lambda*Ix(Index2);
        Dy(Index2) = Dy(Index2) - TAU*lambda*Iy(Index2);
        Dt(Index2) = Dt(Index2) - TAU*lambda*GAMMA;
        % Update for all Index3 values.
        Dx(Index3) = Dx(Index3) - Rho(Index3).*Ix(Index3)./GradSq(Index3);
        Dy(Index3) = Dy(Index3) - Rho(Index3).*Iy(Index3)./GradSq(Index3);
        Dt(Index3) = Dt(Index3) - Rho(Index3).*GAMMA./GradSq(Index3);
        % Update old variables.
        DxOld = 2*Dx - DxOld;
        DyOld = 2*Dy - DyOld;
        DtOld = 2*Dt - DtOld;
    end    
    % Filter that smoothers strong outliers.
    Dx = peakFilter2Matlab(Dx);
    Dy = peakFilter2Matlab(Dy);
end

% Operators that compute the partial differentials.
function Dx = dxPlus(Z)
    Dx = [Z(:,2:end), Z(:,end)] - Z;
function Dy = dyPlus(Z)
    Dy = [Z(2:end,:); Z(end,:)] - Z;
function Dx = dxMinus(Z)
    Dx = [Z(:,1:end-1), zeros(size(Z,1),1)] ...
       - [zeros(size(Z,1),1), Z(:,1:end-1)];
function Dy = dyMinus(Z)
    Dy = [Z(1:end-1,:); zeros(1,size(Z,2))] ...
       - [zeros(1,size(Z,2)); Z(1:end-1,:)];
