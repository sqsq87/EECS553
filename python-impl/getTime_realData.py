import random
import numpy as np
from sdp import sdp


def getTime_realData(X, y, z, gamma, size_range):
    fold = 10
    num_size = len(size_range)
    random.seed(2021)
    (m, n) = X.shape
    ssdp_yes = 1
    time_ssdp = np.zeros(num_size)
    time_ssdp_std = np.zeros(num_size)
    optval_ssdp = np.zeros(num_size)
    w_ssdp = np.zeros((n + 1, fold))
    for i in range(num_size):
        print('Starting a dataset size of ' + str(i));
        timessdp = np.zeros(fold)
        optvalssdp = np.zeros(fold)
        m_curr = size_range[i]
        for idx in range(fold):
            ridx = random.sample(range(m), m_curr)
            if ssdp_yes:
                print('Doing ssdp')
                timessdp[idx] = sdp(X[ridx], y[ridx], z[ridx], gamma);
        time_ssdp[i] = np.mean(timessdp)
        time_ssdp_std[i] = np.std(timessdp)
    return (time_ssdp, time_ssdp_std)





