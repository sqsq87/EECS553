function [w, optval ,time, nf, ng, nH] = RTRNewton2(X, y, z, gamma, varargin)
% GTRS with Remannian
tstart = tic;
[m,n] = size(X);Y = [0.5 * sqrt(gamma) * X, 0.5 * sqrt(gamma) * ones(m,1)];
Lhat = [Y, 0.5 * z]; Lend = 0.5 * z - y;
b = Lhat' * Lend;c = Lend' * Lend;

d = n+2; p = 1;
rinitial.main = ones(d,p)/norm(ones(d,p));


fhandle = @(r) f(r,Lhat,b,c);
gfhandle = @(r) grad(r,Lhat,b);
Hesshandle = @(r,eta) Hess(r, eta ,Lhat);

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

ManiParams.name = 'Stiefel';
ManiParams.n = d;
ManiParams.p = p;
ManiParams.ParamSet = 4;
ManiParams.IsCheckParams = 1;
HasHHR = 0;

% use the function handles
temp0 = tic;
[rhat, fv, gfv, gfgf0, iter, nf, ng, nR, nV, nVp, nH, ComTime, funs, grads, times, eigHess] = DriverOPT(fhandle, gfhandle, Hesshandle, [], SolverParams, ManiParams, HasHHR, rinitial);
solvertime = toc(temp0);

fprintf('nf:%d\tng:%d\tnH:%d\t time %e\n',nf,ng,nH,ComTime);

% recovery
r = rhat.main(:);

w_tilde = r(1:end-1); alpha_tilde = r(end);
alpha = (1+alpha_tilde)/(1-alpha_tilde); 
w = 0.5 * sqrt(gamma) * (alpha + 1) * w_tilde;


time = toc(tstart);


% calculate optimal function value
Lr = Lhat * r;
optval = Lr' * Lr + 2 * Lend' * Lr + c;
end 

function output = IsStopped(x, funSeries, ngf, ngf0)
    output = ngf / ngf0 < 1e-5;
end

function [output, r] = f(r,Lhat,b,c)
    r.Lr = Lhat * r.main;
    output =  r.Lr(:)' * r.Lr(:) + 2 * b' * r.main(:) + c;
end

function [output, r] = grad(r,Lhat,b)
    output.main = 2 * (Lhat' * r.Lr(:)+ b);
end

function [output, r] = Hess(r, eta, Lhat)
    output.main = 2 * Lhat'* (Lhat * eta.main);
end


