import autograd.numpy as anp
import autograd.numpy as np
import pymanopt
import pymanopt.manifolds
import pymanopt.optimizers
import math
from timeit import default_timer as timer


def rtr(X, y, z, gamma):
    m, n = X.shape
    x_tilde = np.hstack((0.5 * np.sqrt(gamma) * X, 0.5 * np.ones((m, 1))))
    l_hat = np.hstack((x_tilde, 0.5 * z))
    y_tilde = 0.5 * z - y
    h = l_hat.T @ l_hat  # H
    g = l_hat.T @ y_tilde
    p = y_tilde.T @ y_tilde

    dim = n + 2
    manifold = pymanopt.manifolds.Sphere(dim)

    @pymanopt.function.autograd(manifold)
    def cost(r):
        return np.linalg.norm((l_hat @ r).reshape(y.shape[0], 1) - y + z / 2) ** 2

    problem = pymanopt.Problem(manifold, cost)

    optimizer = pymanopt.optimizers.trust_regions.TrustRegions(verbosity=0)
    result = optimizer.run(problem)

    # Reconstruct the results
    recon_timer = timer()
    r_star = result.point
    w_tilde = r_star[:-1]
    alpha_tilde = r_star[-1]
    alpha = (1 + alpha_tilde) / (1 - alpha_tilde)
    w = 0.5 * math.sqrt(gamma) * (alpha + 1) * w_tilde
    recon_timer = timer() - recon_timer

    optval = r_star.T @ (h @ r_star) + 2 * g.T @ r_star + p

    return w, optval, result.time + recon_timer
