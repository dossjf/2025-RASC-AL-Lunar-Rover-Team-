import parameters as p
from helper_functions import calc_power, calc_torque, calc_drawbar_pull, WheelLocation, TravelType, calc_mass, calc_battery_mass, calc_number_of_grousers
from materials import *
import numpy as np
import matplotlib.pyplot as plt
import itertools

### Size Calculations ###

print(calc_number_of_grousers())

# Define parameter ranges
diameter_values = np.linspace(0.25, .75, int(75-25))
width_values = np.linspace(0.1, 0.5, int(46/4))
grouser_height_values = np.linspace(0.005, 0.05, int(100/8))

best_params = None
min_total_mass = float('inf')

# Iterate over all combinations
for diameter, width, grouser_height in itertools.product(diameter_values, width_values, grouser_height_values):
    p.outer_diameter = diameter
    p.width = width
    p.grouser_height = grouser_height

    slip_values = np.linspace(0.1, 0.75, 20)
    found_valid_slip = False

    for slip in slip_values:
        p.slip_ratio = slip
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
    battery_mass = calc_battery_mass()
    total_mass = wheel_mass + battery_mass

    # Check if this is the best configuration
    if total_mass < min_total_mass:
        min_total_mass = total_mass
        best_params = (diameter, width, grouser_height)

# Output optimal parameters
optimal_diameter, optimal_width, optimal_grouser_height = best_params
p.outer_diameter = optimal_diameter
p.width = optimal_width
p.grouser_height = optimal_grouser_height

print(f"Optimal Diameter: {optimal_diameter:.3f} m")
print(f"Optimal Width: {optimal_width:.3f} m")
print(f"Optimal Grouser Height: {optimal_grouser_height:.3f} m")
print(f"Minimum 4 Wheel + Battery Mass: {min_total_mass:.3f} kg")

## Force Power Calculations ##

slip_values = np.linspace(0.1, .5, 999)

for slip in slip_values:
    p.slip_ratio = slip  # Update slip ratio in parameters
    front_ll_drawbar_pull = calc_drawbar_pull(WheelLocation.FRONT, TravelType.LEVEL_LINEAR)
    front_up_drawbar_pull = calc_drawbar_pull(WheelLocation.FRONT, TravelType.UPHILL)
    back_ll_drawbar_pull = calc_drawbar_pull(WheelLocation.BACK, TravelType.LEVEL_LINEAR)
    back_up_drawbar_pull = calc_drawbar_pull(WheelLocation.BACK, TravelType.UPHILL)

    level_linear_4x4_pull = 2*front_ll_drawbar_pull + 2*back_ll_drawbar_pull
    uphill_4x4_pull = 2*front_up_drawbar_pull + 2*back_up_drawbar_pull
    drawbar_pull = min(level_linear_4x4_pull, uphill_4x4_pull)

    if drawbar_pull > 0:
        print(f"Found positive drawbar pull at slip ratio: {slip:.3f}")
        print(f"Drawbar Pull: {drawbar_pull:.3f} N")
        break
else:
    print("No positive drawbar pull found within slip range 0-1.")

# Wheel Calcs
front_ll_torque = calc_torque(WheelLocation.FRONT, TravelType.LEVEL_LINEAR)
front_ll_power = calc_power(WheelLocation.FRONT, TravelType.LEVEL_LINEAR)
front_ll_drawbar_pull = calc_drawbar_pull(WheelLocation.FRONT, TravelType.LEVEL_LINEAR)

front_up_torque = calc_torque(WheelLocation.FRONT, TravelType.UPHILL)
front_up_power = calc_power(WheelLocation.FRONT, TravelType.UPHILL)
front_up_drawbar_pull = calc_drawbar_pull(WheelLocation.FRONT, TravelType.UPHILL)

back_ll_torque = calc_torque(WheelLocation.BACK, TravelType.LEVEL_LINEAR)
back_ll_power = calc_power(WheelLocation.BACK, TravelType.LEVEL_LINEAR)
back_ll_drawbar_pull = calc_drawbar_pull(WheelLocation.BACK, TravelType.LEVEL_LINEAR)

