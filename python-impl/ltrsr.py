import numpy as np
from scipy.optimize._trlib import get_trlib_quadratic_subproblem
from timeit import default_timer as timer

KrylovQP = get_trlib_quadratic_subproblem(tol_rel_i=1e-8, tol_rel_b=1e-6)


# Compute the lstrs solution of the least squared problem
# using krylov subspace methods. The problem configuration
# is of the form min q(r) = r'Hr + 2g'r with trust region
# radius delta = 1
def lstrs(H: np.array, g: np.array, delta: float = 1,
          tol_rel_i: float = 1e-8, tol_rel_b: float = 1e-6):
    jacob = 2 * g  # Jacobian of q(r)
    hess = 2 * H  # Hessian of q(r) (H is symmetric)
    krylov_prob = get_trlib_quadratic_subproblem(tol_rel_i, tol_rel_b)
    r_star, active = krylov_prob(x=0, fun=lambda x: 0, jac=lambda x: jacob,
                                 hess=lambda x: hess).solve(delta)
    # Resconstruct the solution for the original problem


def ltrsr(X, y, z, gamma, time=True, delta=1, tol_rel_i=1e-8, tol_rel_b=1e-6):
    m, n = X.shape
    x_tilde = np.hstack(0.5*np.sqrt(gamma)*X, 0.5*np.ones(m, 1))
    l_hat = np.hstack(x_tilde, 0.5*z)
    y_tilde = 0.5*z - y
    h = l_hat.T @ l_hat  # H
    g = l_hat.T @ y_tilde
    p = y_tilde.T @ y_tilde

    # time the process if specified
    start = timer()
    krylov_prob = get_trlib_quadratic_subproblem(tol_rel_i, tol_rel_b)
    r_star, active = krylov_prob(x=0, fun=lambda x: 0, jac=lambda x: 2*g,
                                 hess=lambda x: None, hessp=lambda x, t: 2*h@t)
    w_tilde = r_star[:-1]
    alpha_tilde = r_star[-1]
    alpha = (1 + alpha_tilde) / (1 - alpha_tilde)
    w = 0.5 * np.sqrt(gamma) * (alpha + 1) * w_tilde
    # end the timer
    end = timer()

    # calculate the optimal function value
    optval = r_star.T @ (h @ r_star) + 2 * g.T @ r_star + p
    return w, optval, end - start



