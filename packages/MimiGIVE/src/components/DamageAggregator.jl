using Mimi

@defcomp DamageAggregator begin

    fund_regions = Index()
    country = Index()
    energy_countries = Index()

    include_cromar_mortality = Parameter{Bool}(default=true) # default TRUE
    include_ag = Parameter{Bool}(default=true) # default TRUE
    include_slr = Parameter{Bool}(default=true) # default TRUE - will run SLR after the main model
    include_energy = Parameter{Bool}(default=true) # default TRUE
    include_dice2016R2 = Parameter{Bool}(default=false)
    include_hs_damage = Parameter{Bool}(default=false)
    include_subnatdam = Parameter{Bool}(default=false)

    damage_cromar_mortality = Parameter(index=[time,country], unit="US\$2005/yr")
    damage_ag = Parameter(index=[time,fund_regions], unit="billion US\$2005/yr")
    damage_energy = Parameter(index=[time,energy_countries], unit="billion US\$2005/yr")
    damage_dice2016R2 = Parameter(index=[time], unit="billion US\$2005/yr")
    damage_hs = Parameter(index=[time], unit="billion US\$2005/yr")
    damage_subnat = Parameter(index=[time,country], unit="billion US\$2005/yr")

    gdp = Parameter(index=[time,country], unit="billion US\$2005/yr")

    total_damage = Variable(index=[time], unit="US\$2005/yr")
    total_damage_share = Variable(index=[time])
    total_damage_domestic = Variable(index=[time], unit="US\$2005/yr")

    ## global annual aggregates - for interim model outputs and partial SCCs
    cromar_mortality_damage         = Variable(index=[time], unit="US\$2005/yr")
    agriculture_damage              = Variable(index=[time], unit="US\$2005/yr")
    energy_damage                   = Variable(index=[time], unit="US\$2005/yr")
    subnat_damage                   = Variable(index=[time], unit="US\$2005/yr")

    ## domestic annual aggregates - for interim model outputs and partial SCCs
    cromar_mortality_damage_domestic         = Variable(index=[time], unit="US\$2005/yr")
    agriculture_damage_domestic              = Variable(index=[time], unit="US\$2005/yr")
    energy_damage_domestic                   = Variable(index=[time], unit="US\$2005/yr")
  
    #print("hello world damage_aggregator")

    function run_timestep(p, v, d, t)

        ## global annual aggregates - for interim model outputs and partial SCCs
        v.cromar_mortality_damage[t]        = sum(p.damage_cromar_mortality[t,:])
        v.agriculture_damage[t]             = sum(p.damage_ag[t,:]) * 1e9 
        v.energy_damage[t]                  = sum(p.damage_energy[t,:]) * 1e9
        v.subnat_damage[t]                  = sum(p.damage_subnat[t,:]) * 1e9

        v.total_damage[t] =
            (p.include_cromar_mortality ? v.cromar_mortality_damage[t] : 0.) +
            (p.include_ag               ? v.agriculture_damage[t] : 0.) +
            (p.include_energy           ? v.energy_damage[t] : 0.) +
            (p.include_dice2016R2       ? p.damage_dice2016R2[t] * 1e9 : 0.) +
            (p.include_hs_damage        ? p.damage_hs[t] * 1e9 : 0.) + 
            (p.include_subnatdam        ? v.subnat_damage[t] : 0.)

        gdp = sum(p.gdp[t,:]) * 1e9

        v.total_damage_share[t] = v.total_damage[t] / gdp

        ## domestic annual aggregates - for interim model outputs and partial SCCs
        v.cromar_mortality_damage_domestic[t]           = p.damage_cromar_mortality[t,174]
        v.agriculture_damage_domestic[t]                = p.damage_ag[t,1] * 1e9 
        v.energy_damage_domestic[t]                     = p.damage_energy[t,12] * 1e9
        
        # Calculate domestic damages
        v.total_damage_domestic[t] =
            (p.include_cromar_mortality ? v.cromar_mortality_damage_domestic[t] : 0.) +
            (p.include_ag               ? v.agriculture_damage_domestic[t] : 0.) +
            (p.include_energy           ? v.energy_damage_domestic[t] : 0.)
    end
end

