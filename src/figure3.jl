using MimiGIVE, Mimi, DataFrames, CSVFiles, Query, VegaLite, Statistics

function plot_figure3()
    output_dir = joinpath(@__DIR__, "..", "output")

    data = load(joinpath(output_dir, "figure3_data.csv"), colparsers = Dict(:dr => String))

    aggregated_data = data |>
                      @filter(_.dr == "2.0%") |>
                      @mutate(sector =
                          _.sector == "total" ? "Total" :
                          _.sector == "energy" ? "Energy" :
                          _.sector == "cromar_mortality" ? "Mortality" :
                          _.sector == "agriculture" ? "Agriculture" :
                          _.sector == "slr" ? "Sea-level rise" : error("Unknown sector")) |>
                      @groupby({_.dr, _.sector}) |>
                      @map({key(_)..., q05 = quantile(_.scc, 0.05), q25 = quantile(_.scc, 0.25), median = quantile(_.scc, 0.5), q75 = quantile(_.scc, 0.75), q95 = quantile(_.scc, 0.95), mean = mean(_.scc)}) |>
                      DataFrame

    p = aggregated_data |> @vlplot(
                               y = {"sector:n", axis = {domain = false, ticks = false, title = nothing, grid = false}},
                               color = {"sector:n", legend = nothing, scale = {range = ["#abbcd2", "#f2caa2", "#c2dbd9", "#f1d0cf", "#b5cfac"]}},
                               config = {
                                   font = "Arial",
                                   style = {cell = {stroke = :transparent}},
                                   axis = {
                                       domainColor = :black,
                                       tickColor = :black,
                                       labelFontSize = 7,
                                       labelFlush = false,
                                       titleFontWeight = :normal,
                                       titleFontSize = 7,
                                       gridColor = {
                                           value = "#ddd"
                                       },
                                       gridOpacity = {
                                           condition = {
                                               test = "datum.value===0",
                                               value = 1
                                           },
                                           value = 0
                                       }
                                   },
                               },
                               width = 280,
                               height = {
                                   step = 20
                               }) +
                           @vlplot(:rule, x = {
                                   "q05:q",
                                   axis = {title = "SC-CO₂ (US\$ per tonne of CO₂)", grid = true}
                               },
                               x2 = "q95:q"
                           ) +
                           @vlplot(
                               {
                                   :bar,
                                   size = 13
                               },
                               x = "q25:q",
                               x2 = "q75:q"
                           ) +
                           @vlplot(
                               {
                                   :tick,
                               },
                               x = "median:q",
                               color = {
                                   value = :white
                               },
                               size = {
                                   condition = {
                                       test = "(datum.q75-datum.q25) < 2",
                                       value = 0
                                   },
                                   value = 13
                               }
                           ) +
                           @vlplot(
                               {
                                   :text,
                                   fontSize = 7,
                                   dy = -12
                               },
                               x = "mean:q",
                               text = {
                                   "mean:q",
                                   format = "\$.0f"
                               },
                               color = {value = :black}
                           ) +
                           @vlplot(
                               {
                                   :point,
                                   shape = :diamond,
                                   strokeWidth = 1
                               },
                               x = "mean:q",
                               color = {value = :black}
                           )

    p |> save(joinpath(output_dir, "fig3.svg"))
    aggregated_data |> save(joinpath(output_dir, "figure3_data_aggregated.csv"))
end
