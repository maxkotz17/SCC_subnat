using MimiDICE2016, MimiRFFSPs, Mimi, DataFrames, Query, CSVFiles, Distributions
import Random

function compute_dice_original_scc(seed)
    Random.seed!(seed)
    
    # This function produces the SC-CO2 in $2020 for various discount rates specifications
    # of the deterministic DICE 2016R model.

    output_dir = joinpath(@__DIR__, "..", "output", "rff-dice", "scco2")
    mkpath(output_dir)

    pricelevel_2010_to_2020 = 113.648 / 96.166 # (11/21/2021) BEA Table 1.1.9, line 1 GDP annual values as linked here: https://apps.bea.gov/iTable/iTable.cfm?reqid=19&step=3&isuri=1&select_all_years=0&nipa_table_list=13&series=a&first_year=2005&last_year=2020&scale=-99&categories=survey&thetable=

    df = DataFrame()
    for dr in dice_discount_rates
        scc = MimiDICE2016.compute_scc(year = 2020, last_year = 2300, prtp = dr.prtp, eta = dr.eta) * pricelevel_2010_to_2020
        append!(df, DataFrame(:label => dr.label, :prtp => dr.prtp, :eta => dr.eta, :scc => scc))
    end

    df |> save(joinpath(output_dir, "DICE2016R_scco2_summary.csv"))

    return df
end
