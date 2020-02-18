function [ mu, kappa ] = get_mu_kappa( L, r )

if exist('.\PROPACK', 'dir')==7
    addpath PROPACK;
    [U,Sig,V] = lansvd(L, r ,'L');
else
    [U,Sig,V] = svds(L, r);
end

[m,n] = size(L);

mu_U = max(sum(U.^2,2)*m/r);
mu_V = max(sum(V.^2,2)*n/r);

%mu = max(mu_U,mu_V);
mu = [mu_U, mu_V];
kappa=Sig(1,1)/Sig(r,r);
end

