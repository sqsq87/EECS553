from timeit import default_timer as timer
import numpy as np
from cvxopt import matrix, solvers
from scipy.sparse import csr_matrix


def sdp(X, y, z, gamma):
    # Set solvers options. This is for the purpose
    # of more robust comparison with socp.
    solvers.options["show_progress"] = False
    solvers.options["abstol"] = 1e-6
    solvers.options["reltol"] = 1e-6
    solvers.options["feastol"] = 1e-6

    # Set timer for the entire process.

    time1 = timer()
    m, n = X.shape
    X_tilde = np.hstack((X, np.ones((m, 1))))
    A11 = X_tilde.T @ X_tilde
    A12 = X_tilde.T @ (z - y)
    A13 = -X_tilde.T @ y
    A22 = np.linalg.norm(z - y) ** 2
    A23 = -(z - y).T @ y
    A33 = y.T @ y
    A = np.block([
        [A11, A12, A13],
        [A12.T, A22, A23],
        [A13.T, A23.T, A33]
    ])

    B = csr_matrix(([1] * 4, ([n + 1, n + 1, n + 2, n + 2], [n + 1, n + 2, n + 1, n + 2])),
                   shape=(n + 3, n + 3)).toarray()
    C = csr_matrix(([1 / gamma] * (n + 1) + [-0.5] * 2,
                    (list(range(n + 1)) + [n + 1, n + 2], list(range(n + 1)) + [n + 2, n + 1])),
                   shape=(n + 3, n + 3)).toarray()
    B_flt = B.reshape(1, -1)
    C_flt = -C.reshape(1, -1)

    h = [matrix(A.tolist())]
    c = matrix([-1., 0.])  # minimization problem should use negative weight
    sol = solvers.sdp(c, Gs=[matrix([B_flt.tolist()[0], C_flt.tolist()[0]])],
                      hs=h)

    time2 = timer()

    # retrieve the optimal values
    optval = -sol["primal objective"]
    mu = np.array(sol['x']).squeeze()[0]
    lambda_ = np.array(sol['x']).squeeze()[1]
    D = A - mu*B + lambda_*C
    w_star = np.linalg.lstsq(D[:, :-1], -D[:, -1], rcond=None)[0]
    w_star = np.array(w_star).squeeze()[:n+1]

    return w_star, optval, time2 - time1

