function [w, optval ,time, nf, ng, nH] = RTRNewton1(X, y, z, gamma, varargin)
% GTRS with Remannian
tstart = tic;
[m,n] = size(X);Y = [0.5 * sqrt(gamma) * X, 0.5 * sqrt(gamma) * ones(m,1)];
Lhat = [Y, 0.5 * z]; Lend = 0.5 * z - y;
A = Lhat' * Lhat; b = Lhat' * Lend; c = Lend' * Lend;


d = n+2; p = 1;
rinitial.main = ones(d,p)/norm(ones(d,p));

detail_yes = 0;

fhandle = @(r) f(r,A,b,c);
gfhandle = @(r) grad(r,A,b);
Hesshandle = @(r,eta) Hess(r, eta, A);

SolverParams.method = 'RTRNewton';
SolverParams.IsCheckParams = 1;
SolverParams.Verbose = 3;
SolverParams.Min_Iteration = 1;
SolverParams.Min_Inner_Iter = 10;
SolverParams.IsCheckGradHess = 0;
SolverParams.Tolerance = 1e-12;
SolverParams.Accuracy = 1e-8;
SolverParams.Max_Iteration = 10000;
SolverParams.OutputGap = 1;
SolverParams.IsStopped = @IsStopped;

SolverParams.LineSearch_LS = 0;
SolverParams.LinesearchInput = @LinesearchInput;

ManiParams.IsCheckParams = 1;
ManiParams.name = 'Stiefel';
ManiParams.n = d;
ManiParams.p = p;
ManiParams.ParamSet = 4;
ManiParams.IsCheckParams = 1;
HasHHR = 0;

% use the function handles
temp0 = tic;
[rhat, fv, gfv, gfgf0, iter, nf, ng, nR, nV, nVp, nH, ComTime, funs, grads, times, eigHess] = DriverOPT(fhandle, gfhandle, Hesshandle, [], SolverParams, ManiParams, HasHHR, rinitial);
solvertime = toc(temp0););

fprintf('nf%d\tng%d\tnH:%d\t time%e\n',nf,ng,nH,ComTime);

% process of recovery
r = rhat.main(:);


w_tilde = r(1:end-1); alpha_tilde = r(end);
alpha = (1+alpha_tilde)/(1-alpha_tilde); 
w = 0.5 * sqrt(gamma) * (alpha + 1) * w_tilde;

time = toc(tstart);

% calculate optimal function value
optval = r' * A * r + 2 * b' * r + c;

end 

function output = IsStopped(x, funSeries, ngf, ngf0)
    output = ngf / ngf0 < 1e-5;
end

function [output, r] = f(r,A,b,c)
    r.Ar = A * r.main;
    output =  r.main(:)' * r.Ar(:) + 2 * b' * r.main(:) + c;
end

function [output, r] = grad(r,A,b)
    output.main = 2 * (r.Ar(:) + b);
end

function [output, r] = Hess(r, eta, A)
    output.main = 2 * A * eta.main;
end


