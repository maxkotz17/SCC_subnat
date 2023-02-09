using Mimi, CSVFiles, DataFrames

# ------------------------------------------------------------
# Macroeconomic climate damages from mean temp, daily temp variability, total annual precipitation, wet days, extreme daily precip (Kotz. et al 2021, 2022)
# Written by Max Kotz
# Modified by Chris Callahan
# ------------------------------------------------------------

@defcomp subnat_damages begin

	country                 = Index() # Index 
	gcms 					= Index() # Index for different GCM samples

	# input parameters from main_model.jl
	beta1                   = Parameter(index=[gcms,country]) # Linear coefficient relating GMT to %GDP reduction
	beta2                   = Parameter(index=[gcms,country]) # Quadratic coefficient relating GMT to %GDP reduction
	#maxGMT                  = Parameter(index=[country]) # maximum GMT reached in that simulation (for potential capping of impacts)

	# model number for monte carlo sampling
	# set as random variable from main_mcs.jl
	modelnum 				= Parameter(default=10)

	# parameters connected to climate and socioeconomic components
	temperature             = Parameter(index=[time], unit="degC") # Global average surface temperature anomaly relative to pre-industrial (°C).
	gdp                     = Parameter(index=[time, country], unit="billion US\$2005/yr") #national GDP

	# damages variable
	damages                 = Variable(index=[time,country]) #monetary national gdp damage

	function run_timestep(p, v, d, t)

		for c in d.country
			
			# damages as percentage reduction in GDP
			v.damages[t,c] = p.gdp[t,c] * (((p.beta1[Int(p.modelnum),c]/100.0)*p.temperature[t]) + ((p.beta2[Int(p.modelnum),c]/100.0)*(p.temperature[t]^2)))

		end
	end
end

