function [Ghn,Ghf] = Structure_representation (X,opt)
X = X';
N = size(X,1);
Ghn = zeros(N,N);
Gf = zeros(N,N);
[idx,distX] = knnsearch(X,X,'k',N);
Kn = opt.kmax;
Kf = opt.kF;
idx_att = idx(:,1:Kn);
idx_rep = fliplr(idx(:,end-Kf+1:end));
%%
for i = 1:N
    id_x = idx_att(i,1:Kn);
    di = distX(i,1:Kn);
    k=Kn-1;
    W = (di(Kn)-di)/(k*di(Kn)-sum(di(1:k))+eps);
    Ghn(i,id_x) = W;
end
for i = 1:N
    id_x = idx_rep(i,1:Kf);
    Gf(i,id_x) = 1;
end
Ghn=sparse(Ghn);
Ghn = Ghn + Ghn * Ghn + Ghn* Ghn* Ghn;
Gf = sparse(Gf);
Ghf = Gf + Ghn*Gf + Gf*Ghn;
Ghf = full(Ghf);
Ghf = sign(Ghf);
Ghn = full(Ghn);
for i = 1:N
    sumRe = sum(Ghf(i,:));
    Ghf(i,:) = Ghf(i,:)/sumRe;
    sumSp = sum(Ghn(i,:));
    Ghn(i,:) = Ghn(i,:)/sumSp;
end