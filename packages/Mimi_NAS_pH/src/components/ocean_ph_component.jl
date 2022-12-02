# ---------------------------------------------------------------------------------------------------------------------------
# Globally Averaged Ocean pH from "Valuing Climate Damages: Updating Estimation of the Social Cost of Carbon Dioxide" (2017)
# ---------------------------------------------------------------------------------------------------------------------------

@defcomp ocean_pH begin

    β1           = Parameter()             # Multiplicative term from pH approximation (from Equation 7 in Appendix F).
    β2           = Parameter()             # Additive term from pH approximation (from Equation 7 in Appendix F).
    pH_0         = Parameter()             # Globally averaged ocean pH for first model timestep.
    atm_co2_conc = Parameter(index=[time]) # Atmospheric CO₂ concentration used to approximate CO₂ partial pressure of the surface ocean (ppm, 10⁻⁶ mol CO₂ per mol air)

    pH = Variable(index=[time])            # Globally averaged ocean pH (-log₁₀[H⁺]).


    function run_timestep(p, v, d, t)

        # Note: Report states, "Globally averaged pCO2 of the surface ocean can be estimated from globally averaged CO2 concentration in the atmosphere with
        #       approximately 1 year lag." As a result, the equation here uses atmospheric CO₂ concentrations from period [t-1] to calculate pH for period [t].

        if is_first(t)
            # Set initial condition for timestep 1.
            v.pH[t] = p.pH_0
        else
            # Calculate ocean pH following Equation 7 in Appendix F of report.
            v.pH[t] = p.β1 * log(p.atm_co2_conc[t-1]) + p.β2
        end
    end
end
