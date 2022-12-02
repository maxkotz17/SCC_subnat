module Mimi_NAS_pH


# Load required packages.
using CSVFiles, DataFrames, Mimi

# Load Ocean pH Mimi component.
include(joinpath("components", "ocean_ph_component.jl"))

# Load example CO₂ concentration data to run the Ocean pH function.
co2_data = DataFrame(load(joinpath(@__DIR__, "..", "data", "ssp_co2_concentrations.csv"), skiplines_begin=4))


# Create a function to set up and run the Ocean pH compoennt as a stand-alone Mimi model.
# 'ssp_emissions_scenario' options = "SSP1-19", "SSP1-26", "SSP2-45", "SSP3-70", "SSP5-85"
function get_model(;ssp_emissions_scenario::String="SSP1-19")

    # Initialize a Mimi model.
    m = Model()

    # Set time dimension.
    set_dimension!(m, :time, collect(1950:2100))

    # Add in ocean pH Mimi component.
    add_comp!(m, ocean_pH)

    # Set ocean pH parameters.
    set_param!(m, :ocean_pH, :β1, -0.3671)
    set_param!(m, :ocean_pH, :β2, 10.2328)
    set_param!(m, :ocean_pH, :pH_0, 8.123)
    set_param!(m, :ocean_pH, :atm_co2_conc, co2_data[:, ssp_emissions_scenario])

    # Return ocean pH model.
    return m
end

end #module