back_up_torque = calc_torque(WheelLocation.BACK, TravelType.UPHILL)
back_up_power = calc_power(WheelLocation.BACK, TravelType.UPHILL)
back_up_drawbar_pull = calc_drawbar_pull(WheelLocation.BACK, TravelType.UPHILL)

level_linear_4x4_pull = 2*front_ll_drawbar_pull + 2*back_ll_drawbar_pull
uphill_4x4_pull = 2*front_up_drawbar_pull + 2*back_up_drawbar_pull
drawbar_pull = min(level_linear_4x4_pull, uphill_4x4_pull)

level_linear_4x4_power = 2*front_ll_power + 2*back_ll_power
uphill_4x4_power = 2*front_up_power + 2*back_up_power
max_power = max(level_linear_4x4_power, uphill_4x4_power)

print("\n--- Torque and Power Calculations ---\n")

print(f"{'Wheel Position':<15} | {'Travel Type':<15} | {'Torque [Nm]':<15} | {'Power [W]':<15} | {'Speed [rad/s]'}")
print("-" * 85)

print(f"{'Front':<15} | {'Level Linear':<15} | {front_ll_torque:<15.3f} | {front_ll_power:<15.3f} | {p.max_angular_velocity:<15.3f}")
print(f"{'Front':<15} | {'Uphill':<15} | {front_up_torque:<15.3f} | {front_up_power:<15.3f} | {p.min_angular_velocity:<15.3f}")
print(f"{'Back':<15} | {'Level Linear':<15} | {back_ll_torque:<15.3f} | {back_ll_power:<15.3f} | {p.max_angular_velocity:<15.3f}")
print(f"{'Back':<15} | {'Uphill':<15} | {back_up_torque:<15.3f} | {back_up_power:<15.3f} | {p.min_angular_velocity:<15.3f}")

print(f"\nSlip: {p.slip_ratio:.3f} [~]")
print(f"Drawbar Pull: {drawbar_pull:.3f} [N]")
print(f"Total Power: {max_power:.3f} [W]")
print(f"Number of Grousers: {calc_number_of_grousers()} [~]")

## Material Selection Calculations ##

# Calculate mass for each material
mass_ti = calc_mass(Ti_6Al_4V)
mass_steel = calc_mass(Stainless_Steel)
mass_al = calc_mass(Aluminum_7075)
mass_inconel = calc_mass(Inconel_718)

# Print results in a structured format
print("\n--- Material Mass Calculations ---\n")#
print(f"{'Material':<20} | {'Density (kg/m³)':<20} | {'Mass 4 Wheel (kg)'}")
print("-" * 60)
print(f"{Ti_6Al_4V.name:<20} | {Ti_6Al_4V.density:<20.1f} | {mass_ti:.3f}")
print(f"{Stainless_Steel.name:<20} | {Stainless_Steel.density:<20.1f} | {mass_steel:.3f}")
print(f"{Aluminum_7075.name:<20} | {Aluminum_7075.density:<20.1f} | {mass_al:.3f}")
print(f"{Inconel_718.name:<20} | {Inconel_718.density:<20.1f} | {mass_inconel:.3f}")

wheel_mass = calc_mass(Aluminum_7075)

# ## Diameter ##
# diameter_values = np.linspace(.25, 1, 76)
# valid_diameters = []
# total_mass = []

# for diameter in diameter_values:
#     p.outer_diameter = diameter 
#     slip_values = np.linspace(0.01, .99, 99)
#     found_valid_slip = False

#     for slip in slip_values:
#         p.slip_ratio = slip  # Update slip ratio in parameters
#         front_ll_drawbar_pull = calc_drawbar_pull(WheelLocation.FRONT, TravelType.LEVEL_LINEAR)
#         front_up_drawbar_pull = calc_drawbar_pull(WheelLocation.FRONT, TravelType.UPHILL)
#         back_ll_drawbar_pull = calc_drawbar_pull(WheelLocation.BACK, TravelType.LEVEL_LINEAR)
#         back_up_drawbar_pull = calc_drawbar_pull(WheelLocation.BACK, TravelType.UPHILL)

