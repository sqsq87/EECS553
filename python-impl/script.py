import numpy as np
import pandas as pd
from sklearn.preprocessing import normalize

from data_read import data_read
from getTime_realData import getTime_realData


def run():
    dataname_list = ["wine_modest", "wine_severe", "insurance_modest", "insurance_severe"]
    len_name = len(dataname_list)
    gamma_list = [1e-1]
    normalize_yes = 1

    for gamma_idx in range(len(gamma_list)):
        gamma = gamma_list[gamma_idx]
        ssdp_mr = np.zeros((len_name, 1))
        ssdp_std = np.zeros((len_name, 1))
        for idx in range(len_name):
            dataname = dataname_list[idx]
            [X, y, z, const, gamma_list, gamma_time, datasize_list] = data_read(dataname)

            if normalize_yes:
                X = normalize(X, axis=1, norm='l1')

            Infossdp = getTime_realData(X, y, z, gamma, datasize_list);
            ssdp_mr = Infossdp[0]
            ssdp_std = Infossdp[1]

            print(ssdp_mr, ssdp_std)
            df = pd.DataFrame({'datasize': datasize_list, 'ssdp_mr': ssdp_mr, 'ssdp_std': ssdp_std})

            table_name_cmp = 'result/' + str(dataname) + '_time.csv'
            df.to_csv(table_name_cmp)


if __name__ == "__main__":
    run()
