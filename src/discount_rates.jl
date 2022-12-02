discount_rates = [
    (label = "1.5%", prtp = exp(9.149606e-05) - 1, eta = 1.016010e+00), (label = "2.0%", prtp = exp(0.001972641) - 1, eta = 1.244458999), (label = "2.5%", prtp = exp(0.004618784) - 1, eta = 1.421158088), (label = "3.0%", prtp = exp(0.007702711) - 1, eta = 1.567899391),
]

# Export the discount rates to use for Table 1 Calculations of (1) DICE and (2) 
# DICE + RFF Socioeconomics

dice_discount_rates = [
    # Constant discount rates
    (label = "CR 1%", prtp = 0.01, eta = 0.0), (label = "CR 2%", prtp = 0.02, eta = 0.0), (label = "CR 2.5%", prtp = 0.025, eta = 0.0), (label = "CR 3%", prtp = 0.03, eta = 0.0), (label = "CR 5%", prtp = 0.05, eta = 0.0),
    # Ramsey discount rates calibrated a la NPP
    (label = "1.5%", prtp = exp(9.149606e-05) - 1, eta = 1.016010e+00), (label = "2.0%", prtp = exp(0.001972641) - 1, eta = 1.244458999), (label = "2.5%", prtp = exp(0.004618784) - 1, eta = 1.421158088), (label = "3.0%", prtp = exp(0.007702711) - 1, eta = 1.567899391),
    # Other Ramsey discount rates
    (label = "DICE2016", prtp = 0.015, eta = 1.45)
]