#         level_linear_4x4_pull = 2*front_ll_drawbar_pull + 2*back_ll_drawbar_pull
#         uphill_4x4_pull = 2*front_up_drawbar_pull + 2*back_up_drawbar_pull
#         drawbar_pull = min(level_linear_4x4_pull, uphill_4x4_pull)

#         if drawbar_pull > 0:
#             print(f"Found positive drawbar pull at slip ratio: {slip:.3f}")
#             print(f"Drawbar Pull: {drawbar_pull:.3f} N")
#             found_valid_slip = True
#             break

#     if not found_valid_slip:
#         print(f"No positive drawbar pull found for diameter {diameter:.3f} m. Skipping.")
#         continue

#     wheel_mass = calc_mass(Aluminum_7075)
#     battery_mass = calc_battery_mass()
#     total_mass.append(wheel_mass + battery_mass)
#     valid_diameters.append(diameter)

# valid_diameters = np.array(valid_diameters)
# total_mass = np.array(total_mass)

# if len(valid_diameters) > 0:
#     # Find the optimal diameter that minimizes total mass
#     min_mass_index = np.argmin(total_mass)
#     optimal_diameter = valid_diameters[min_mass_index]
#     p.outer_diameter = optimal_diameter
    
#     plt.figure(figsize=(8, 6))
#     plt.plot(valid_diameters, total_mass, marker='o', linestyle='-', color='b', label="Total Mass")
#     plt.axvline(optimal_diameter, color='r', linestyle='--', label=f"Optimal Diameter: {optimal_diameter:.3f} m")
#     plt.xlabel("Diameter (m)")
#     plt.ylabel("Total Mass (kg)")
#     plt.title(f"Total Mass vs. Diameter (Width = {p.width}m, Grouser Height = {p.grouser_height}m)")
#     plt.legend()
#     plt.grid(True)
#     plt.savefig("wheels/images/total_mass_vs_diameter.png", dpi=300)

# ## Width ##
# width_values = np.linspace(.05, .5, 46)
# valid_widths = []
# total_mass = []

# for width in width_values:
#     p.width = width
#     slip_values = np.linspace(0.01, .99, 99)
#     found_valid_slip = False

#     for slip in slip_values:
#         p.slip_ratio = slip  # Update slip ratio in parameters
#         front_ll_drawbar_pull = calc_drawbar_pull(WheelLocation.FRONT, TravelType.LEVEL_LINEAR)
#         front_up_drawbar_pull = calc_drawbar_pull(WheelLocation.FRONT, TravelType.UPHILL)
#         back_ll_drawbar_pull = calc_drawbar_pull(WheelLocation.BACK, TravelType.LEVEL_LINEAR)
#         back_up_drawbar_pull = calc_drawbar_pull(WheelLocation.BACK, TravelType.UPHILL)

#         level_linear_4x4_pull = 2*front_ll_drawbar_pull + 2*back_ll_drawbar_pull
#         uphill_4x4_pull = 2*front_up_drawbar_pull + 2*back_up_drawbar_pull
#         drawbar_pull = min(level_linear_4x4_pull, uphill_4x4_pull)

#         if drawbar_pull > 0:
#             print(f"Found positive drawbar pull at slip ratio: {slip:.3f}")
#             print(f"Drawbar Pull: {drawbar_pull:.3f} N")
#             found_valid_slip = True
#             break
        
#     if not found_valid_slip:
#         print(f"No positive drawbar pull found for width {width:.3f} m. Skipping.")
#         continue

#     wheel_mass = calc_mass(Aluminum_7075)
#     battery_mass = calc_battery_mass()
#     total_mass.append(wheel_mass + battery_mass)
#     valid_widths.append(width)

# valid_widths = np.array(valid_widths)
# total_mass = np.array(total_mass)

# if len(valid_widths) > 0:
#     # Find the optimal diameter that minimizes total mass
#     min_mass_index = np.argmin(total_mass)
#     optimal_width = valid_widths[min_mass_index]
#     p.width = optimal_width
    
