import math
from timeit import default_timer as timer
import cvxopt
import numpy as np
from cvxopt import matrix, sparse, solvers
from scipy.sparse import csr_matrix


def socp(X, y, z, gamma):
    # Set solver options.
    solvers.options["show_progress"] = False
    solvers.options["abstol"] = 1e-6
    solvers.options["reltol"] = 1e-6
    solvers.options["feastol"] = 1e-6

    # timer for matrix operations
    timer_matrx = timer()
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
                   shape=(n + 3, n + 3))
    C = csr_matrix(([1 / gamma] * (n + 1) + [-0.5] * 2,
                    (list(range(n + 1)) + [n + 1, n + 2], list(range(n + 1)) + [n + 2, n + 1])),
                   shape=(n + 3, n + 3))

    # Define matrices used later in the socp
    A11_bar12 = 1 / math.sqrt(gamma) * (A12 - A13)
    A11_bar = np.block([
        [A11, A11_bar12],
        [A11_bar12.T, 1 / gamma * (A22 + A33 - 2 * A23)]
    ])
    A12_bar = np.vstack((A12 + A13,
                         1 / math.sqrt(gamma) * (A22 - A33)))
    A22_bar = A22 + A33 + 2 * A23
    timer_matrx = timer() - timer_matrx

    # timer for eigenvalue decomposition
    timer_eig = timer()
    d, V = np.linalg.eigh(A11_bar)
    timer_eig = timer() - timer_eig

    # prepare start
    timer_solve = timer()
    b = V.T @ A12_bar

    # Prepare for SOCP
    # linear inequality constraints
    G0 = -csr_matrix(([1. / gamma] + [-4.] + [-1.] * (n + 3) + [1.] * (n + 2),  # values
                      ([0] + [1] * (n + 4) + list(range(2, n + 4)),  # row index
                       [1] + list(range(n + 4)) + list(range(2, n + 4))  # col index
                       )), shape=(n + 4, n + 4))
    G0 = matrix(G0.T.toarray().tolist())
    h0 = np.concatenate((np.min(d, keepdims=True),
                         A22_bar[0], np.zeros(n + 2)), axis=0)
    h0 = matrix(h0.tolist())

    # cone inequality constraints
    Gk, hk = [], []
    for j in range(n + 2):
        wj = np.zeros(n + 4)
        wj[1], wj[j + 2] = 1 / gamma, 1
        vj = np.zeros(n + 4)
        vj[1], vj[j + 2] = 1 / gamma, -1
        Gk_ = -0.5 * np.array([wj, vj, np.zeros(n + 4)])
        assert Gk_.shape == (3, n + 4)
        assert b[j].shape == (1,)
        hk_ = np.array((0.5 * d[j], 0.5 * d[j], b[j][0]))
        Gk.append(matrix(Gk_.T.tolist()))
        hk.append(matrix(hk_.tolist()))

    # objective coefficient
    c_ = np.zeros(n + 4, dtype=np.double)
    c_[0] = -1.0
    c_ = matrix(c_.tolist())
    sol = solvers.socp(c=c_, Gl=G0, hl=h0, Gq=Gk, hq=hk, solver="mosek")
    timer_solve = timer() - timer_solve

    # recover the results
    optval = -sol["primal objective"]
    mu = np.array(sol['x']).squeeze()[0]
    lambda_ = np.array(sol['x']).squeeze()[1]
    D = A - mu * B + lambda_ * C
    w_star = np.linalg.lstsq(D[:, :-1], -D[:, -1], rcond=None)[0]
    w_star = np.array(w_star).squeeze()[:n + 1]
    # optval = np.linalg.norm((z * (w_star.T @ w_star) / gamma + X_tilde @ w_star) /
    #                         (1 + w_star.T @ w_star / gamma) - y) ** 2

    return w_star, optval, (timer_eig, timer_matrx + timer_eig + timer_solve)
