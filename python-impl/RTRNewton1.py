#!/usr/bin/env python
# coding: utf-8

# In[78]:


import autograd.numpy as anp
import autograd.numpy as anp
import pymanopt
import pymanopt.manifolds
import pymanopt.optimizers

import autograd.numpy as np
import time


def RTRNewton(X, y, z, gamma):
    time1 = time.time()
    (m, n) = X.shape
    Y = np.concatenate([0.5 * (gamma ** 0.5) * X, 0.5 * (gamma ** 0.5) * np.ones((m, 1))], axis=1)
    Lhat = np.concatenate([Y, 0.5 * z], axis=1)
    # Lend = 0.5 * z - y
    # A = np.dot(Lhat.T, Lhat)
    # b = np.dot(Lhat.T, Lend)
    # c = np.dot(Lend.T, Lend)

    dim = n + 2
    manifold = pymanopt.manifolds.Sphere(dim)

    @pymanopt.function.autograd(manifold)
    def cost(r):
        return np.linalg.norm((Lhat @ r).reshape(y.shape[0], 1) - y + z / 2) ** 2

    problem = pymanopt.Problem(manifold, cost)

    optimizer = pymanopt.optimizers.trust_regions.TrustRegions(verbosity=0)
    result = optimizer.run(problem)

    # print("Pymanopt solution:", result.point)
    time2 = time.time()
    return time2 - time1
