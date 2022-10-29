import os

import numpy as np
import pandas as pd


# Read data from database provided
# "name" as the name of the dataset
def data_read(name: str, directory="../datasets/"):
    if name in ["wine_modest", "wine_severe"]:
        data = pd.read_csv(os.path.join(directory, "wine.csv"),
                           sep=';').to_numpy()
        X, y = data[:, :-1], data[:, -1]
        z = np.clip(y, 0, 10)
        if name.find("modest") != -1:
            z = np.clip(z, 6, None)
        else:
            z = np.clip(z, 7, None)
        # Configuration parameters, can change later using
        # structure options
        const = 0.1
        gamma_list = np.linspace(1e-3, 0.75, 40)
        gamma_time = 0.5
        datasize_list = np.linspace(150, 1500, 16)

    elif name in ["insurance_modest", "insurance_severe"]:
        data = pd.read_csv(os.path.join(directory,
                                        "insurance.csv"), sep=',')
        y = data["charges"].to_numpy()
        data = data.drop("charges")
        for column in ["sex", "smoker", "region"]:
            one_hot = pd.get_dummies(data[column])
            data = data.drop(column, axis=1)
            data = data.join(one_hot)
        X = data.to_numpy()
        if name.find("modest"):
            z = y - 100
        else:
            z = y - 300
        z = np.clip(z, 0, None)
        z /= 100
        y /= 100

        # Configuration parameters
        const = 0.03
        gamma_list = [1e-3]
        gamma_time = 0.5
        datasize_list = np.linspace(100, 1300, 25)

    elif name in ["building_modest", "building_severe",
                  "building_modest170", "building_severe170"]:
        data = pd.read_excel(io=os.path.join(directory, "building.xlsx"),
                             sheet_name="Data", header=1).to_numpy()
        y = data[:, -1]
        X = data[:, :-1]
        if name.find("modest"):
            z = y + 20
        else:
            z = y + 40
        z = np.clip(z, 0, None)

        # Configuration parameters
        const = 0.01
        gamma_list = [20]
        gamma_time = 0.5
        if name in ["building_modest", "building_severe"]:
            datasize_list = np.linspace(100, 300, 21)
        else:
            datasize_list = [170]
        nor = const * np.max(np.abs(y))
        y = y / nor
        z = z / nor

    elif name in ["blog_modest", "blog_severe"]:
        data = pd.read_csv(os.path.join(directory, "blog.csv"),
                           sep=',').to_numpy()
        y = data[:, -1]
        X = data[:, :-1]
        if name.find("modest"):
            z = y + 5
        else:
            z = y + 10
        z = np.clip(z, 0, None)

        # Configuration parameters
        const = 0.01
        gamma_list = [200]
        gamma_time = 0.5
        datasize_list = np.linspace(5000, 50000, 10)

    else:
        raise ValueError("Data set name not recognized.")

    return X, y, z, const, gamma_list, gamma_time, datasize_list
