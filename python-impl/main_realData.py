import os
from sklearn.preprocessing import normalize
from tqdm import tqdm

from data_read import data_read
from getTime_realData import getTime_realData

# directory to the result
RESULT_DIR = "../result/"

# method used
METHOD = {"ssdp": True, "socp": True, "ltr": True, "rtr": True}

# list of dataset name
DATANAME_LIST = ["wine_modest", "wine_severe", "insurance_modest",
                 "insurance_severe", "house_modest", "house_severe"]

GAMMA_LIST = [1e-1]


def main_realData(methods: dict = METHOD, dataname_list: list = DATANAME_LIST,
                  gamma_list: list = GAMMA_LIST, result_dir: str = RESULT_DIR,
                  norm: bool = True):
    # Configuration
    len_name = len(dataname_list)

    for gamma in tqdm(gamma_list, desc="gamma (main)",
                      colour="green", leave=False, position=0):
        for idx in tqdm(range(len_name), desc="dataset (main)",
                        colour="blue", leave=False, position=1):
            dataname = dataname_list[idx]
            X, y, z, const, gamma_list, gamma_time, \
                datasize_list = data_read(name=dataname)

            if norm:
                X = normalize(X, axis=1, norm='l1')

            record = getTime_realData(X, y, z, gamma,
                                      datasize_list.astype(int),
                                      methods, 10)
            table_name_cmp = os.path.join(result_dir, dataname + '_' +
                                          str(gamma) + "_result.csv")
            record.to_csv(table_name_cmp)


if __name__ == "__main__":
    main_realData()
