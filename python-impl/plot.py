import matplotlib.pyplot as plt
import os
import pandas as pd
import numpy as np

from main_realData import RESULT_DIR, GAMMA_LIST, DATANAME_LIST, METHOD


def plot_result(result_dir: str = RESULT_DIR,
                gamma_list: list = GAMMA_LIST,
                dataname_list: list = DATANAME_LIST):
    methods = METHOD.keys()
    for gamma in gamma_list:
        for dataname in dataname_list:
            # Result path and save path
            filename = dataname + '_' + str(gamma) + \
                       "_result.csv"
            path = os.path.join(result_dir, filename)
            save_path = os.path.join(result_dir, "plt_" +
                                     filename[:-4] + ".jpg")

            # Read result
            result = pd.read_csv(path)
            data = result[[method + "_mean" for method in methods]]
            data = np.exp(data)
            data.columns = methods
            error = result[[method + "_std" for method in methods]]
            error.columns = methods

            # Create plot
            data.plot(yerr=error)
            plt.yscale("log")
            plt.title("Time for " + dataname)
            plt.xlabel("dataset size")
            plt.ylabel("average training time")

            # save figure
            plt.savefig(save_path)


if __name__ == "__main__":
    plot_result()
