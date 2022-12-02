using MimiGIVE, Mimi, DataFrames, CSVFiles, Query, Dates, Arrow, VegaLite, Statistics, DataValues
import Random

function compute_figure1_data(num_trials, seed)
    Random.seed!(seed)

    output_dir = joinpath(@__DIR__, "..", "output")
    detail_dir = joinpath(output_dir, "Figure1")
    mkpath(detail_dir)

    m = MimiGIVE.get_model(socioeconomics_source = :RFF)

    save_list = [
        (:Socioeconomic, :co2_emissions), # Emissions (GtC/yr)
        (:Socioeconomic, :population_global), # Global population (millions of persons)
        (:PerCapitaGDP, :global_pc_gdp), # Global GDP (billions of USD $2005/yr)
        (:TempNorm_1850to1900, :global_temperature_norm), # Global surface temperature anomaly (K) from preinudstrial
        (:co2_cycle, :co2), # Total atmospheric carbon dioxide concentrations (ppm)
        (:GlobalSLRNorm_1900, :global_slr_norm) # total sea level rise from all components (includes landwater storage for projection periods) (m)
    ]

    MimiGIVE.run_mcs(; trials = num_trials,
        output_dir = detail_dir,
        save_trials = false,
        fair_parameter_set = :random,
        rffsp_sampling = :random,
        m = m,
        save_list = save_list,
        results_in_memory = false,
    )

    # At this point all the data we need can be found in output_dir/results which will hold
    # one CSV per saved variable

    ## ----------------------------------------------------------------------------- 
    ## Step 2. Post-Process to Final Table

    df_emissions = load(joinpath(detail_dir, "results", "Socioeconomic_co2_emissions.csv"), colparsers = Dict(:co2_emissions => Float64)) |>
                   @mutate(variable = "CO₂ emissions") |>
                   @mutate(co2_emissions = _.co2_emissions * 44 / 12) |> # Convert from Gt C to Gt CO2
                   @rename(:co2_emissions => :value, :time => :year) |>
                   @filter(_.year >= 2020 && _.year <= 2300) |>
                   @select(:year, :variable, :value) |>
                   @mutate(year = Date(_.year)) |>
                   @dissallowna() |>
                   DataFrame

    df_concentrations = load(joinpath(detail_dir, "results", "co2_cycle_co2.csv"), colparsers = Dict(:co2 => Float64)) |>
                        @mutate(variable = "CO₂ concentrations") |>
                        @rename(:co2 => :value, :time => :year) |>
                        @filter(_.year >= 2020 && _.year <= 2300) |>
                        @select(:year, :variable, :value) |>
                        @mutate(year = Date(_.year)) |>
                        @dissallowna() |>
                        DataFrame

    df_temporary = load(joinpath(detail_dir, "results", "PerCapitaGDP_global_pc_gdp.csv"), colparsers = Dict(:global_pc_gdp => Float64)) |> DataFrame

    ypc_2020 = df_temporary |>
               @filter(_.time == 2020) |>
               @dissallowna()

    df_ypc_cumgrowth = df_temporary |>
                       @rename(:time => :year) |>
                       @join(ypc_2020, _.trialnum, _.trialnum, {_..., ypc2020 = __.global_pc_gdp}) |>
                       @mutate(ypc_cumgrowth = (_.global_pc_gdp / _.ypc2020)^(1 / (_.year - 2020)) - 1) |>
                       @mutate(variable = "GDP per capita growth") |>
                       @rename(:ypc_cumgrowth => :value) |>
                       @filter(_.year >= 2020 && _.year <= 2300) |>
                       @select(:year, :variable, :value) |>
                       @mutate(year = Date(_.year)) |>
                       @dissallowna() |>
                       DataFrame

    df_pop = load(joinpath(detail_dir, "results", "Socioeconomic_population_global.csv"), colparsers = Dict(:population_global => Float64)) |>
             @mutate(variable = "Population") |>
             @rename(:population_global => :value, :time => :year) |>
             @filter(_.year >= 2020 && _.year <= 2300) |>
             @select(:year, :variable, :value) |>
             @mutate(year = Date(_.year)) |>
             @mutate(value = _.value / 1000) |> # Convert to billions
             @dissallowna() |>
             DataFrame

    df_temp = load(joinpath(detail_dir, "results", "TempNorm_1850to1900_global_temperature_norm.csv"), colparsers = Dict(:global_temperature_norm => Float64)) |>
              @mutate(variable = "Temperature") |>
              @rename(:global_temperature_norm => :value, :time => :year) |>
              @filter(_.year >= 2020 && _.year <= 2300) |>
              @select(:year, :variable, :value) |>
              @mutate(year = Date(_.year)) |>
              @dissallowna() |>
              DataFrame

    df_slr = load(joinpath(detail_dir, "results", "GlobalSLRNorm_1900_global_slr_norm.csv"), colparsers = Dict(:global_slr_norm => Float64)) |>
             @mutate(variable = "Sea-level rise") |>
             @rename(:global_slr_norm => :value, :time => :year) |>
             @filter(_.year >= 2020 && _.year <= 2300) |>
             @select(:year, :variable, :value) |>
             @mutate(year = Date(_.year)) |>
             @dissallowna() |>
             DataFrame

    df_all = vcat(df_emissions, df_concentrations, df_ypc_cumgrowth, df_pop, df_temp, df_slr)

    df_all |> save(joinpath(output_dir, "figure1_data.csv"))
end