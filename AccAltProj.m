function [ L, S ] = AccAltProj( D, r, para )
% [ L, S ] = AccAltProj( D, r, para )
% 
% Inputs:
% D : Observed matrix. Sum of underlying low rank matrix and underlying
%     sparse matrix. 
% r : Target rank of underlying low rank matrix.
% params : parameters for the algorithm
%   .max_iter : Maximum number of iterations. (default 50)
%   .tol : Desired Frobenius norm error. (default 1e-5)
%   .beta_init : Parameter for thresholding at initialization. (default
%                4*beta)
%   .beta : Parameter for thresholding. (default 1/(2*nthroot(m*n,4)))
%   .gamma : Parameter for desired convergence rate. Value should between 0
%            and 1. Turn this parameter bigger will slow the convergence
%            speed but tolerate harder problem, such as higher p, r or mu. 
%            (default 0.5)   
%   .trimming : Determine whether using trimming step. (default false)
%   .mu : Incoherence of underlying low rank matrix. Input can be in format
%         of .mu = mu_max, or .mu = [mu_U, mu_V]. (default 5) 
%
% Outputs:
% L : Estimated low rank component of D.
% S : Estimated sparse component of D.
%
%
% Please cite the paper "Accelerated Alternating Projections for Robust
% Principal Component Analysis" if you find this code helpful
%
%
% Warning: We found this code runs very slow on AMD CPUs with earlier 
% versions of Matlab. For best experience, please use the code on Intel CPU
% based computer, and update Matlab to the latest version.
%
%
% By
% HanQin Cai          , Jian-Feng Cai, Ke Wei
% caesar-cai@uiowa.edu, jfcai@ust.hk , kewei@fudan.edu.cn

addpath PROPACK;
[m,n]     = size(D);
norm_of_D = norm(D, 'fro'); 

%% Default/Inputed parameters
max_iter  = 100;
tol       = 1e-5;
beta      = 1/(2*nthroot(m*n,4));
beta_init = 4*beta;
gamma     = 0.5;    
mu        = 5;     
trimming  = false;


if isfield(para,'beta_init') 
    beta_init = para.beta_init; 
    fprintf('beta_init = %f set.\n', beta_init);
else
    fprintf('using default beta_init = %f.\n', beta_init);
end
if isfield(para,'beta') 
    beta = para.beta; 
    fprintf('beta = %f set.\n', beta);
else
    fprintf('using default beta = %f.\n', beta);
end
if isfield(para,'gamma') 
    gamma = para.gamma; 
    fprintf('gamma = %f set.\n', tol);
else
    fprintf('using default gamma = %f.\n', gamma);
end
if isfield(para,'mu') 
    mu = para.mu; 
    fprintf('mu = [%f,%f] set.\n', mu(1), mu(end));
else
    fprintf('using default mu = [%f,%f].\n', mu, mu);
end
if isfield(para,'trimming') 
    trimming = para.trimming; 
    if  trimming
        fprintf('trimming = true set.\n');
    else 
        fprintf('trimming = false set.\n');
    end
else
    fprintf('using default trimming = False.\n');
end
if isfield(para,'max_iter')   
    max_iter = para.max_iter; 
    fprintf('max_iter = %d set.\n', max_iter);
else
    fprintf('using default max_iter = %d.\n', max_iter);
end
if isfield(para,'tol')        
    tol= para.tol; 
    fprintf('tol = %e set.\n', tol);
else
    fprintf('using default tol = %e.\n', tol);
end 

err    = -1*ones(max_iter,1);
timer  = -1*ones(max_iter,1);

tic;
%%Initilization 
zeta = beta_init * lansvd(D,1); 
% When S is sparse enough, we may store S as a sparse matrix. This can save
% some memory and computing when problem size is large.
S = wthresh( D ,'h',zeta);    

[U,Sigma,V] = lansvd(D - S, r, 'L');
L = U * Sigma * V';

zeta = beta * Sigma(1,1); 
S = wthresh( D - L ,'h',zeta);

init_timer = toc;
init_err = norm(D-L-S,'fro')/norm_of_D;
fprintf('Init: error: %e, timer: %f \n', init_err, init_timer);


%% Main Alogorithm
for t = 1 : max_iter
    tic;
    %% Trim
    if trimming
        [U, V] = trim( U, Sigma(1:r,1:r), V, mu(1), mu(end) );
    end

    %% update L
    Z = D - S;
    % These 2 QR can be computed parallelly
    [Q1,R1] = qr(Z' * U - V * ((Z * V)' * U), 0);
    [Q2,R2] = qr(Z  * V - U * ( U' * Z  * V), 0);

    M = [ U'*Z*V, R1'            ;
          R2    , zeros(size(R2)); ];
    [U_of_M, Sigma, V_of_M] = svd(M,'econ');
    % These 2 matrices multiplications can be computed parallelly
    U = [U, Q2] * U_of_M(:,1:r);
    V = [V, Q1] * V_of_M(:,1:r);
    L = U * Sigma(1:r,1:r) * V';

    %% update S
    zeta = beta * (Sigma(r+1,r+1) + (gamma^t)*Sigma(1,1));
    S = wthresh( D - L ,'h',zeta);

    %% Stop Condition
    err(t) = norm (D - L - S,'fro')/norm_of_D;
    timer(t) = toc;
    if err(t) < tol  
        fprintf('Total %d iteration, final error: %e, total time without init: %f , with init: %f\n======================================\n', t, err(t), sum(timer(timer>0)),sum(timer(timer>0))+init_timer);
        return;
    else
        fprintf('Iteration %d: error: %e, timer: %f \n', t, err(t), timer(t));
    end
end


fprintf('Maximum iterations reached, final error: %e.\n======================================\n', err(t));
end

