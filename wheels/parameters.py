# Vehicle Properties
mass_of_rover = 500 # [kg]
mass_of_max_payload = 300 # [kg]
max_speed = 1 # [m/s]
min_speed_at_max_slope = .1 # [m/s]
safety_factor = 1.5 # [~]
max_slope = 25 # [deg]ii
rover_length = 2.5 # [m]
center_of_mass_from_the_back = .81 # [m]

# Wheel Properties
outer_diameter = .45 # [m]
width = .125 # [m]
slip_ratio = .31 # [~] (0,1) exclusive bounds
minimum_outer_thickness = .001 # [m]
deformation_localization_factor = .1 # [~]
grouser_height = .01 # [m]

# Constants
lunar_gravity = 1.62 # [m/s^2]

# Lunar Regolith Properties
sinkage_constant = 1 # [~] [1 pg.22] (n) 
modulus_of_cohesion = 1400 # [N/m^2] [1 pg.22] (k_c) 
modulus_of_friction = 820000 # [N/m^2] [1 pg.22] (k_phi) 
shear_deformation_modulus = 0.018 # [~] [2 pg.22] (K) 
soil_cohesion = 170 # [N/m^2] [2 pg.22] (c) 
soil_angle_of_internal_friction = 35 # [deg] [2 pg.22] (phi) 
cohesive_modulus_of_soil_deformation = 33.37 # [~] [5] (K_c) 
density_modulus_of_soil_deformation = 72.77 # [~] [5] (K_gamma) 
soil_weight_density = 2470 # N/m^2 [5] (gamma) 

# Calculated parameters
max_angular_velocity = 2 * max_speed / outer_diameter # [rad/s]
min_angular_velocity = 2 * min_speed_at_max_slope / outer_diameter # [rad/s]

internal_rolling_friction_coeffient = 0.05 # [~]

# Battery parameters
runtime_at_full_power = 8 # [hr]
battery_specific_energy = 104.6 # [Wh/kg]