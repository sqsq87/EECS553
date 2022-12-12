This is the code used in this reproducibility report, adapted from the ICML 2022 conference paper "Solving  Stackelberg Prediction Game with Least Squares Loss via Spherically Constrained Least Squares Reformulation".

This code has the following requirements:
- MATLAB 2020b or later
- MOSEK solver (https://www.mosek.com/)
- ROPTLIB solver (https://www.math.fsu.edu/~whuang2/Indices/index_ROPTLIB.html)
- The MATLAB Statistics and Machine Learning Toolbox (https://uk.mathworks.com/products/statistics.html)
- The MATLAB Parallel Computing Toolbox (https://uk.mathworks.com/products/parallel-computing.html)
- The MATLAB Optimization Toolbox (https://uk.mathworks.com/products/optimization.html)

+ BlogFeedBack Dataset (https://archive.ics.uci.edu/ml/datasets/BlogFeedback)
+ Residential Building Dataset (https://archive.ics.uci.edu/ml/datasets/Residential+Building+Data+Set)

This is a public repo for the original paper. For the link to their original code, refer to https://github.com/JialiWang12/SCLS.

Our added folder is the python-impl/ directory and krylov.m. The former is a failed trial during our reproducing process. The latter is our own implementation of the Krylov subspace method following GLTR.

Our final results are gathered in submit/ directory.
