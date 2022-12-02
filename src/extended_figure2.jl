using MimiGIVE, Mimi, DataFrames, CSVFiles, Dates, Statistics, VegaLite, Query

function plot_extended_figure2()
    df = load(joinpath(@__DIR__, "..", "output", "extended_figure2_data.csv")) |> DataFrame

    p = df |>
        @filter(_.dr == 0.02 && _.year < Date(2300)) |>
        @groupby({_.year}) |>
        @map({key(_)..., q05 = quantile(_.md, 0.05), q25 = quantile(_.md, 0.25), mean = mean(_.md), median = quantile(_.md, 0.5), q75 = quantile(_.md, 0.75), q95 = quantile(_.md, 0.95)}) |>
        @vlplot(
            x = {
                "year:t",
                timeUnit = :year,
                axis = {
                    grid = false,
                },
                title = "Year"
            },
            width = 400,
            height = 300,
            config = {
                style = {
                    cell = {
                        stroke = :transparent
                    }
                },
                axis = {
                    labelFontSize = 7,
                    titleFontWeight = :normal,
                    titleFontSize = 7,
                    domainColor = :black,
                    tickColor = :black,
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
                legend = {
                    labelFontSize = 7,
                    titleFontSize = 7
                },
                text = {
                    fontSize = 7
                },
                title = {
                    fontSize = 8,
                    anchor = :start
                }
            }
        ) +
        @vlplot(
            {:errorband, opacity = 0.1},
            y = {
                "q05:q",
                axis = {
                    grid = true,
                },
                title = "SC-CO₂ (US\$ per tonne of CO₂)"
            },
            y2 = "q95:q",
        ) +
        @vlplot(
            {:errorband, opacity = 0.3},
            y = {
                "q25:q",
                title = "SC-CO₂ (US\$ per tonne of CO₂)"
            },
            y2 = "q75:q",
        ) +
        @vlplot(:line, y = "mean") +
        @vlplot({:line, strokeDash = "4,4"}, y = "median")

    output_dir = joinpath(@__DIR__, "..", "output")
    mkpath(output_dir)

    p |> save(joinpath(output_dir, "ext_fig2.svg"))

    return p
end