#     plt.figure(figsize=(8, 6))
#     plt.plot(valid_widths, total_mass, marker='o', linestyle='-', color='b', label="Total Mass")
#     plt.axvline(optimal_width, color='r', linestyle='--', label=f"Optimal Width: {optimal_width:.3f} m")
#     plt.xlabel("Width (m)")
#     plt.ylabel("Total Mass (kg)")
#     plt.title(f"Total Mass vs. Width (Diameter = {p.outer_diameter}m, Grouser Height = {p.grouser_height}m)")
#     plt.legend()
#     plt.grid(True)
#     plt.savefig("wheels/images/total_mass_vs_width.png", dpi=300)

# ## Grouser Height ##
# grouser_height_values = np.linspace(.001, .100, 100)
# valid_grouser_heights = []
# total_mass = []

# for grouser_height in grouser_height_values:
#     p.grouser_height = grouser_height
#     slip_values = np.linspace(0.01, .99, 99)
#     found_valid_slip = False

#     for slip in slip_values:
#         p.slip_ratio = slip  # Update slip ratio in parameters
#         front_ll_drawbar_pull = calc_drawbar_pull(WheelLocation.FRONT, TravelType.LEVEL_LINEAR)
#         front_up_drawbar_pull = calc_drawbar_pull(WheelLocation.FRONT, TravelType.UPHILL)
#         back_ll_drawbar_pull = calc_drawbar_pull(WheelLocation.BACK, TravelType.LEVEL_LINEAR)
#         back_up_drawbar_pull = calc_drawbar_pull(WheelLocation.BACK, TravelType.UPHILL)

#         level_linear_4x4_pull = 2*front_ll_drawbar_pull + 2*back_ll_drawbar_pull
#         uphill_4x4_pull = 2*front_up_drawbar_pull + 2*back_up_drawbar_pull
#         drawbar_pull = min(level_linear_4x4_pull, uphill_4x4_pull)

#         if drawbar_pull > 0:
#             print(f"Found positive drawbar pull at slip ratio: {slip:.3f}")
#             print(f"Drawbar Pull: {drawbar_pull:.3f} N")
#             found_valid_slip = True
#             break
        
#     if not found_valid_slip:
#         print(f"No positive drawbar pull found for grouser_height {grouser_height:.3f} m. Skipping.")
#         continue

#     wheel_mass = calc_mass(Aluminum_7075)
#     battery_mass = calc_battery_mass()
#     total_mass.append(wheel_mass + battery_mass)
#     valid_grouser_heights.append(grouser_height)

# valid_grouser_heights = np.array(valid_grouser_heights)
# total_mass = np.array(total_mass)

# if len(valid_grouser_heights) > 0:
#     # Find the optimal diameter that minimizes total mass
#     min_mass_index = np.argmin(total_mass)
#     optimal_grouser_height = valid_grouser_heights[min_mass_index]
#     p.grouser_height = optimal_grouser_height
    
#     plt.figure(figsize=(8, 6))
#     plt.plot(valid_grouser_heights, total_mass, marker='o', linestyle='-', color='b', label="Total Mass")
#     plt.axvline(optimal_grouser_height, color='r', linestyle='--', label=f"Optimal Grouser Height: {optimal_grouser_height:.3f} m")
#     plt.xlabel("Grouser Height (m)")
#     plt.ylabel("Total Mass (kg)")
#     plt.title(f"Total Mass vs. Grouser Height (Diameter = {p.outer_diameter}m, Width = {p.grouser_height}m)")
#     plt.legend()
#     plt.grid(True)
#     plt.savefig("wheels/images/total_mass_vs_grouser_height.png", dpi=300)


# wheel_mass = calc_mass(Aluminum_7075)
# print(f"\nOptimal Diameter: {optimal_diameter:.3f} m")
# print(f"Optimal Width: {optimal_width:.3f} m")
# print(f"Optimal Grouser Height: {optimal_grouser_height:.3f} m")
# print(f"Minimum 4 Wheel Mass: {wheel_mass:.3f} kg")




