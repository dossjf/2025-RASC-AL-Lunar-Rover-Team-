import parameters as p
from helper_functions import *
from materials import *
import numpy as np
import matplotlib.pyplot as plt
import itertools

### Size Calculations ###

# Define parameter ranges
diameter_values = np.linspace(0.25, .75, 50)

best_params = None
min_wheel_mass = float('inf')

# Iterate over all combinations
for diameter in diameter_values:
    for grouser_height in np.linspace(diameter*.01, diameter*.1, 50):
        p.outer_diameter = diameter
        p.grouser_height = grouser_height

        slip_values = np.linspace(0.1, 0.5, 20)
        found_valid_slip = False

        for slip in slip_values:
            p.slip_ratio = slip
            normalized_sinkage = .45*slip + .05
            sinkage = normalized_sinkage*p.outer_diameter
            length_of_patch = p.outer_diameter*np.arccos(1 - 2*normalized_sinkage)
            p.width = 1/p.modulus_of_friction * (calc_weight_on_wheel(WheelLocation.BACK, TravelType.UPHILL)/(sinkage*length_of_patch) - p.modulus_of_cohesion)
            front_ll_drawbar_pull = calc_drawbar_pull(WheelLocation.FRONT, TravelType.LEVEL_LINEAR)
            front_up_drawbar_pull = calc_drawbar_pull(WheelLocation.FRONT, TravelType.UPHILL)
            back_ll_drawbar_pull = calc_drawbar_pull(WheelLocation.BACK, TravelType.LEVEL_LINEAR)
            back_up_drawbar_pull = calc_drawbar_pull(WheelLocation.BACK, TravelType.UPHILL)

            level_linear_4x4_pull = 2 * front_ll_drawbar_pull + 2 * back_ll_drawbar_pull
            uphill_4x4_pull = 2 * front_up_drawbar_pull + 2 * back_up_drawbar_pull
            drawbar_pull = min(level_linear_4x4_pull, uphill_4x4_pull)

            if drawbar_pull > 0:
                found_valid_slip = True
                break  # Stop checking slip ratios if we find a valid one

        if not found_valid_slip:
            continue  # Skip this combination if no valid slip is found

        wheel_mass = calc_mass(Aluminum_7075)

        # Check if this is the best configuration
        if wheel_mass < min_wheel_mass:
            min_wheel_mass = wheel_mass
            best_params = (diameter, p.width, grouser_height)

# Output optimal parameters
optimal_diameter, optimal_width, optimal_grouser_height = best_params
p.outer_diameter = optimal_diameter
p.width = optimal_width
p.grouser_height = optimal_grouser_height

print(f"Optimal Diameter: {optimal_diameter:.3f} m")
print(f"Optimal Width: {optimal_width:.3f} m")
print(f"Optimal Grouser Height: {optimal_grouser_height:.3f} m")
print(f"Minimum 4 Wheel + Battery Mass: {min_wheel_mass:.3f} kg")