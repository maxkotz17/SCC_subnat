# Replication code for Rennert et al. "Comprehensive Evidence Implies a Higher Social Cost of CO2"

This repository holds all code required to replicate the results of:

Rennert, K., Errickson, F., Prest, B. C., Rennels, L., Newell, R. G., Pizer, W., Kingdon, C., Wingenroth, J., Cooke, R., Parthum, B., Smith, D., Cromar, K., Diaz, D., Moore, F. C., Müller, U. K., Plevin, R. J., Raftery, A. E., Ševčíková, H., Sheets, H., Stock, J. H., Tan, T., Watson, M., Wong, T. E., & Anthoff, D. (2022). Comprehensive Evidence Implies a Higher Social Cost of CO2. Nature. https://doi.org/10.1038/s41586-022-05224-9.

The replication code for this paper can also be found at https://github.com/anthofflab/paper-2022-scc-give.

## Hardware and software requirements

You need to install [Julia](http://julialang.org/) to run the replication code. We tested this code on Julia version 1.6.4.

Make sure to install Julia in such a way that the Julia binary is on the `PATH`.

Running the complete replication code on Windows on a system with an Intel Xeon W-2195 18 core CPU, 128 GB of RAM and a 1 TB SSD hard drive takes about one day.

## Running the replication script

To recreate all outputs and figures for this paper, open a OS shell and change into the folder where you downloaded the content of this replication repository. Then run the following command to compute all results:

```
julia --procs auto src/main.jl
```

The script is configured such that it automatically downloads and installs any required Julia packages.

## Result and figure files

All results and figures will be stored in the folder `output`.

#Ammendments made by Maximilian Kotz to incorporate empirically-derived estimates of sub-national macroeconomic damages
#See new component packages/MimiGIVE/src/components/subnat_damages.jl 
#and according ammendments made to components packages/MimiGIVE/src/components/DamageAggregator.jl, packages/MimiGIVE/src/main_model.jl, src/compute_scc.jl 

#Run as instructed above using 
```
julia --procs auto src/main.jl
```

#And see the current error status (having already worked through errors to compile the MimiGIVE model with the new modifications).

