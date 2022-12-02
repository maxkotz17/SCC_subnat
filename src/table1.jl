using MimiGIVE, Mimi, DataFrames, CSVFiles, Query, Printf

function compute_table1_data(give_scc, data_dice2016_scc, data_dice_original_scc, data_subnatdam_scc)
    df_final = DataFrame(label = String[], scc = String[])

    results_original_dice = data_dice_original_scc |>
                            @filter(_.label == "DICE2016") |>
                            @map(_.scc) |>
                            first

    result_dice2016_3perc = data_dice2016_scc[:scc] |>
                            @filter(_.first.dr_label == "3.0%") |>
                            @map(_.second) |>
                            first

    result_give_3perc = give_scc[:scc] |>
                        @filter(_.first.dr_label == "3.0%" && _.first.sector == :total) |>
                        @map(_.second) |>
                        first

    result_give = give_scc[:scc] |>
                  @filter(_.first.dr_label == "2.0%" && _.first.sector == :total) |>
                  @map(_.second) |>
                  first

    result_subnatdam = data_subnatdam_scc[:scc] |>
                  @filter(_.first.dr_label == "2.0") |>
                  @map(_.second) |>
                  first

    push!(df_final, (label = "Original DICE2016", scc = @sprintf("\$%0.f", results_original_dice)))
    push!(df_final, (label = "RFFSP, FAIR, DICE DAMAGE, 3%", scc = @sprintf("\$%0.f", result_dice2016_3perc.expected_scc * pricelevel_2005_to_2020)))
    push!(df_final, (label = "This study with 3% DR", scc = @sprintf("\$%0.f", result_give_3perc.expected_scc * pricelevel_2005_to_2020)))
    push!(df_final, (label = "This study", scc = @sprintf("\$%0.f", result_give.expected_scc * pricelevel_2005_to_2020)))
    push!(df_final, (label = "Sub-nat dams", scc = @sprintf("\$%0.f", result_subnatdam * pricelevel_2005_to_2020)))

    output_dir = joinpath(@__DIR__, "..", "output")
    mkpath(output_dir)

    df_final |> save(joinpath(output_dir, "table1_data.csv"))
end

