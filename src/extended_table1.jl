using MimiGIVE, Mimi, DataFrames, CSVFiles, Statistics

function compute_extended_table1_data(results)
    df_final = DataFrame(damagefunction = Symbol[], dr = String[], expected_scc = Float64[], se_scc = Float64[], q05_scc = Float64[], q95_scc = Float64[])

    for (damagefunction, res) in results
        for (k, v) in res[:scc]
            if damagefunction != :rff || k.sector == :total
                push!(df_final, (
                    damagefunction = damagefunction,
                    dr = k.dr_label,
                    expected_scc = v.expected_scc * pricelevel_2005_to_2020,
                    se_scc = v.se_expected_scc * pricelevel_2005_to_2020,
                    q05_scc = quantile(v.sccs, 0.05) * pricelevel_2005_to_2020,
                    q95_scc = quantile(v.sccs, 0.95) * pricelevel_2005_to_2020,
                )
                )
            end
        end
    end

    output_dir = joinpath(@__DIR__, "..", "output")
    mkpath(output_dir)

    df_final |> save(joinpath(output_dir, "extended_table1_data.csv"))
end
