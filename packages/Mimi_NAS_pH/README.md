# Empirical Equation for Estimating Ocean Acidification

This package provides a simplified expression to calculate globally averaged ocean pH. Is follows Equation 7 from [Appendix F](https://www.nap.edu/read/24651/chapter/17) of "*Valuing Climate Damages: Updating Estimation of the Social Cost of Carbon Dioxide*":

![img](https://latex.codecogs.com/gif.latex?pH&space;=&space;-0.3671&space;\times&space;log_{_{e}}\left&space;(pCO_{2}&space;\right&space;)&plus;10.2328)

The equation is based on the ocean surface partial pressure of CO2 (*pCO2*), but the report notes, "*Globally averaged pCO2 of the surface ocean can be estimated from globally averaged CO2 concentration in the atmosphere with approximately 1 year lag.*" It therefore represents pCO2 in period ***[t]*** as the atmospheric CO2 concentration in period ***[t-1]***. 

The code is written in the [Julia programming language](https://julialang.org/) and uses the [Mimi framework](https://github.com/mimiframework/Mimi.jl) for integrated assessment models.

### Comparison of "*Valuing Climate Damages*" Report and Mimi Ocean pH Calculations

<a href="https://ibb.co/17454Yn"><img src="https://i.ibb.co/CmSZSpt/Replication-of-NAS-p-H-plot.png" alt="Replication-of-NAS-p-H-plot" border="0"></a>
