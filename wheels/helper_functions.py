import parameters as p

class WheelLocation(Enum):
    FRONT = "front"
    BACK = "back"

class TravelType(Enum):
    LEVEL_LINEAR = "level_linear"
    UPHILL = "uphill"

def calc_torque(wheel_location: WheelLocation, travel_type: TravelType):
    
    
    torque = tractive_force * p.outer_diameter # [Nm]

def calc_power(wheel_location: WheelLocation, travel_type: TravelType):
    power = p.max_angular_velocity * calc_torque(wheel_location, travel_type) # [W]
    return power