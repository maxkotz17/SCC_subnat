using MimiGIVE, Mimi, DataFrames, CSVFiles, VegaLite, Query, Statistics, Printf

function plot_extended_figure1()
    output_dir = joinpath(@__DIR__, "..", "output")

    data = load(joinpath(output_dir, "extended_figure1_data.csv"), colparsers = Dict(:dr => String, :damagefunction => String)) |> DataFrame

    panel_prefix = Dict("3.0%" => "a", "2.5%" => "b", "2.0%" => "c", "1.5%" => "d")

    p = data |>
        @mutate(damagefunction = _.damagefunction == "rff" ? "GIVE" :
                                 _.damagefunction == "dice" ? "DICE-2016R" :
                                 _.damagefunction == "hs" ? "Howard & Sterner" : error("Unknown damage function."),
            dr = "$(panel_prefix[_.dr]): $(_.dr) near-term discount rate"
        ) |>
        @vlplot(
            config = {
                font = "Arial",
                style = {cell = {stroke = :transparent}},
                axis = {
                    labelFontSize = 7,
                    titleFontSize = 7,
                    domainColor = :black,
                    tickColor = :black,
                    titleFontWeight = :normal
                },
                legend = {
                    labelFontSize = 7,
                    titleFontSize = 7,
                    orient = :none,
                    legendX = 300
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
        [
        @vlplot(
            transform = [
                {
                    filter = "datum.dr!=='d: 1.5% near-term discount rate'"
                }
            ],
            facet = {
                row = {
                    field = :dr,
                    header = {
                        title = nothing,
                        labelOrient = :top,
                        labelAnchor = :start,
                        labelFontWeight = :bold
                    }
                }
            },
            resolve = {scale = {x = :independent}},
        ) +
        @vlplot(
            mark = {:line, clip = true},
            transform = [
                {
                density = :scc,
                bandwidth = 25.0,
                groupby = [:damagefunction, :dr],
                steps = 500
            }
            ],
            x = {
                "value:q",
                scale = {domain = [-90.0, 1000.0]},
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
                "damagefunction:n",
                title = "Damage function",
            },
            width = 400,
            height = 80
        )
        @vlplot(
            transform = [
                {
                    filter = "datum.dr==='d: 1.5% near-term discount rate'"
                }
            ],
            facet = {
                row = {
                    field = :dr,
                    header = {
                        title = nothing,
                        labelOrient = :top,
                        labelAnchor = :start,
                        labelFontWeight = :bold
                    }
                }
            },
            resolve = {scale = {x = :independent}},
        ) +
        @vlplot(
            mark = {:line, clip = true},
            transform = [
                {
                density = :scc,
                bandwidth = 25.0,
                groupby = [:damagefunction, :dr],
                steps = 500
            }
            ],
            x = {
                "value:q",
                scale = {domain = [-90.0, 1000.0]},
                axis = {
                    labels = true,
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
                    title = "SC-CO₂ (US\$ per tonne of CO₂)"
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
                "damagefunction:n",
                title = "Damage function",
            },
            width = 400,
            height = 80
        )
        ]

    p |> save(joinpath(output_dir, "ext_fig1.svg"))

    return p
end
