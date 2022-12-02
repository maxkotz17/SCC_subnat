using MimiGIVE, Mimi, DataFrames, CSVFiles, VegaLite, Query, Statistics, Printf
import Random

function compute_rff_scc(num_trials, seed)
    Random.seed!(seed)

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
        save_md = false,
        save_cpc = false,
        compute_sectoral_values = true,
        compute_domestic_values = false,
        CIAM_foresight = :perfect,
        CIAM_GDPcap = true,
        pulse_size = 1e-4,
    )

    return results
end

function compute_subnatdam_scc(num_trials, seed)
    Random.seed!(seed)

    m = MimiGIVE.get_model(socioeconomics_source = :RFF)

    update_param!(m, :DamageAggregator, :include_cromar_mortality, false)
    update_param!(m, :DamageAggregator, :include_ag, false)
    update_param!(m, :DamageAggregator, :include_slr, false)
    update_param!(m, :DamageAggregator, :include_energy, false)
    update_param!(m, :DamageAggregator, :include_subnatdam, true)

    results = MimiGIVE.compute_scc(m;
        year = 2020,
        last_year = 2300,
        discount_rates = discount_rates,
        fair_parameter_set = :random,
        rffsp_sampling = :random,
        n = num_trials,
        gas = :CO2,
        output_dir = nothing,
        save_md = false,
        save_cpc = false,
        compute_sectoral_values = false,
        compute_domestic_values = false,
        CIAM_foresight = :perfect,
        CIAM_GDPcap = true,
        pulse_size = 1e-4,
    )

    return results
end

function run_subnatdam(seed)
	Random.seed!(seed)

	m = MimiGIVE.get_model(socioeconomics_source = :RFF)

	update_param!(m, :DamageAggregator, :include_cromar_mortality, false)
	update_param!(m, :DamageAggregator, :include_ag, false)
	update_param!(m, :DamageAggregator, :include_slr, false)
	update_param!(m, :DamageAggregator, :include_energy, false)
	update_param!(m, :DamageAggregator, :include_subnatdam, true)

	run(m)	
	return getdataframe(m, :DamageAggregator=>:total_damage_share) 
end


function run_dice(seed)
	Random.seed!(seed)
	m = MimiGIVE.get_model(socioeconomics_source = :RFF)

	update_param!(m, :DamageAggregator, :include_cromar_mortality, false)
	update_param!(m, :DamageAggregator, :include_ag, false)
	update_param!(m, :DamageAggregator, :include_slr, false)
	update_param!(m, :DamageAggregator, :include_energy, false)
	update_param!(m, :DamageAggregator, :include_dice2016R2, true)

	run(m)
	return getdataframe(m, :DamageAggregator=>:total_damage_share)
end

function compute_dice_scc(num_trials, seed)
    Random.seed!(seed)

    m = MimiGIVE.get_model(socioeconomics_source = :RFF)

    update_param!(m, :DamageAggregator, :include_cromar_mortality, false)
    update_param!(m, :DamageAggregator, :include_ag, false)
    update_param!(m, :DamageAggregator, :include_slr, false)
    update_param!(m, :DamageAggregator, :include_energy, false)
    update_param!(m, :DamageAggregator, :include_dice2016R2, true)

    results = MimiGIVE.compute_scc(m;
        year = 2020,
        last_year = 2300,
        discount_rates = discount_rates,
        fair_parameter_set = :random,
        rffsp_sampling = :random,
        n = num_trials,
        gas = :CO2,
        output_dir = nothing,
        save_md = false,
        save_cpc = false,
        compute_sectoral_values = false,
        compute_domestic_values = false,
        CIAM_foresight = :perfect,
        CIAM_GDPcap = true,
        pulse_size = 1e-4,
    )

    return results
end

function compute_hs_scc(num_trials, seed)
    Random.seed!(seed)
    
    m = MimiGIVE.get_model(socioeconomics_source = :RFF)

    update_param!(m, :DamageAggregator, :include_cromar_mortality, false)
    update_param!(m, :DamageAggregator, :include_ag, false)
    update_param!(m, :DamageAggregator, :include_slr, false)
    update_param!(m, :DamageAggregator, :include_energy, false)
    update_param!(m, :DamageAggregator, :include_hs_damage, true)

    results = MimiGIVE.compute_scc(m;
        year = 2020,
        last_year = 2300,
        discount_rates = discount_rates,
        fair_parameter_set = :random,
        rffsp_sampling = :random,
        n = num_trials,
        gas = :CO2,
        output_dir = nothing,
        save_md = false,
        save_cpc = false,
        compute_sectoral_values = false,
        compute_domestic_values = false,
        CIAM_foresight = :perfect,
        CIAM_GDPcap = true,
        pulse_size = 1e-4,
    )

    return results
end

function compute_figure2_data(results)
    df_final = DataFrame(scc = Float64[], dr = String[])

    for (k, v) in results[:scc]
        if k.sector == :total
            df = DataFrame(scc = v.sccs .* pricelevel_2005_to_2020)
            df[!, :dr] .= k.dr_label

            append!(df_final, df)
        end
    end

    output_dir = joinpath(@__DIR__, "..", "output")
    mkpath(output_dir)

    df_final |> save(joinpath(output_dir, "figure2_data.csv"))

    return nothing
end

function compute_extended_figure1_data(results)
    df_final = DataFrame(scc = Float64[], dr = String[], damagefunction = String[])

    for (damagefunction, res) in results
        for (k, v) in res[:scc]
            if damagefunction != :rff || k.sector == :total
                df = DataFrame(scc = v.sccs .* pricelevel_2005_to_2020)
                df[!, :dr] .= k.dr_label
                df[!, :damagefunction] .= string(damagefunction)

                append!(df_final, df)
            end
        end
    end

    output_dir = joinpath(@__DIR__, "..", "output")
    mkpath(output_dir)

    df_final |> save(joinpath(output_dir, "extended_figure1_data.csv"))

    return nothing
end

function compute_figure3_data(results)
    df_final = DataFrame(scc = Float64[], sector = Symbol[], dr = String[])

    for (k, v) in results[:scc]
        df = DataFrame(scc = v.sccs .* pricelevel_2005_to_2020)
        df[!, :sector] .= k.sector
        df[!, :dr] .= k.dr_label

        append!(df_final, df)
    end

    output_dir = joinpath(@__DIR__, "..", "output")
    df_final |> save(joinpath(output_dir, "figure3_data.csv"))

    return nothing
end
