import numpy as np
import matplotlib.pyplot as plt
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

# Define wheel width range
width_values = np.linspace(0.0001, p.outer_diameter, num=500)
normalized_width = width_values/p.outer_diameter

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
    normalized_sinkage = .25*slip + .05
    sinkage = normalized_sinkage*p.outer_diameter
    length_of_patch = p.outer_diameter*np.arccos(1 - 2*normalized_sinkage)
    # min_width = (1/p.modulus_of_friction) * ((calc_weight_on_wheel(WheelLocation.BACK, TravelType.UPHILL) / np.power(sinkage,p.sinkage_constant)*length_of_patch) - p.modulus_of_cohesion)
    min_width = calc_Terzaghi_soil_bearing_width(calc_weight_on_wheel(WheelLocation.BACK, TravelType.UPHILL), length_of_patch, sinkage)

    drawbar_line, = plt.plot(normalized_width, drawbar_pull_results[slip], label=f"Slip {slip}")
    line_color = drawbar_line.get_color()

    plt.axvline(min_width/p.outer_diameter, linestyle="--", linewidth=1, label="Minimum Soil Bearing Capacity", color=line_color)

plt.xlabel("Normalized Wheel Width (~)")
plt.ylabel("Drawbar Pull (N)")
plt.title(f"Drawbar Pull vs. Normalized Wheel Width at Different Slip Ratios \n(Diameter={p.outer_diameter}m, Grouser Height = {p.grouser_height}m, Grouser Number = {calc_number_of_grousers()})")
plt.legend()
plt.grid()
plt.savefig("images/drawbar_pull_vs_width.png", dpi=300)
