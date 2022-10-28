import os

import numpy as np

DATA_PATH = "../datasets/"


def get_time_real(X: np.array, y: np.array, z: np.array,
                  gamma: float, size_range: np.array,
                  sdp: bool=True, socp: bool=True,
                  ltr: bool=True, rtr: bool=True):
    m, n = X.shape
