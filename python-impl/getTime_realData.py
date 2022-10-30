import random
import numpy as np
import pandas as pd
from tqdm import tqdm

from sdp import sdp
from socp import socp
from ltrsr import ltrsr
from rtr import rtr


def getTime_realData(X, y, z, gamma, size_range,
                     methods_bool: dict, fold: int = 10):
    num_size = len(size_range)
    random.seed(2021)
    (m, n) = X.shape

    # Initialize experiment record, including time and optval
    column_name = ["ssdp_mean", "ssdp_std", "socp_mean", "socp_std",
                   "socp_eig_mean", "socp_eig_std", "ltr_mean",
                   "ltr_std", "rtr_mean", "rtr_std", "optval_ssdp",
                   "optval_socp", "optval_ltr", "optval_rtr"]
    record = pd.DataFrame(np.zeros((num_size, len(column_name))),
                          columns=column_name)

    # Collect method names and their interface
    method_names = ["ssdp", "socp", "ltr", "rtr"]
    method_iface = [sdp, socp, ltrsr, rtr]
    assert np.all(set(methods_bool.keys()) == set(method_names))
    for i in tqdm(range(num_size), desc="data size (getTime)",
                  colour="red", leave=False, position=2):
        for name, iface in zip(method_names, method_iface):
            if not methods_bool[name]:
                continue
            time = np.zeros(fold)
            time_eig = np.zeros(fold)
            optval = np.zeros(fold)
            m_curr = size_range[i]
            for idx in range(fold):
                ridx = random.sample(range(m), int(m_curr))
                w_star, optval_v, time_v = iface(X[ridx, :], y[ridx].reshape((-1, 1)),
                                                 z[ridx].reshape((-1, 1)), gamma)

                if name == "socp":
                    time[idx] = time_v[1]
                    time_eig[idx] = time_v[0]
                else:
                    time[idx] = time_v
                optval[idx] = optval_v
                # print(name, w_star)

            record[name + "_mean"][i] = np.log(np.mean(time))
            record[name + "_std"][i] = np.std(time)
            if name == "socp":
                record["socp_eig_mean"][i] = np.log(np.mean(time_eig))
                record["socp_eig_std"][i] = np.std(time_eig)
            record["optval_" + name][i] = np.mean(optval)

    # Change index name for plotting
    record = pd.DataFrame(record.to_numpy(), columns=record.columns,
                          index=size_range)
    return record
