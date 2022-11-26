# This script is intended to generate tables and numbers that illustrates the analysis results of the experiments.
import os
import pandas as pd
import numpy as np

from main_realData import RESULT_DIR, METHOD, GAMMA_LIST


def compare_building_wine():
    for gamma in GAMMA_LIST:
        for type in ["modest", "severe"]:
            print("######")
            print("gamma:", gamma, "; type:", type)
            building_path = os.path.join(RESULT_DIR, "building_" + type + "_" +
                                         str(gamma) + "_result.csv")
            wine_path = os.path.join(RESULT_DIR, "wine_" + type + "_" +
                                     str(gamma) + "_result.csv")
            building = pd.read_csv(building_path)
            wine = pd.read_csv(wine_path)

            # building
            # ltr
            lstr_build_re = (building["optval_socp"] - building["optval_ltr"]) / \
                            np.abs(building["optval_socp"]).to_numpy()
            print("|fSOCP-fLTRS|/|fSOCP|(AVG, MIN, NAX|building) =", lstr_build_re.mean(),
                  lstr_build_re.max(), lstr_build_re.min())
            # rtr
            lstr_build_re = (building["optval_socp"] - building["optval_rtr"]) / \
                            np.abs(building["optval_socp"]).to_numpy()
            print("|fSOCP-fRTR|/|fSOCP|(AVG, MIN, NAX|building) =", lstr_build_re.mean(),
                  lstr_build_re.max(), lstr_build_re.min())

            # wine
            # ltr
            lstr_wine_re = (wine["optval_socp"] - wine["optval_ltr"]) / \
                           np.abs(wine["optval_socp"]).to_numpy()
            print("|fSOCP-fLTRS|/|fSOCP|(AVG, MIN, NAX|wine) =", lstr_wine_re.mean(),
                  lstr_wine_re.max(), lstr_wine_re.min())
            # rtr
            lstr_wine_re = (wine["optval_socp"] - wine["optval_rtr"]) / \
                           np.abs(wine["optval_socp"]).to_numpy()
            print("|fSOCP-fRTR|/|fSOCP|(AVG, MIN, NAX|wine) =", lstr_wine_re.mean(),
                  lstr_wine_re.max(), lstr_wine_re.min())


if __name__ == "__main__":
    compare_building_wine()