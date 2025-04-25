import numpy as np
import matplotlib.pyplot as plt

# Constants
critical_force = 29430          # N
n = 2
E = 69e9                     # Pa
L = 1.28                        # m
SF = 2
num_stands = 4
rho = 2760

# Geometry
B = 0.025                         # m
H = 0.025                         # m

# Critical load target
required_force = critical_force*SF / (num_stands)

# Thickness values to sweep over
t_vals = np.linspace(.0000001, .001, 500)
buckling_loads = []

for t in t_vals:
    if t <= 0 or t >= B/2 or t >= H/2:
        buckling_loads.append(np.nan)
    else:
        I = (B * H**3 - (B - 2*t)*(H - 2*t)**3) / 12
        P_cr = (n**2 * np.pi**2 * E * I) / (L**2)
        buckling_loads.append(P_cr)

# Plot
plt.figure(figsize=(8, 5))
plt.plot(t_vals * 1000, buckling_loads, label='Buckling Load vs. Thickness')
plt.axhline(required_force, color='red', linestyle='--', label='Required Load')
plt.xlabel("Thickness t (mm)")
plt.ylabel("Buckling Load (N)")
plt.ylim([-2*critical_force, 2*critical_force])
plt.title("Buckling Load vs. Wall Thickness")
plt.grid(True)
plt.legend()
plt.tight_layout()
plt.show()

def calculate_mass(B, H, t):
    if t <= 0 or t >= B/2 or t >= H/2:
        return np.inf
    volume = L * (B * H - (B - 2 * t) * (H - 2 * t))
    return volume * rho

print(f"Mass: {calculate_mass(B, H, .001)}")
