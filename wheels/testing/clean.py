import os
import pandas as pd
import matplotlib.pyplot as plt
from scipy.signal import find_peaks
import numpy as np

data_dir = "./data"

def compute_wheel_slip(position, revs, dt, wheel_radius, window_size=25):
    # Convert to numpy
    position = np.array(position)
    revs = np.array(revs)

    # Convert revs to radians
    theta = 2 * np.pi * revs

    # Create arrays of zeros for output size
    slip = np.zeros(len(position))

    for i in range(window_size, len(position)):
        # Finite difference over a window
        delta_x = position[i] - position[i - window_size]
        delta_theta = theta[i] - theta[i - window_size]

        # Time delta over the window
        delta_t = dt * window_size

        # Velocities
        v_vehicle = delta_x / delta_t
        omega = delta_theta / delta_t
        v_wheel = wheel_radius * omega

        # Avoid division by zero
        denom = max(max(v_vehicle, v_wheel), 1e-6)
        slip[i] = (v_wheel - v_vehicle) / denom

    # Could also return slip[window_size:] if you want to skip leading zeros
    return slip

# Loop through each subfolder in /data
for folder_name in os.listdir(data_dir):
    folder_path = os.path.join(data_dir, folder_name)

    if os.path.isdir(folder_path):
        # Look for the one CSV file in the folder
        csv_files = [f for f in os.listdir(folder_path) if f.endswith(".csv")]
        
        if len(csv_files) != 1:
            print(f"Skipping {folder_name}: expected 1 CSV file, found {len(csv_files)}")
            continue

        csv_path = os.path.join(folder_path, csv_files[0])

        try:
            df = pd.read_csv(csv_path, delimiter=",")  # or delimiter="," if needed
        except Exception as e:
            print(f"Error reading {csv_path}: {e}")
            continue

        # Clean the data
        df = df.dropna()
        df = df.apply(pd.to_numeric, errors='coerce')
        df = df.dropna()
        time_cut_off = 25

        ### ForceX vs Time Graph ###
        time_col = "Time (seconds)"
        force_col = "ForceX (Newtons)"

        if time_col in df.columns and force_col in df.columns:
            time = df[time_col]
            force = df[force_col]

            # Find peaks before 20s
            mask_early = time < time_cut_off
            peaks, _ = find_peaks(force[mask_early], height=10, prominence=2, width=50)  # tweak height if needed
            peak_times = time[mask_early].iloc[peaks]
            peak_values = force[mask_early].iloc[peaks]

            # Calculate average ForceX after 20s
            mask_late = time > time_cut_off
            avg_force_after_time_cut_off = force[mask_late].mean()

            # Plotting
            plt.figure(figsize=(10, 4))
            plt.plot(time, force, label="ForceX", color='blue')
            plt.scatter(peak_times, peak_values, color='red', label="Peaks")

            for t, f in zip(peak_times, peak_values):
                plt.annotate(f"{f:.2f}", (t, f), textcoords="offset points", xytext=(0,5), ha='center', fontsize=8, color='red')

            plt.axvline(time_cut_off, linestyle="--", color="gray", linewidth=1)
            plt.text(time_cut_off+1, max(force) * 0.95, f"Avg after {time_cut_off}s: {avg_force_after_time_cut_off:.2f} N", fontsize=9, color='green')

            plt.title(f"ForceX vs Time - {folder_name}")
            plt.xlabel("Time (seconds)")
            plt.ylabel("ForceX (Newtons)")
            plt.grid(True)
            plt.legend()
            plt.tight_layout()

            save_path = os.path.join(folder_path, "forcex_vs_time.png")
            plt.savefig(save_path)
            plt.close()
        else:
            print(f"{csv_path} is missing required columns.")


        ### Power vs Time Graph ###
        time_col = "Time (seconds)"
        amp_col = "Motor Effort (before gearbox - Amps)"
        power_col = "Motor Power (Watts)"
        voltage = 24

        if time_col in df.columns and amp_col in df.columns:
            time = df[time_col]
            amps = -df[amp_col]
            power = amps * voltage
            df[power_col] = power

            # Find peaks before 20s
            mask_early = time < time_cut_off
            peaks, _ = find_peaks(power[mask_early], height=10, prominence=2, width=50)  # tweak height if needed
            peak_times = time[mask_early].iloc[peaks]
            peak_values = power[mask_early].iloc[peaks]

            # Calculate average ForceX after 20s
            mask_late = time > time_cut_off
            avg_pwr_after_time_cut_off = power[mask_late].mean()

            # Plotting
            plt.figure(figsize=(10, 4))
            plt.plot(time, power, label="Power", color='blue')
            plt.scatter(peak_times, peak_values, color='red', label="Peaks")

            for t, f in zip(peak_times, peak_values):
                plt.annotate(f"{f:.2f}", (t, f), textcoords="offset points", xytext=(0,5), ha='center', fontsize=8, color='red')

            plt.axvline(time_cut_off, linestyle="--", color="gray", linewidth=1)
            plt.text(time_cut_off+1, max(power) * 0.95, f"Avg after {time_cut_off}s: {avg_pwr_after_time_cut_off:.2f} W", fontsize=9, color='green')

            plt.title(f"Power vs Time - {folder_name}")
            plt.xlabel("Time (seconds)")
            plt.ylabel("Power (Watts)")
            plt.grid(True)
            plt.legend()
            plt.tight_layout()

            save_path = os.path.join(folder_path, "power_vs_time.png")
            plt.savefig(save_path)
            plt.close()
        else:
            print(f"{csv_path} is missing required columns.")

        ### Slip vs Time Graph ###
        time_col = "Time (seconds)"
        deg_col = "Motor Encoder Position (before gearbox - degrees)"
        horitzontal_col = "Horizontal Axis Position (millimeters)"
        vertical_col = "Vertical Axis Position (millimeters)"
        wheel_radius = .125

        if time_col in df.columns and deg_col in df.columns and horitzontal_col in df.columns:
            time = df[time_col]
            degs = -df[deg_col]
            pos = df[horitzontal_col]
            vert = df[vertical_col]
            normalized_sinkage = -vert/1000 / wheel_radius
            slip = compute_wheel_slip(pos, degs, .01, wheel_radius)

            # Calculate average ForceX after 20s
            mask_late = time > time_cut_off
            avg_slip_after_time_cut_off = slip[mask_late].mean()
            avg_sink_after_time_cut_off = normalized_sinkage[mask_late].mean()

            # Plotting
            plt.figure(figsize=(10, 4))
            plt.plot(time, slip, label="Slip", color='blue')
            plt.plot(time, normalized_sinkage, label="Sinkage", color='green')

            plt.axvline(time_cut_off, linestyle="--", color="gray", linewidth=1)
            plt.text(time_cut_off+1, max(slip) * 0.95, f"Avg after {time_cut_off}s: {avg_slip_after_time_cut_off:.2f}", fontsize=9, color='blue')
            plt.text(time_cut_off+1, min(normalized_sinkage) * 0.95, f"Avg after {time_cut_off}s: {avg_sink_after_time_cut_off:.2f}", fontsize=9, color='green')

            plt.title(f"Slip vs Time - {folder_name}")
            plt.xlabel("Time (seconds)")
            plt.ylabel("Slip (-)")
            plt.ylim([-1,1])
            plt.grid(True)
            plt.legend()
            plt.tight_layout()

            save_path = os.path.join(folder_path, "slip_vs_time.png")
            plt.savefig(save_path)
            plt.close()
        else:
            print(f"{csv_path} is missing required columns.")