from dataclasses import dataclass

@dataclass
class Material:
    name: str
    density: float  # kg/m^3
    modulus_of_elasticity: float  # Pa
    shear_modulus: float  # Pa
    poissons_ratio: float  # Dimensionless
    yield_strength: float  # Pa

# Define materials
Ti_6Al_4V = Material(
    name="Titanium Ti-6Al-4V",
    density=4430,  # kg/m^3
    modulus_of_elasticity=1.14E11,  # Pa
    shear_modulus=4.40E10,  # Pa
    poissons_ratio=0.293,  # Dimensionless
    yield_strength=8.80E8  # Pa
)

Stainless_Steel = Material(
    name="Stainless Steel",
    density=8000,  # kg/m^3
    modulus_of_elasticity=1.93E11,  # Pa
    shear_modulus=8.60E10,  # Pa
    poissons_ratio=0.122,  # Dimensionless
    yield_strength=2.15E8  # Pa
)

Aluminum_7075 = Material(
    name="Aluminum 7075",
    density=2810,  # kg/m^3
    modulus_of_elasticity=7.17E10,  # Pa
    shear_modulus=2.60E10,  # Pa
    poissons_ratio=0.379,  # Dimensionless
    yield_strength=5.03E8  # Pa
)

Inconel_718 = Material(
    name="Inconel 718",
    density=8220,  # kg/m^3
    modulus_of_elasticity=2.05E11,  # Pa
    shear_modulus=7.72E10,  # Pa
    poissons_ratio=0.328,  # Dimensionless
    yield_strength=1.39E9  # Pa
)