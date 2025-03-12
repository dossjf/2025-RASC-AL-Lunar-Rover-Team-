import parameters as p
import numpy as np
from enum import Enum
from materials import Material

class WheelLocation(Enum):
    FRONT = "front"
    BACK = "back"

class TravelType(Enum):
    LEVEL_LINEAR = "level_linear"
    UPHILL = "uphill"

### Force Power Calculations ###

def calc_torque(wheel_location: WheelLocation, travel_type: TravelType):
    tractive_force = calc_tractive_force(wheel_location, travel_type) # [N]
    torque = tractive_force * p.outer_diameter/2 # [Nm]
    return torque

def calc_power(wheel_location: WheelLocation, travel_type: TravelType):
    if travel_type == TravelType.LEVEL_LINEAR:
        return p.max_angular_velocity * calc_torque(wheel_location, travel_type) # [W]
    elif travel_type == TravelType.UPHILL:
        return p.min_angular_velocity * calc_torque(wheel_location, travel_type) # [W]

def calc_tractive_force(wheel_location: WheelLocation, travel_type: TravelType):
    weight_on_wheel = calc_weight_on_wheel(wheel_location, travel_type)
    number_of_grousers = calc_number_of_grousers()
    length_contact_patch = calc_length_contact_patch(wheel_location, travel_type)

    # Source 2 pg. 22
    contact_area = calc_contact_area(length_contact_patch)
    tractive_force = ((contact_area * p.soil_cohesion * (1 + 2*p.grouser_height*number_of_grousers/p.width)) + 
                      weight_on_wheel*np.tan(np.deg2rad(p.soil_angle_of_internal_friction))*(1 + .64*(p.grouser_height/p.width)*np.arctan(p.width/p.grouser_height))) * \
                      (1 - (p.shear_deformation_modulus/(p.slip_ratio*length_contact_patch)) * 
                      (1 - np.exp(-p.slip_ratio*length_contact_patch/p.shear_deformation_modulus)))
    return tractive_force

def calc_contact_area(length_contact_patch):
    # Source 2 pg. 4
    return length_contact_patch * p.width

def calc_weight_on_wheel(wheel_location: WheelLocation, travel_type: TravelType):
    # Source 4
    if travel_type == TravelType.LEVEL_LINEAR:
        return (p.mass_of_rover + p.mass_of_max_payload)*p.lunar_gravity/4
    elif wheel_location == WheelLocation.FRONT:
        return (p.mass_of_rover + p.mass_of_max_payload)*p.lunar_gravity/p.rover_length * (np.cos(np.deg2rad(p.max_slope))*p.center_of_mass_from_the_back - np.sin(np.deg2rad(p.max_slope))*p.outer_diameter)
    elif wheel_location == WheelLocation.BACK:
        front_wheel_weight = (p.mass_of_rover + p.mass_of_max_payload)*p.lunar_gravity/p.rover_length * (np.cos(np.deg2rad(p.max_slope))*p.center_of_mass_from_the_back - np.sin(np.deg2rad(p.max_slope))*p.outer_diameter)
        return (p.mass_of_rover + p.mass_of_max_payload)*p.lunar_gravity*np.cos(np.deg2rad(p.max_slope)) - front_wheel_weight
    
def calc_number_of_grousers():
    # Source 2 pg. 19-21
    compressive_depth = np.array([calc_compressive_depth(WheelLocation.FRONT, TravelType.LEVEL_LINEAR),
                         calc_compressive_depth(WheelLocation.FRONT, TravelType.UPHILL),
                         calc_compressive_depth(WheelLocation.BACK, TravelType.LEVEL_LINEAR),
                         calc_compressive_depth(WheelLocation.BACK, TravelType.UPHILL)])

    normalized_grouser_height = p.grouser_height / (p.outer_diameter/2)
    normalized_compressive_depth = compressive_depth / (p.outer_diameter/2)

    grouser_angle = (1/(1-p.slip_ratio))*(np.sqrt(normalized_grouser_height**2 + 2*normalized_grouser_height + 2*normalized_compressive_depth - normalized_compressive_depth**2) - np.sqrt(2*normalized_compressive_depth - normalized_compressive_depth**2))

    return np.ceil(2*np.pi/np.min(grouser_angle))

