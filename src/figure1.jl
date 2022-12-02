using MimiGIVE, Mimi, DataFrames, CSVFiles, Query, Dates, Arrow, VegaLite, Statistics, DataValues

function plot_figure1()
    output_dir = joinpath(@__DIR__, "..", "output")

    df_all = load(joinpath(output_dir, "figure1_data.csv")) |>
             DataFrame

    df = df_all |>
         @groupby({_.year, _.variable}) |>
         @map({
             key(_)...,
             q05 = quantile(_.value, 0.05),
             median = quantile(_.value, 0.5),
             q95 = quantile(_.value, 0.95),
             q25 = quantile(_.value, 0.25),
             q75 = quantile(_.value, 0.75)
         }) |>
         DataFrame

    p = @vlplot(
        config = {
            font = "Arial",
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
        },
        columns = 3,
        concat = [
            @vlfrag(
                data = df |> @filter(_.variable == "Population"),
                width = 177,
                height = 177,
                layer = [
                    @vlfrag(
                        title = "a",
                        mark = :line,
                        color = {
                            value = "#5778a4"
                        },
                        x = {
                            "year:t",
                            timeUnit = :year,
                            title = nothing,
                            axis = {
                                labels = false,
                                grid = false
                            }
                        },
                        y = {
                            "median:q",
                            title = "Global population (billion)"
                        }
                    ),
                    @vlfrag(
                        mark = {
                            :errorband,
                            opacity = 0.1
                        },
                        color = {
                            value = "#5778a4"
                        },
                        x = {
                            "year:t",
                            timeUnit = :year,
                            title = nothing
                        },
                        y = {
                            "q05:q",
                            title = "Global population (billion)"
                        },
                        y2 = "q95:q"
                    ),
                    @vlfrag(
                        mark = {
                            :errorband,
                            opacity = 0.3
                        },
                        color = {
                            value = "#5778a4"
                        },
                        x = {
                            "year:t",
                            timeUnit = :year,
                            title = nothing
                        },
                        y = {
                            "q25:q",
                            title = "Global population (billion)"
                        },
                        y2 = "q75:q"
                    )
                ]
            ),
            @vlfrag(
                data = df |> @filter(_.variable == "GDP per capita growth" && _.year > Date(2020)),
                width = 177,
                height = 177,
                layer = [
                    @vlfrag(
                        title = "b",
                        mark = :line,
                        color = {
                            value = "#e49444"
                        },
                        x = {
                            "year:t",
                            timeUnit = :year,
                            title = nothing,
                            axis = {
                                labels = false,
                                grid = false
                            }
                        },
                        y = {
                            "median:q",
                            title = "Average per capita GDP growth rate (2020 to year)",
                            axis = {
                                grid = true,
                                format = "%"
                            }
                        }
                    ),
                    @vlfrag(
                        mark = {
                            :errorband,
                            opacity = 0.1
                        },
                        color = {
                            value = "#e49444"
                        },
                        x = {
                            "year:t",
                            timeUnit = :year,
                            title = nothing,
                            axis = {
                                labels = false,
                                grid = false
                            }
                        },
                        y = {
                            "q05:q",
                            title = "Average per capita GDP growth rate (2020 to year)"
                        },
                        y2 = "q95:q"
                    ),
                    @vlfrag(
                        mark = {
                            :errorband,
                            opacity = 0.3
                        },
                        color = {
                            value = "#e49444"
                        },
                        x = {
                            "year:t",
                            timeUnit = :year,
                            title = nothing,
                            axis = {
                                labels = false,
                                grid = false
                            }
                        },
                        y = {
                            "q25:q",
                            title = "Average per capita GDP growth rate (2020 to year)"
                        },
                        y2 = "q75:q"
                    )
                ]
            ),
            @vlfrag(
                data = df |> @filter(_.variable == "CO₂ emissions"),
                width = 177,
                height = 177,
                layer = [
                    @vlfrag(
                        title = "c",
                        mark = :line,
                        color = {value = "#d1615d"},
                        x = {
                            "year:t",
                            timeUnit = :year,
                            title = nothing,
                            axis = {
                                labels = false,
                                grid = false
                            }
                        },
                        y = {
                            "median:q",
                            title = "Global CO₂ emissions (Gt CO₂)",
                            axis = {
                                grid = true
                            }
                        }
                    ),
                    @vlfrag(
                        mark = {:errorband, opacity = 0.1},
                        color = {value = "#d1615d"},
                        x = {"year:t", timeUnit = :year, title = nothing, axis = {labels = false, grid = false}},
                        y = {"q05:q", title = "Global CO₂ emissions (Gt CO₂)"},
                        y2 = "q95:q"
                    ),
                    @vlfrag(
                        mark = {:errorband, opacity = 0.3},
                        color = {value = "#d1615d"},
                        x = {"year:t", timeUnit = :year, title = nothing, axis = {labels = false, grid = false}},
                        y = {"q25:q", title = "Global CO₂ emissions (Gt CO₂)"},
                        y2 = "q75:q"
                    )
                ]
            ),
            @vlfrag(
                data = df |> @filter(_.variable == "CO₂ concentrations"),
                width = 177,
                height = 177,
                layer = [
                    @vlfrag(
                        title = "d",
                        mark = :line,
                        color = {value = "#85b6b2"},
                        x = {"year:t", timeUnit = :year, title = nothing, axis = {grid = false}},
                        y = {"median:q", title = "Atmospheric CO₂ concentrations (ppm)", axis = {grid = false}}
                    ),
                    @vlfrag(
                        mark = {:errorband, opacity = 0.1},
                        color = {value = "#85b6b2"},
                        x = {"year:t", timeUnit = :year, title = nothing, axis = {grid = false}},
                        y = {"q05:q", title = "Atmospheric CO₂ concentrations (ppm)"},
                        y2 = "q95:q"
                    ),
                    @vlfrag(
                        mark = {:errorband, opacity = 0.3},
                        color = {value = "#85b6b2"},
                        x = {"year:t", timeUnit = :year, title = nothing, axis = {grid = false}},
                        y = {"q25:q", title = "Atmospheric CO₂ concentrations (ppm)"},
                        y2 = "q75:q"
                    )
                ]
            ),
            @vlfrag(
                data = df |> @filter(_.variable == "Temperature"),
                width = 177,
                height = 177,
                layer = [
                    @vlfrag(
                        title = "e",
                        mark = :line,
                        color = {value = "#6a9f58"},
                        x = {"year:t", timeUnit = :year, title = "Year", axis = {grid = false}},
                        y = {"median:q", title = ["Global surface temperature change", "relative to 1850-1900 (°C)"], axis = {grid = false}}
                    ),
                    @vlfrag(
                        mark = {:errorband, opacity = 0.1},
                        color = {value = "#6a9f58"},
                        x = {"year:t", timeUnit = :year, title = "Year", axis = {grid = false}},
                        y = {"q05:q", title = ["Global surface temperature change", "relative to 1850-1900 (°C)"]},
                        y2 = "q95:q"
                    ),
                    @vlfrag(
                        mark = {:errorband, opacity = 0.3},
                        color = {value = "#6a9f58"},
                        x = {"year:t", timeUnit = :year, title = "Year", axis = {grid = false}},
                        y = {"q25:q", title = ["Global surface temperature change", "relative to 1850-1900 (°C)"]},
                        y2 = "q75:q"
                    )
                ]
            ),
            @vlfrag(
                data = df |> @filter(_.variable == "Sea-level rise"),
                width = 177,
                height = 177,
                layer = [
                    @vlfrag(
                        title = "f",
                        mark = :line,
                        color = {value = "#e7ca60"},
                        x = {"year:t", timeUnit = :year, title = nothing, axis = {grid = false}},
                        y = {"median:q", title = "Global mean sea level change relative to 1900 (m)", axis = {grid = false}}
                    ),
                    @vlfrag(
                        mark = {:errorband, opacity = 0.2},
                        color = {value = "#e7ca60"},
                        x = {"year:t", timeUnit = :year, title = nothing, axis = {grid = false}},
                        y = {"q05:q", title = "Global mean sea level change relative to 1900 (m)"},
                        y2 = "q95:q"
                    ),
                    @vlfrag(
                        mark = {:errorband, opacity = 0.4},
                        color = {value = "#e7ca60"},
                        x = {"year:t", timeUnit = :year, title = nothing, axis = {grid = false}},
                        y = {"q25:q", title = "Global mean sea level change relative to 1900 (m)"},
                        y2 = "q75:q"
                    )
                ]
            ),
        ]
    )

    p |> save(joinpath(output_dir, "fig1.svg"))

    return p
end
