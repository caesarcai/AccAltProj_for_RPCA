clear;
close all;
n = 2500;
m = n;
r = 5;
p = 0.4;   
c = 1;   

%% Generate a RPCA problem
A_generater = randn(m,r);
B_generater = randn(r,n);
L_true = A_generater * B_generater;
norm_of_L_true = norm(L_true,'fro');

S_supp_idx = randsample(m*n, round(p*m*n), false);
S_range = c*mean(mean(abs(L_true)));
S_temp = 2*S_range*rand(m,n)-S_range; 
S_true = zeros(m, n);
S_true(S_supp_idx) = S_temp(S_supp_idx);                       
norm_of_S_true = norm(S_true,'fro');

D = L_true + S_true;

%% RieAltProj without trim,, using all default parameters
[L1, S1] = AccAltProj( D, r, '' );
L1_err = norm(L1-L_true,'fro')/norm(L_true,'fro')


%% RieAltProj with trim
para.mu        = 1.1*get_mu_kappa(L_true,r);  
para.beta_init = r*sqrt(para.mu(1)*para.mu(end))/(sqrt(m*n));
para.beta      = r*sqrt(para.mu(1)*para.mu(end))/(4*sqrt(m*n));
para.trimming  = true;
para.tol       = 1e-5;
para.gamma     = 0.5;
para.max_iter  = 100;
[L2, S2] = AccAltProj( D, r, para );
L2_err = norm(L2-L_true,'fro')/norm(L_true,'fro')

    
    