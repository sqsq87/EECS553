import math
from timeit import default_timer as timer

import cvxopt
import numpy as np
from cvxopt import solvers
from scipy.sparse import csr_matrix


def socp(X, y, z, gamma):
    # timer for matrix operations
    timer_matrx = timer()
    m, n = X.shape
    X_tilde = np.hstack((X, np.ones(m, 1)))
    A = np.block([
        [X_tilde.T @ X_tilde, X_tilde.T @ (z - y), -X_tilde.T @ y],
        [(z - y).T @ X_tilde, np.linalg.norm(z - y) ** 2, -(z - y).T @ y],
        [-y.T @ X_tilde, -y.T @ (z - y), y.T @ y]
    ])
    B = csr_matrix(([1] * 4, ([n + 1, n + 1, n + 2, n + 2], [n + 1, n + 2, n + 1, n + 2])),
                   shape=(n + 3, n + 3))
    C = csr_matrix(([1 / gamma] * (n + 1) + [-0.5] * 2,
                    (list(range(n + 1)) + [n + 1, n + 2], list(range(n + 1)) + [n + 2, n + 1])),
                   shape=(n + 3, n + 3))
    # Define matrices used later in the socp
    A11_bar = np.block([
        [A[:n + 1, :n + 1],
         1 / math.sqrt(gamma) * (A[:n + 1, n + 1] - A[:n + 1, n + 2])],
        [1 / math.sqrt(gamma) * (A[:n + 1, n + 1] - A[:n + 1, n + 2]).T,
         1 / gamma * (A[n + 1, n + 1] + A[n + 2, n + 2] - 2 * A[n + 1, n + 2])]
    ])
    A12_bar = np.vstack((A[:n + 1, n + 1] + A[:n + 1, n + 2],
                         1 / math.sqrt(gamma) * (A[n + 1, n + 1] - A[n + 2, n + 2])))
    A22_bar = A[n + 1, n + 1] + A[n + 2, n + 2] + 2 * A[n + 1, n + 2]
    timer_matrx -= timer()

    # timer for eigenvalue decomposition
    timer_eig = timer()
    d, V = np.linalg.eig(A11_bar)
    timer_eig -= timer()

    # prepare start
    timer_solve = timer()
    b = V.T @ A12_bar
    assert len(b) == n + 2

    # Prepare for SOCP
    # linear inequality constraints
    G0 = -csr_matrix(([1] * (n + 2) + [-4] + [-1] * (n + 3) + [1] * (n + 2),  # values
                      (list(range(n + 2)) + [n + 2] * (n + 4) + list(range(n + 3, 2 * n + 5)),  # row index
                       [1] * (n + 2) + list(range(n + 4)) + list(range(2, n + 4))  # col index
                       )), shape=(2 * n + 5, n + 4))
    h0 = np.vstack((gamma * d, A22_bar, np.zeros(n + 2)))
    # cone inequality constraints
    Gk, hk = [], []
    for j in range(n + 2):
        wj = np.zeros(n + 4)
        wj[1], wj[j + 2] = -1 / gamma, 1
        vj = np.zeros(n + 4)
        vj[1], vj[j + 2] = 1 / gamma
        Gk_ = -0.5 * np.vstack((vj.T, wj.T, np.zeros(n + 4)))
        assert Gk_.ndim == 2 and Gk_.shape == (3, n + 4)
        hk_ = np.array((0.5 * d[j], 0.5 * d[j], b[j]))
        assert hk_.ndim == 1 and hk_.shape == 3
        Gk.append(cvxopt.matrix(Gk_))
        hk.append(cvxopt.matrix(hk_))
    # objective coefficient
    c_ = np.zeros(n + 4)
    c_[0] = -1
    c_ = cvxopt.matrix(c_)
    sol = solvers.socp(c=c_, Gl=G0, hl=h0, Gq=Gk, hq=hk)

    # recover the results
    D = A - sol['x'][0] * B + sol['x'][1] * C
    w_star = np.linalg.solve(D[:, :-1], -D[:, -1])[:-1]
    timer_solve -= timer()

    optval = np.linalg.norm(
        (z @ (w_star.T @ w_star) / gamma + X_tilde @ w_star) / (1 + w_star.T @ w_star / gamma) - y) ** 2
    return w_star, optval, timer_matrx + timer_eig + timer_solve
