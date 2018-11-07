function [ U_out, V_out ] = trim( U, Sig, V, mu_U, mu_V )
[m,r]=size(U);
row_norm_square_U = sum(U.^2,2);
big_rows_U = row_norm_square_U > (mu_U*r/m);
U(big_rows_U,:) = bsxfun(@times,U(big_rows_U,:),((mu_U*r/m) ./ sqrt(row_norm_square_U(big_rows_U))));   %This is A in paper
%sum(big_rows_U)

[n,r]=size(V);
row_norm_square_V = sum(V.^2,2);
big_rows_V = row_norm_square_V > (mu_V*r/n);
V(big_rows_V,:) = bsxfun(@times,V(big_rows_V,:),((mu_V*r/n) ./ sqrt(row_norm_square_V(big_rows_V))));   %This is B in paper
%sum(big_rows_V)


% These 2 QR can be computed parallelly
[Q1,R1]=qr(U,0);
[Q2,R2]=qr(V,0);
[U_temp,Sig_out,V_temp]=svd(R1*Sig*R2','econ');
% These 2 matrices multiplications can be computed parallelly
U_out = Q1*U_temp;
V_out = Q2*V_temp;

end