def calc_compressive_depth(wheel_location: WheelLocation, travel_type: TravelType):
    normal_force = calc_weight_on_wheel(wheel_location, travel_type)

    return np.power((3*normal_force/((3-p.sinkage_constant)*(p.modulus_of_cohesion + p.width*p.modulus_of_friction)*np.sqrt(p.outer_diameter))),2/(2*p.sinkage_constant+1))

def calc_length_contact_patch(wheel_location: WheelLocation, travel_type: TravelType):
    return p.outer_diameter/2 * np.arccos(1 - 2*calc_compressive_depth(wheel_location, travel_type)/p.outer_diameter)

def calc_drawbar_pull(wheel_location: WheelLocation, travel_type: TravelType):
    # Source 2 pg. 24
    tractive_force = calc_tractive_force(wheel_location, travel_type)
    
    compaction_resistance = calc_compaction_resistance(wheel_location, travel_type)
    bulldoze_resistance = calc_bulldoze_resistance(wheel_location, travel_type)
    gravitational_resistance = calc_gravitational_resistance(wheel_location, travel_type)
    rolling_resistance = calc_rolling_resistance(wheel_location, travel_type)

    return tractive_force - compaction_resistance - bulldoze_resistance - gravitational_resistance - rolling_resistance

def calc_compaction_resistance(wheel_location: WheelLocation, travel_type: TravelType):
    # Source 1 pg. 32
    return .5 * np.power(p.modulus_of_cohesion + p.modulus_of_friction*p.width, -0.33) * np.power(1.5*calc_weight_on_wheel(wheel_location, travel_type)/np.sqrt(p.outer_diameter), 1.33)

def calc_bulldoze_resistance(wheel_location: WheelLocation, travel_type: TravelType):
    # Source 1 pg. 43
    if wheel_location == WheelLocation.BACK:
        return 0

    compressive_depth = calc_compressive_depth(wheel_location, travel_type)

    wheel_aoa = np.arccos(1 - (2*compressive_depth/p.outer_diameter)) # alpha
    length_of_ruptured_soil =  compressive_depth * np.tan(np.pi/4 - np.deg2rad(p.soil_angle_of_internal_friction/2))**2 # l0
    
    bulldoze_resistance = (p.width*np.sin(wheel_aoa+np.deg2rad(p.soil_angle_of_internal_friction))/(2*np.sin(wheel_aoa)*np.cos(np.deg2rad(p.soil_angle_of_internal_friction)))) * \
                          (2*compressive_depth*p.soil_cohesion*p.cohesive_modulus_of_soil_deformation + p.soil_weight_density*(compressive_depth**2)*p.density_modulus_of_soil_deformation) + \
                          (length_of_ruptured_soil**3 * p.soil_weight_density/3)*(np.pi/2 - np.deg2rad(p.soil_angle_of_internal_friction)) + \
                          (p.soil_cohesion*length_of_ruptured_soil**2)*(1 + np.tan(np.pi/4 + np.deg2rad(p.soil_angle_of_internal_friction/2)))

    return bulldoze_resistance

def calc_gravitational_resistance(wheel_location: WheelLocation, travel_type: TravelType):
    # Source 1 pg. 42
    if travel_type == TravelType.LEVEL_LINEAR:
        return 0

    if wheel_location == WheelLocation.FRONT:
        return calc_weight_on_wheel(wheel_location, travel_type) * np.sin(np.deg2rad(p.max_slope))
    elif wheel_location == WheelLocation.BACK:
        return calc_weight_on_wheel(wheel_location, travel_type) * np.sin(np.deg2rad(p.max_slope))
    
def calc_rolling_resistance(wheel_location: WheelLocation, travel_type: TravelType):
    weight_on_wheel = calc_weight_on_wheel(wheel_location, travel_type)
    return weight_on_wheel*p.internal_rolling_friction_coeffient


### Mass Calculations ###

