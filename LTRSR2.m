function [w, optval, toctime] = LTRSR2(X, y, z, gamma, varargin)
%test the following least-squares problem:
%min || Lr +b||^2   subject to ||r||=1

% hyper parameter
hypertune = 2;

tstart = tic;

% GTRS with Krylov
[m, ~] = size(X);Y = [0.5 * sqrt(gamma) * X, 0.5 * sqrt(gamma) * ones(m,1)];
Lhat = [Y, 0.5 * z]; Lend = 0.5 * z - y;
b = Lhat' * Lend; c = Lend' * Lend; 
g = 2 * b;

preparetime = toc(tstart);
if hypertune == 0

    % nested Lanczos method with arpackc method
    temp0 = tic;
    [r1, ~] = lstrs(@func_handle, g, 1);
    solvertime = toc(temp0);
    % 
    
    % nested Lanczos method with tcheigs methd
    temp1 = tic;
    [r2, ~] = lstrs(@func_handle, g, 1, @tcheigs_lstrs_gateway);
    solvertime = min(solvertime, toc(temp1));
    %
    
    % nested Lanczos method with Matlab built-in method
    temp2 = tic;
    [r3, ~] = lstrs(@func_handle, g, 1, @eig_gateway);
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
        optval = ((r' * Lhat') * Lhat ) * r + 2 * b' * r + c;
    end
    
    [optval, minidx] = min(optvallist);
    w = wlist(:, minidx);

elseif hypertune == 1

    % nested Lanczos method with arpackc method
    temp0 = tic;
    [r, ~] = lstrs(@func_handle, g, 1);
    solvertime = toc(temp0);

    % should not include recovery
    toctime = preparetime + solvertime;
  
    % process of recovery
    w_tilde = r(1:end-1); alpha_tilde = r(end);
    alpha = (1+alpha_tilde)/(1-alpha_tilde); 
    w = 0.5 * sqrt(gamma) * (alpha + 1) * w_tilde;
    
    % calculate optimal function value
    optval = ((r' * Lhat') * Lhat ) * r + 2 * b' * r + c;
    
else
    % nested Lanczos method with arpackc method
    n = size(Lhat, 2);
    temp0 = tic;
    [r, ~] = krylov([], Lhat, eye(n), g, 1, 1e-10, n, "gltr");
    solvertime = toc(temp0);

    % should not include recovery
    toctime = preparetime + solvertime;
  
    % process of recovery
    w_tilde = r(1:end-1); alpha_tilde = r(end);
    alpha = (1+alpha_tilde)/(1-alpha_tilde); 
    w = 0.5 * sqrt(gamma) * (alpha + 1) * w_tilde;
    
    % calculate optimal function value
    optval = ((r' * Lhat') * Lhat ) * r + 2 * b' * r + c;
end

% nested function for quadratic term
function [w] = func_handle(v, varargin)
    w = 2*(Lhat'*(Lhat*v));
end

end  % end function
