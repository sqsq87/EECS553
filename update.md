Ziyuan's update on 11/26/2022

### What did I do

**1. ``./submit`` Folder**

This folder is intended for final submission. I put good-looking plots and decent results into this folder, incase our
program rewrite those files. Anyone seeing any neat results can copy them into this folder.

**2. LSTRS package**
This is a modified version of LSTRS package from http://homepage.tudelft.nl/w4u81/Docs/lstrs-manual.pdf.
The previous version is out-dated for MATLAB > 2006. Please use the package from our own directory.

**3. Krylov implementation**
The major edition is in files *LTRSR1.m*, *LTRSR2.m*, and *krylov.m*. *krylov.m* provides three different implementations
of the krylov subspace method: safeguard_newton, gltr, and lstrs. We could discuss the performance of these three methods 
in our report.

Unfortunately, as far as I observe from my device, each of the three methods attains some results in the original paper, 
but none of them can attain all the results simultaneously. For example, safeguard_newton and gltr achieve pretty decent 
accuracy results (Table 1 in the paper) but fail to provide speed results in Table 2. LSTRS runs much faster for spase 
matrices, but it is far less accurate than the other two. By adjusting the accuracy parameter ``epsilon`` in LSTRTS according to the
user manual http://homepage.tudelft.nl/w4u81/Docs/lstrs-manual.pdf, one can realize that LSTRS runs even slower than SDP
in the wine dataset.

I believe the root of the dilemma lies in the MATLAB implementation. GALAHAD is compiled in lower-level Fortran, which may
achieve higher speed.

I have tried optimizing the code, such as turning the T matrix into sparse matrix, replace loops with MATLAB built-in vectorization
methods, but none of them works. In fact, the RTR algorithm runs pretty fast on my machine, which you can see in the ``/submit``
folder, and only LSTRS successfully beat RTR method on sparse problems.

### How to run the code
#### Prerequisite
1. Need to be able to run mosek and ROPTLIB. 
2.  Add mosek, ROPTLIB, and LSTRS to your path.

### Run the code
For real data:
1. Modify *main_realData.m* to select which files you would like to run.
2. Select ``hypertune`` parameter in *LSTRS1.m* and *LSTRS2.m*.
3. Run *main_realData.m*.
4. Run *main_plot.m* to plot all files.
5. Plots are available in ``./figures`` folder and the optimal value of the objective function is available under 
``./result/*_value.csv`` where ``*`` stands for one of ``wine_modest``, ``wine_severe``, ``building_modest``, and ``building_severe``.
The ``csv`` file is used to compute relative error as in Table 1. There is a calculation result available in ``./submit``.

For synthetic data:
1. Run *generate_synthetic_sparse.m* to generate the data.
2. Run *main_syhthetic_sparse.m*.

### Memory issue 
I cannot only run the first three values in ``n_list`` because the rest will cause a memory issue.