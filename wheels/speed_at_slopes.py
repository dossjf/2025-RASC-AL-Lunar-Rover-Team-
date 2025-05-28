import parameters as p
from helper_functions import calc_power, calc_torque, calc_drawbar_pull, WheelLocation, TravelType, calc_mass, calc_battery_mass, calc_number_of_grousers
from materials import *
import numpy as np
import matplotlib.pyplot as plt

### Speed at Different Slopes ###

front_ll_torque = calc_torque(WheelLocation.FRONT, TravelType.LEVEL_LINEAR)
front_ll_power = calc_power(WheelLocation.FRONT, TravelType.LEVEL_LINEAR)

front_up_torque = calc_torque(WheelLocation.FRONT, TravelType.UPHILL)
front_up_power = calc_power(WheelLocation.FRONT, TravelType.UPHILL)

back_ll_torque = calc_torque(WheelLocation.BACK, TravelType.LEVEL_LINEAR)
back_ll_power = calc_power(WheelLocation.BACK, TravelType.LEVEL_LINEAR)

back_up_torque = calc_torque(WheelLocation.BACK, TravelType.UPHILL)
back_up_power = calc_power(WheelLocation.BACK, TravelType.UPHILL)

level_linear_4x4_power = 2*front_ll_power + 2*back_ll_power
uphill_4x4_power = 2*front_up_power + 2*back_up_power
max_power = max(level_linear_4x4_power, uphill_4x4_power)
max_torque = max(front_ll_torque, front_up_torque, back_ll_torque, back_up_torque)

slope_values = np.linspace(0, p.max_slope, 10)
speed_values = np.linspace(p.min_speed_at_max_slope, p.max_speed, 10)
max_speed_values = []

for i, slope in enumerate(slope_values):
    p.max_slope = slope

    last_valid_speed = .1

    for speed in speed_values:
        p.min_speed_at_max_slope = speed
        p.min_angular_velocity = 2 * p.min_speed_at_max_slope / p.outer_diameter

        front_up_torque = calc_torque(WheelLocation.FRONT, TravelType.UPHILL)
        front_up_power = calc_power(WheelLocation.FRONT, TravelType.UPHILL)

        back_up_torque = calc_torque(WheelLocation.BACK, TravelType.UPHILL)
        back_up_power = calc_power(WheelLocation.BACK, TravelType.UPHILL)

        uphill_4x4_power = 2*front_up_power + 2*back_up_power
        torque = max(front_up_torque, back_up_torque)

        if uphill_4x4_power > max_power or torque > max_torque:
        #if uphill_4x4_power > max_power:
            break
        else:
            last_valid_speed = speed 

    max_speed_values.append(last_valid_speed)

plt.figure(figsize=(8, 5))
plt.scatter(slope_values, max_speed_values, label="Max Speed vs Slope", color="b")
plt.xlabel("Slope (degrees)")
plt.ylabel("Max Speed (m/s)")
plt.title("Max Speed at Different Slopes")
plt.legend()
plt.grid()
plt.show()