def calc_mass(material: Material):

    front_ll_outer_shell_mass = calc_outer_shell_mass(material, WheelLocation.FRONT, TravelType.LEVEL_LINEAR)
    front_up_outer_shell_mass = calc_outer_shell_mass(material, WheelLocation.FRONT, TravelType.UPHILL)
    back_ll_outer_shell_mass = calc_outer_shell_mass(material, WheelLocation.BACK, TravelType.LEVEL_LINEAR)
    back_up_outer_shell_mass = calc_outer_shell_mass(material, WheelLocation.BACK, TravelType.UPHILL)

    front_ll_grouser_mass = calc_grouser_mass(material, WheelLocation.FRONT, TravelType.LEVEL_LINEAR)
    front_up_grouser_mass = calc_grouser_mass(material, WheelLocation.FRONT, TravelType.UPHILL)
    back_ll_grouser_mass = calc_grouser_mass(material, WheelLocation.BACK, TravelType.LEVEL_LINEAR)
    back_up_grouser_mass = calc_grouser_mass(material, WheelLocation.BACK, TravelType.UPHILL)

    return 4*(max(front_ll_outer_shell_mass, front_up_outer_shell_mass, back_ll_outer_shell_mass, back_up_outer_shell_mass) + \
           max(front_ll_grouser_mass, front_up_grouser_mass, back_ll_grouser_mass, back_up_grouser_mass))

def calc_outer_shell_mass(material: Material, wheel_location: WheelLocation, travel_type: TravelType):
    weight_on_wheel = calc_weight_on_wheel(wheel_location, travel_type)
    hoop_stress_thickness = p.safety_factor*weight_on_wheel*p.outer_diameter/(8*material.yield_strength*calc_contact_area(calc_length_contact_patch(wheel_location, travel_type)))
    impact_energy_thickness = p.outer_diameter/2 - np.sqrt((p.outer_diameter/2)**2 - ((p.deformation_localization_factor*weight_on_wheel/p.lunar_gravity*p.max_speed**2*material.modulus_of_elasticity*p.safety_factor**2)/ \
                                                                                      (material.yield_strength**2 * p.width * np.pi)))
    
    thickness = max(hoop_stress_thickness, impact_energy_thickness, p.minimum_outer_thickness)
    return material.density*p.width*np.pi*((p.outer_diameter/2)**2 - (p.outer_diameter/2 - thickness)**2)

def calc_grouser_mass(material: Material, wheel_location: WheelLocation, travel_type: TravelType):
    weight_on_wheel = calc_weight_on_wheel(wheel_location, travel_type)
    length_contact_patch = calc_length_contact_patch(wheel_location, travel_type)
    smooth_wheel_tractive_force = (p.width*length_contact_patch*p.soil_cohesion + calc_weight_on_wheel(wheel_location, travel_type)*np.tan(np.deg2rad(p.soil_angle_of_internal_friction))) * \
                                  (1 - p.shear_deformation_modulus/(length_contact_patch*p.slip_ratio)*(1 - np.exp(-length_contact_patch*p.slip_ratio/p.shear_deformation_modulus))) # source 2 pg.4 
    grouser_tractive_force = calc_tractive_force(wheel_location, travel_type) - smooth_wheel_tractive_force # [N]
    grouser_distributed_force = grouser_tractive_force / p.grouser_height # [Nm]
    cantilever_bending_thickness = np.sqrt((p.safety_factor*grouser_distributed_force*p.grouser_height**2)/(48*material.yield_strength*p.width))
    impact_method_thickness = np.power((((weight_on_wheel/p.lunar_gravity)*p.safety_factor*p.max_speed**2)/(2*p.width*(material.yield_strength/material.modulus_of_elasticity)*p.grouser_height)) * \
                                       (p.grouser_height**2 * 12 * (1-material.poissons_ratio**2))/(.95 * np.pi**2 * material.modulus_of_elasticity), 1/3)
    
    thickness = max(cantilever_bending_thickness, impact_method_thickness, p.minimum_outer_thickness)

    return thickness*p.grouser_height*p.width*material.density*calc_number_of_grousers()

### Battery Stuff ###
def calc_battery_mass():
    front_ll_power = calc_power(WheelLocation.FRONT, TravelType.LEVEL_LINEAR)
    front_up_power = calc_power(WheelLocation.FRONT, TravelType.UPHILL)
    back_ll_power = calc_power(WheelLocation.BACK, TravelType.LEVEL_LINEAR)
    back_up_power = calc_power(WheelLocation.BACK, TravelType.UPHILL)

    level_linear_4x4_power = 2*front_ll_power + 2*back_ll_power
    uphill_4x4_power = 2*front_up_power + 2*back_up_power
    max_power = max(level_linear_4x4_power, uphill_4x4_power)

    battery_capacity = max_power * p.runtime_at_full_power
    return battery_capacity/p.battery_specific_energy


