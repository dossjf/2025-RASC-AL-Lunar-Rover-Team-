import parameters as p
from helper_functions import *

## Force Power Calculations ##

# Wheel Calcs
front_ll_torque = calc_torque(WheelLocation.FRONT, TravelType.LEVEL_LINEAR)
front_ll_power = calc_power(WheelLocation.FRONT, TravelType.LEVEL_LINEAR)

front_up_torque = calc_torque(WheelLocation.FRONT, TravelType.UPHILL)
front_up_power = calc_power(WheelLocation.FRONT, TravelType.UPHILL)

back_ll_torque = calc_torque(WheelLocation.BACK, TravelType.LEVEL_LINEAR)
back_ll_power = calc_power(WheelLocation.BACK, TravelType.LEVEL_LINEAR)

back_up_torque = calc_torque(WheelLocation.BACK, TravelType.UPHILL)
back_up_power = calc_power(WheelLocation.BACK, TravelType.UPHILL)

# other

# 


