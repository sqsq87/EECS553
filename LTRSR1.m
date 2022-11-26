function [w, optval, toctime] = LTRSR1(X, y, z, gamma, varargin)
%test the following least-squares problem:
%min || Lr +b||^2   subject to ||r||=1

% whether hyper-tune three possible methods and take the fastest
% 0: lstrs with the best performance among all possible eigen-solvers
% 1: lstrs with Arnoldi process
% 2: gltr process
hypertune = 2;

tstart = tic;
% GTRS with Krylov
[m, ~] = size(X);Y = [0.5 * sqrt(gamma) * X, 0.5 * sqrt(gamma) * ones(m,1)];
Lhat = [Y, 0.5 * z]; Lend = 0.5 * z - y;
A = Lhat' * Lhat; b = Lhat' * Lend;c = Lend' * Lend; 
H = 2 * A;
g = 2 * b;
preparetime = toc(tstart);

if hypertune == 0

    % nested Lanczos method with arpackc method
    temp0 = tic;
    [r1, ~] = lstrs(H, g, 1);
    solvertime = toc(temp0);
    % 
    
    % nested Lanczos method with tcheigs methd
    temp1 = tic;
    [r2, ~] = lstrs(H, g, 1, @tcheigs_lstrs_gateway);
    solvertime = min(solvertime, toc(temp1));
    %
    
    % nested Lanczos method with Matlab built-in method
    temp2 = tic;
    [r3, ~] = lstrs(H, g, 1, @eig_gateway);
    solvertime = min(solvertime, toc(temp2));
    %
    
    % should not include recovery
    toctime = preparetime + solvertime;
    
    % test if all solutions yields smallest result
    rlist = [r1, r2, r3];
    optvallist = [0, 0, 0];
    wlist = zeros(size(r1, 1) - 1, 3);
    for i = 1:3
        % process of recovery
        r = rlist(:, i);
        w_tilde = r(1:end-1); alpha_tilde = r(end);
        alpha = (1+alpha_tilde)/(1-alpha_tilde); 
        wlist(:, i) = 0.5 * sqrt(gamma) * (alpha + 1) * w_tilde;
        
        % calculate optimal function value
        optvallist(i) = (r' * A ) * r + 2 * b' * r + c;
    end
    
    [optval, minidx] = min(optvallist);
    w = wlist(:, minidx);

elseif hypertune == 1

    % nested Lanczos method with arpackc method
    temp0 = tic;
    [r, ~] = lstrs(H, g, 1);
    solvertime = toc(temp0);

    % should not include recovery
    toctime = preparetime + solvertime;
  
    % process of recovery
    w_tilde = r(1:end-1); alpha_tilde = r(end);
    alpha = (1+alpha_tilde)/(1-alpha_tilde); 
    w = 0.5 * sqrt(gamma) * (alpha + 1) * w_tilde;
    
    % calculate optimal function value
    optval = (r' * A ) * r + 2 * b' * r + c;
    
else
    % nested Lanczos method with arpackc
    n = size(H, 1);
    temp0 = tic;
    [r, ~] = krylov(H, [], eye(n), g, 1, 1e-10, n, "gltr");
    solvertime = toc(temp0);

    % should not include recovery
    toctime = preparetime + solvertime;
  
    % process of recovery
    w_tilde = r(1:end-1); alpha_tilde = r(end);
    alpha = (1+alpha_tilde)/(1-alpha_tilde); 
    w = 0.5 * sqrt(gamma) * (alpha + 1) * w_tilde;
    
    % calculate optimal function value
    optval = (r' * A ) * r + 2 * b' * r + c;
end

end  % end function


