import numpy as np
import matplotlib.pyplot as plt
import parameters as p
from helper_functions import calc_drawbar_pull, WheelLocation, TravelType, calc_number_of_grousers

# Define wheel width range
width_values = np.linspace(0.1, 0.75, num=50)

# Define slip ratios
slip_values = [0.1, 0.2, 0.3, 0.5]

# Store results
drawbar_pull_results = {slip: [] for slip in slip_values}

# Iterate through wheel widths and calculate drawbar pull
for width in width_values:
    p.width = width  # Update parameter
    for slip in slip_values:
        p.slip_ratio = slip  # Set slip ratio
        front_ll_drawbar_pull = calc_drawbar_pull(WheelLocation.FRONT, TravelType.LEVEL_LINEAR)
        back_ll_drawbar_pull = calc_drawbar_pull(WheelLocation.BACK, TravelType.LEVEL_LINEAR)
        
        # Total 4x4 drawbar pull
        drawbar_pull = 2 * (front_ll_drawbar_pull + back_ll_drawbar_pull)
        drawbar_pull_results[slip].append(drawbar_pull)

# Plot results
plt.figure(figsize=(8, 6))
for slip in slip_values:
    plt.plot(width_values, drawbar_pull_results[slip], label=f"Slip {slip}")

plt.xlabel("Wheel Width (m)")
plt.ylabel("Drawbar Pull (N)")
plt.title(f"Drawbar Pull vs. Wheel Width at Different Slip Ratios \n(Diameter={p.outer_diameter}m, Grouser Height = {p.grouser_height}m, Grouser Number = {calc_number_of_grousers()})")
plt.legend()
plt.grid()
plt.savefig("wheels/images/drawbar_pull_vs_width.png", dpi=300)
plt.show()
