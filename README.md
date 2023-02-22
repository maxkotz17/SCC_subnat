# Top-down implementation of MimiGIVE with subnational damage functions

This repository holds a modified version of the Greenhouse Gas Impact Value Estimator (GIVE) Integrated Assessment Model, first developed and released by Rennert et al. ("Comprehensive evidence implies a higher social cost of CO$_2$", _Nature_, 2022).

The original version of GIVE used individual "bottom-up" damage functions for sectors such as mortality, energy demand, and agriculture; this version uses "top-down" damage functions derived from empirical relationships between climate variation and GDP per capita growth.

Modified by Max Kotz and Chris Callahan.

## Hardware and software requirements

You need to install [Julia](http://julialang.org/) to run the replication code. Make sure to install Julia in such a way that the Julia binary is on the `PATH`.

## Running the model

To generate a distribution of estimated social cost of carbon (SCC) values, open an OS shell and change into the folder where you downloaded the content of this repository. Then run the following command.

```
julia --procs auto src/main.jl
```

The script is configured such that it automatically downloads and installs any required Julia packages. 

All results and figures will be stored in the `output` folder. The `/output/figure2_data.csv` file contains the SCC values of interest.

There are two warnings or error messages to be aware of:

- When running the model, you may get a series of warning messages about the MimiRFFSPs. This appears to be normal and does not affect the functioning of the model.
- During some Monte Carlo iterations, the model has occasionally hit an error when trying to raise a negative number to an exponent in the discounting module. This appears to only occur when net consumption is negative (an extreme outlier case), and does not occur with the current randomization seed (set at 42 in `main.jl`.) If you maintain this seed, the model should continue running fine. Changing the seed may yield particular Monte Carlo iterations that throw this error. Debugging this error should be done before final production and publication. There is a Github issue about it [here](https://github.com/rffscghg/MimiGIVE.jl/issues/21).

## Modifications

Amendments have been made by Maximilian Kotz and Chris Callahan to incorporate empirically derived estimates of subnational macreconomic damages. There is a new component, `/packages/MimiGIVE/src/components/subnat_damages.jl`, that implements the damage calculation for each country as a quadratic function of temperature. Related modifications have been made to scripts `DamageAggregator.jl`, `main_model.jl`, `compute_scc.jl`, and `main_mcs.jl`.

The damage function parameters for each country should be in a csv file deposited in the following folder: `/packages/MimiGIVE/data/subnat_dam_params/`. The model is currently configured to take two separate files, one for the linear coefficients and one for the quadratic coefficients. Importantly, "damage" should be represented by positive values. That is, a 10% loss in GDP is +10, not -10. 

The parameters are currently loaded from the csv files in the `main_model.jl` script. They are set ("connected") as a matrix of parameters, with rows corresponding to climate models and columns corresponding to countries. When the Monte Carlo simulations are running, each simulation will randomly choose one climate model (chosen in the `main_mcs.jl` script), and the `subnat_damages.jl` script will calculate the damages for each country using the chosen climate model. 

_Forked by Chris Callahan from Github on 21 December 2022. Preliminary modifications finished and pushed back to main branch on 9 February 2023._
