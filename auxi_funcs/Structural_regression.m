function [Z, delt,RelDiff] = Structural_regression(Y,Ghn,Ghf,opt)
% X----> Y
Niter = opt.Niter;
N_inner = opt.N_inner;
lambda = opt.lambda;
ss = 0.01;
varepsilon = 0.1;
mu = 0.4;
opt.SGDMw = 0.5;
[M,N] = size(Y);
delt = zeros(M,N);% initialization
W = zeros(M,N);% initialization
T_att  = 4 * LaplacianMatrix(Ghn);% 4*Lx
T_rep  = 4 * LaplacianMatrix(Ghf);
distY = (pdist2(Y',Y')).^2;
Z = Y;
for i=1:Niter
    distZ = (pdist2(Z',Z')).^2;
    value_att = sum(sum(Ghn.*distZ));
    value_RepS = sum(sum(Ghf./(varepsilon+distZ)));
    beta_temp(i) = value_att/(value_RepS+eps);
    if i > 10 && beta_temp(i) > beta_temp(i-1)
        break
    end
    beta = opt.beta * beta_temp(i);
    if i<= Niter/4
        beta = opt.beta * beta_temp(i)/10;
    elseif i<= Niter/2
        beta = opt.beta * beta_temp(i)/4;
    elseif i<= Niter*0.75
        beta = opt.beta * beta_temp(i)/2;
    else
        beta = opt.beta * beta_temp(i)/1;
    end
    delt_old = delt;
    v = 0;  
    for j = 1:N_inner
        distZ = (pdist2(Z',Z')).^2;
        T_rep  = 4 * LaplacianMatrix(Ghf./((varepsilon+distZ).^2));
        Tx = T_att - beta*T_rep;
        Gradient = Z*(Tx + mu * eye(N)) - (mu * (Y + delt) - W) ;
        v = opt.SGDMw*v + (1-opt.SGDMw)*Gradient;
        Z = Z - ss*v;
    end
    Q = Z - Y + W/mu;
    delt = deltUpdate(Q,lambda/mu,21);% delt update£» 1---> L1 norm; 21---> L21 norm
    W = W + mu * (Z - Y - delt); % W update
    RelDiff(i) = norm(delt - delt_old,'fro')/norm(delt,'fro');
    if i > 3 && RelDiff(i) < 1e-2
        break
    end
end
