using MimiGIVE, Mimi, DataFrames, CSVFiles, Dates, Statistics, VegaLite
import Random

function compute_extended_figure2_data(num_trials, seed)
    Random.seed!(seed)
    
    output_dir = joinpath(@__DIR__, "..", "output")
    mkpath(output_dir)

    m = MimiGIVE.get_model(socioeconomics_source = :RFF)

    results = MimiGIVE.compute_scc(m;
        year = 2020,
        last_year = 2300,
        discount_rates = discount_rates,
        fair_parameter_set = :random,
        rffsp_sampling = :random,
        n = num_trials,
        gas = :CO2,
        output_dir = nothing,
        save_md = true,
        save_cpc = true,
        compute_sectoral_values = false,
        compute_domestic_values = false,
        CIAM_foresight = :perfect,
        CIAM_GDPcap = true,
        pulse_size = 1e-4,
    )

    mds = results[:mds][(region = :globe, sector = :total)] .* pricelevel_2005_to_2020
    cpc = results[:cpc][(region = :globe, sector = :total)] .* pricelevel_2005_to_2020

    df_final = DataFrame(md = Float64[], year = DateTime[], dr = String[])

    for dr in discount_rates
        e_cpc_2020 = mean(view(cpc, :, 1)) # TODO Confirm that index 1 here corresponds to the year 2020
        npv_mds = (e_cpc_2020 ./ cpc) .^ dr.eta .* (1 + dr.prtp) .^ (0:-1:-280)' .* mds

        for (i, year) in enumerate(2020:2300)
            df = DataFrame(md = npv_mds[:, i], year = Date(year), dr = dr.label)

            append!(df_final, df)
        end
    end

    df_final |> save(joinpath(output_dir, "extended_figure2_data.csv"))

    return nothing
end
