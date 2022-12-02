num_trials = 3
our_seed = 24523438

if length(ARGS) == 1
    num_trials = parse(Int, ARGS[1])
end

println("Running $num_trials trials.")

using Dates, Distributed

ENV["JULIA_WORKER_TIMEOUT"] = 2592000
ENV["DATADEPS_ALWAYS_ACCEPT"] = "true"

@info "Starting simulation at $(now())"

# Install required Julia packages if they are not already installed
@everywhere using Pkg
@everywhere Pkg.activate(joinpath(@__DIR__, ".."))
@everywhere ENV["JULIA_WORKER_TIMEOUT"] = 2592000
Pkg.instantiate()

# Trigger download of data files
using MimiRFFSPs
MimiRFFSPs.datadep"rffsps_v5"

@everywhere include("include_main.jl")

results = run_dice(our_seed)
save("Dice_output.csv",results)

results = run_subnatdam(our_seed)
save("subnnatdam_output.csv",results)

#@sync begin
    #global result_dice_original_scc = @spawn compute_dice_original_scc(our_seed)

    #global results_rff_scc = @spawn compute_rff_scc(num_trials, our_seed)

    #global results_dice_scc = @spawn compute_dice_scc(num_trials, our_seed)

    #global results_hs_scc = @spawn compute_hs_scc(num_trials, our_seed)

    #global results_subnatdam_scc = @spawn compute_subnatdam_scc(num_trials, our_seed)

#    results = @spawn run_subnatdam(our_seed)

  #  global fig2_results = @spawn begin
  #      data = fetch(results_rff_scc)
  #      compute_figure2_data(data)
  #  end

  #  global fig1_results = @spawn compute_figure1_data(num_trials, our_seed)

  #  global fig3_results = @spawn begin
  #      data = fetch(results_rff_scc)
  #      compute_figure3_data(data)
  #  end

  #  @spawn begin
  #      fetch(fig2_results)
  #      plot_figure2()
  #  end

  #  @spawn begin
  #      fetch(fig1_results)
  #      plot_figure1()
  #  end

  #  @spawn begin
  #      fetch(fig3_results)
  #      plot_figure3()
  #  end

  #  @spawn begin
  #      data_rff = fetch(results_rff_scc)
  #      data_dice = fetch(results_dice_scc)
  #      data_hs = fetch(results_hs_scc)

  #      compute_extended_table1_data(
  #          Dict(
  #              :rff => data_rff,
  #              :dice => data_dice,
  #              :hs => data_hs
  #          )
  #      )
  #  end

  #  global extended_figure1_result = @spawn begin
  #      data_rff = fetch(results_rff_scc)
  #      data_dice = fetch(results_dice_scc)
  #      data_hs = fetch(results_hs_scc)

  #      compute_extended_figure1_data(
  #          Dict(
  #              :rff => data_rff,
  #              :dice => data_dice,
  #              :hs => data_hs
  #          )
  #      )
  #  end

  #  @spawn begin
  #      fetch(extended_figure1_result)
  #      plot_extended_figure1()
  #  end

  #  global extended_figure2_result = @spawn compute_extended_figure2_data(num_trials, our_seed)

  #  @spawn begin
  #      fetch(extended_figure2_result)
  #      plot_extended_figure2()
  #  end

  #  @spawn begin
  #      data_dice_original_scc = fetch(result_dice_original_scc)
  #      data_dice2016_scc = fetch(results_dice_scc)
  #      data_give_scc = fetch(results_rff_scc)
  #       data_subnatdam_scc = fetch(results_subnatdam_scc)
  #       println(data_subnatdam_scc)
  #      compute_table1_data(data_give_scc, data_dice2016_scc, data_dice_original_scc, data_subnatdam_scc)
  #      compute_table1_data(data_subnatdam_scc)
        
  #  end
#end

@info "Finished simulation at $(now())"
