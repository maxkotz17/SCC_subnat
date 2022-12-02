using MimiGIVE, Mimi, DataFrames, CSVFiles, VegaLite, Query, Statistics, Printf

function plot_figure2()
    output_dir = joinpath(@__DIR__, "..", "output")

    data = load(joinpath(output_dir, "figure2_data.csv"), colparsers = Dict(:dr => String)) |> DataFrame

    rule_height = Dict(
        "1.5%" => 0.004,
        "2.0%" => 0.005,
        "2.5%" => 0.007,
        "3.0%" => 0.0085,
    )

    rule_data = data |>
                @groupby(_.dr) |>
                @map({dr = key(_), mean_scc = mean(_.scc)}) |>
                @mutate(label = string("\$", @sprintf("%.0f", _.mean_scc))) |>
                @join(rule_height, _.dr, _[1], {_..., height = __[2]})

    box_whisker_data = data |>
                       @groupby(_.dr) |>
                       @map({dr = key(_), median = quantile(_.scc, 0.5), q25 = quantile(_.scc, 0.25), q75 = quantile(_.scc, 0.75), q05 = quantile(_.scc, 0.05), q95 = quantile(_.scc, 0.95)})

    p = data |>
        @vlplot(
        resolve = {scale = {x = :shared}},
        config = {
            font = "Arial",
            style = {cell = {stroke = :transparent}},
            axis = {
                labelFontSize = 7,
                titleFontSize = 7,
                domainColor = :black,
                tickColor = :black
            },
            legend = {
                labelFontSize = 7,
                titleFontSize = 7
            },
            text = {
                fontSize = 7
            }
        },
        spacing = 0
    ) +
        [
        @vlplot() +
        @vlplot(
            {:line, clip = true},
            transform = [
                {
                density = :scc,
                bandwidth = 25.0,
                groupby = [:dr],
                steps = 500
            }
            ],
            x = {
                "value:q",
                scale = {domain = [-90.0, 1010.0]},
                axis = {
                    labels = false,
                    ticks = true,
                    domain = true,
                    gridColor = {
                        value = "#ddd"
                    },
                    gridOpacity = {
                        condition = {
                            test = "datum.value===0",
                            value = 1
                        },
                        value = 0
                    },
                    title = nothing
                }
            },
            y = {
                "density:q",
                title = "Density",
                axis = {
                    gridColor = {value = "#ddd"
                    },
                    gridOpacity = {
                        condition = {
                            test = "datum.value===0",
                            value = 0
                        },
                        value = 0
                    },
                    title = nothing,
                    labels = false,
                    ticks = false,
                    domainWidth = 0,
                }
            },
            color = {
                "dr:n",
                title = "Near-term discount rate",
                legend = {orient = "top-right", titleFontWeight = :normal},
                sort = :descending
            },
            opacity = {
                condition = {
                    test = "datum.dr==='2.0%'",
                    value = 1.0
                },
                value = 0.3
            },
            width = 309,
            height = 150
        ) +
        @vlplot(
            :rule,
            data = rule_data,
            x = {"mean_scc"},
            y = {datum = 0.0},
            y2 = :height,
            color = {"dr:n",
                sort = :descending},
            strokeDash = {value = "2,1"}
        ) +
        @vlplot(
            {
                :text,
                align = :left,
                baseline = :bottom,
            },
            data = rule_data,
            text = :label,
            x = "mean_scc",
            y = :height,
            opacity = {
                condition = {
                    test = "datum.dr!='2.0%'",
                    value = 1
                },
                value = 0
            }
        ) +
        @vlplot(
            {
                :text,
                align = :left,
                baseline = :bottom,
                fontWeight = :bold,
                fontSize = 7
            },
            data = rule_data,
            text = :label,
            x = "mean_scc",
            y = :height,
            opacity = {
                condition = {
                    test = "datum.dr=='2.0%'",
                    value = 1
                },
                value = 0
            }
        )
        @vlplot(data = box_whisker_data, y = {"dr:n", axis = nothing, sort = :descending}, color = {"dr:n",
                sort = :descending}, height = {step = 8}) +
        @vlplot(:rule, x = {
                "q05:q",
                axis = {
                    title = "SC-CO₂ (US\$ per tonne of CO₂)",
                    titleFontWeight = :normal,
                    grid = true,
                    gridColor = {
                        value = "#ddd"
                    },
                    gridOpacity = {
                        condition = {
                            test = "datum.value===0",
                            value = 1
                        },
                        value = 0
                    }}
            },
            x2 = "q95:q"
        ) +
        @vlplot({:bar, size = 6}, x = "q25:q", x2 = "q75:q") +
        @vlplot({:tick, size = 6}, x = "median:q", color = {value = :white})
    ]

    p |> save(joinpath(output_dir, "fig2.svg"))

    return p
end
