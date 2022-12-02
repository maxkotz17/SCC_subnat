using Mimi, CSVFiles, DataFrames

# ------------------------------------------------------------
# Macroeconomic climate damages from mean temp, daily temp variability, total annual precipitation, wet days, extreme daily precip (Kotz. et al 2021, 2022)
# ------------------------------------------------------------

@defcomp subnat_damages begin

	country                 = Index() # Index 

	#previous version which passed betas and maxGMT from main_model.jl, now implemented below to encompass MCS of different damage parameters
	beta1                   = Parameter(index=[country]) # Linear coefficient relating GMT to %GDP reduction
	beta2                   = Parameter(index=[country]) # Quadratic coefficient relating GMT to %GDP reduction
	maxGMT                  = Parameter(index=[country]) # maximum GMT reached in that simulation (for potential capping of impacts)

	#select damage parameters for results from particular climate model simulation
#	model_num               = Parameter(default=1)
#	subnat_params           = Parameter(index=[country,21*3+1])
#	subnat_params           = DataFrame(load(joinpath(@__DIR__, "..", "data","subnat_dam_params","PERC_scaling_coefs_ssp1_lagdiff_lintren_NL_3_fixflex__N=100.csv")))
#	beta2                   = subnat_params[:,"m" * string(model_num) * "_beta2"]
#	beta1                   = subnat_params[:,"m" * string(model_num) * "_beta1"]
#	maxGMT                  = subnat_params[:,"m" * string(model_num) * "_maxGMT"]

	#parameters connected to climate and socioeconomic components
	temperature             = Parameter(index=[time], unit="degC") # Global average surface temperature anomaly relative to pre-industrial (°C).
	gdp                     = Parameter(index=[time, country], unit="billion US\$2005/yr") #national GDP

	#old variable damfrac caused bugs
	#damfrac                 = Variable(index=[time,country]) #fraction of national gdp reduced
	damages                 = Variable(index=[time,country]) #monetary national gdp damage

	function run_timestep(p, v, d, t)

		for c in d.country

			#calculate percentage reduction - for some reason this two step calculation caused bugs
			#v.damfrac[t,c]=(100.0+p.beta1[c] * p.temperature[t] + p.beta2[c] * p.temperature[t]^2)/100.0
			#v.damages[t,c]=v.damfrac[t,c] * p.gdp[t,c]
			#updated version of calculation
			v.damages[t,c] = p.gdp[t,c] * (100.0+p.beta1[c] * p.temperature[t] + p.beta2[c] * p.temperature[t]^2)/100.0		    

		end
	end
end

