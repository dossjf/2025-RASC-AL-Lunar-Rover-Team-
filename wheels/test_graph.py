import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import parameters as p
from helper_functions import *

def calc_Terzaghi_soil_bearing_width(weight, length, sinkage):

    # Lunar
    # c = 170 # cohesion of the soil [Pa]
    # Nc = 48.09 # Terzaghi factor
    # gamma = 2470 # unit weight of the soil
    # Nq = 32.23 # Terzaghi factor
    # Ngamma = 33.27 # Terzaghi factor

    # Dry Sand
    phi = 28
    phi_rad = np.radians(phi)
    Nq = np.exp(np.pi * np.tan(phi_rad)) * np.tan(np.radians(45) + phi_rad / 2) ** 2
    Nc = (Nq - 1) / np.tan(phi_rad) if phi_rad != 0 else 5.7  # use default for phi = 0
    Ngamma = 2 * (Nq + 1) * np.tan(phi_rad)
    c = 170 # cohesion of the soil [Pa]
    gamma = 16000 # unit weight of the soil

    a = .5*gamma*length*Ngamma
    b = length*c*Nc + gamma*sinkage*Nq*length
    c_ = -weight

    discriminant = b**2 - 4*a*c_

    if discriminant < 0:
        print("No real solution for wheel width (B)")
    else:
        B1 = (-b + np.sqrt(discriminant)) / (2*a)
        B2 = (-b - np.sqrt(discriminant)) / (2*a)

        # Return the positive root
        B = max(B1, B2)

    return B

# Load the data from the CSV file
data = pd.read_csv('testing/data.csv')

# Extract the necessary columns for plotting
normalized_width_data = data['Normalized Width']
drawbar_pull_data = data['Drawbar Pull [N]']

# Define wheel width range
width_values = np.linspace(.05, p.outer_diameter, num=100)
normalized_width_vals = width_values / p.outer_diameter

# Store results
slip = 0.6
p.slip_ratio = slip
p.outer_diameter = .25
p.grouser_height = .0067
p.mass_of_rover = p.mass_of_rover*.75
p.mass_of_max_payload = p.mass_of_max_payload*.25
drawbar_pull_results = []

# Test sand
# p.modulus_of_cohesion = 990
# p.modulus_of_friction = 1528000
# p.shear_deformation_modulus = .075
# p.soil_cohesion = 1040
# p.cohesive_modulus_of_soil_deformation = 5
# p.density_modulus_of_soil_deformation = 50
# p.soil_weight_density = 1800
# p.sinkage_constant = 1.1

# Iterate through wheel widths and calculate drawbar pull
for width in width_values:
    p.width = width  # Update parameter
    front_ll_drawbar_pull = calc_drawbar_pull(WheelLocation.FRONT, TravelType.LEVEL_LINEAR)
    back_ll_drawbar_pull = calc_drawbar_pull(WheelLocation.BACK, TravelType.LEVEL_LINEAR)
    
    # Total 4x4 drawbar pull
    drawbar_pull = 2 * (front_ll_drawbar_pull + back_ll_drawbar_pull)
    drawbar_pull_results.append(drawbar_pull)

# Calculate sinkage and min_width
normalized_sinkage = 0.25 * slip + 0.05
sinkage = normalized_sinkage * p.outer_diameter
length_of_patch = p.outer_diameter * np.arccos(1 - 2 * normalized_sinkage)
#min_width = (1 / p.density_modulus_of_soil_deformation) * ((calc_weight_on_wheel(WheelLocation.BACK, TravelType.UPHILL) / np.power(sinkage, p.sinkage_constant) * length_of_patch) - p.cohesive_modulus_of_soil_deformation)
min_width = calc_Terzaghi_soil_bearing_width(200, length_of_patch, sinkage)

# Create a single plot
plt.figure(figsize=(8, 6))

# Scatter plot for the data from the CSV
plt.scatter(normalized_width_data, drawbar_pull_data, marker='o', linestyle='-', color='b', label="Test Results Drawbar Pull")

# Line plot for calculated results
drawbar_line, = plt.plot(normalized_width_vals, drawbar_pull_results, label=f"Bekker (Dry Sand) Slip: {slip}", color='r')

# Plot for minimum width
plt.axvline(min_width / p.outer_diameter, linestyle="--", linewidth=1, label="Terzaghi Minimum Soil Bearing Capacity (Dry Sand)", color=drawbar_line.get_color())

# Label the axes and title
plt.xlabel("Normalized Width")
plt.ylabel("Drawbar Pull [N]")
plt.title(f"Drawbar Pull vs Normalized Width \n(Diameter={p.outer_diameter}m, Grouser Height={p.grouser_height}m)")

# Display the legend
plt.legend()

# Add gridlines for readability
plt.grid(True)

# Save the combined plot
plt.savefig("images/test_drawbar_pull_vs_normalized_width.png", dpi=300)
