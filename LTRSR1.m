function [w, optval, toctime] = LTRSR1(X, y, z, gamma, varargin)
%test the following least-squares problem:
%min || Lr +b||^2   subject to ||r||=1

tstart = tic;
% GTRS with Krylov
[m,n] = size(X);Y = [0.5 * sqrt(gamma) * X, 0.5 * sqrt(gamma) * ones(m,1)];
Lhat = [Y, 0.5 * z]; Lend = 0.5 * z - y;
A = Lhat' * Lhat; b = Lhat' * Lend;c = Lend' * Lend; 
H = 2 * A;
g = 2 * b;

% nested Lanczos method
temp0 = tic;
[outinfo]=Krylov(inputs);% need to complement!!; any krylov subspace method.
solvertime = toc(temp0);
% 

% process of recovery
r = outinfo.opt;
w_tilde = r(1:end-1); alpha_tilde = r(end);
alpha = (1+alpha_tilde)/(1-alpha_tilde); 
w = 0.5 * sqrt(gamma) * (alpha + 1) * w_tilde;

toctime = toc(tstart);

% calculate optimal function value
optval = (r' * A ) * r + 2 * b' * r + c;



