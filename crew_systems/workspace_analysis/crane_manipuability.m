close all
clear
addpath("kinematics\")

craneDH = [
    0            0              0.3             0; % 1 J1
    0           -pi/2           0.0             0; % 2 J2
    0            pi/2           1.4+3.3             0; % 3 J3
    0           -pi/2           0               0; % 4 J4
   -1.054        0              0               0];

craneDH_mod = craneDH;


% minimum reach: 1.4, maximum reach: 4.7, max extension = 3.68 (meters)
max_extension = 3.3;
crane_limits = [deg2rad(-30)    deg2rad(30);
                -pi/2            0;
                 1.4          1.4 + max_extension; 
                -pi/2        deg2rad(35)];

% Rover: length = 2.6m, height=0.5, width=1.3 (not super important)
cart_placement = [1, 0, 0.5]; % cartesian offset
pre_mult = [1 0 0 cart_placement(1);
            0 1 0 cart_placement(2);
            0 0 1 cart_placement(3);
            0 0 0        1         ];

rad_iter_val = deg2rad(1);
m_iter_val = 1.1;

% ANALYSIS
count = 1;
for th2_crane = crane_limits(2,1):rad_iter_val:crane_limits(2,2) % Crane Pitch
for th4_crane = crane_limits(4,1):rad_iter_val:crane_limits(4,2) % Crane Elbow Pitch
    count = count + 1;
end
end

use_count = count-1;

% Allocate array lengths
q = zeros(use_count,5);
cartx = zeros(use_count, 1);
carty = zeros(use_count, 1);
cartz = zeros(use_count, 1);

count = 1;
for th2_crane = crane_limits(2,1):rad_iter_val:crane_limits(2,2) % Crane Pitch
for th4_crane = crane_limits(4,1):rad_iter_val:crane_limits(4,2) % Crane Elbow Pitch

                craneDH_mod(2,4) = craneDH(2,4)+th2_crane;
                craneDH_mod(4,4) = craneDH(4,4)+th4_crane;
 
                q(count, 1) = craneDH_mod(1,4);
                q(count, 2) = craneDH_mod(2,4);
                q(count, 4) = craneDH_mod(4,4);
    
                % Compute the final output pose
                T_final = pre_mult*SslModifDhTableToTransf(0, 5, craneDH_mod);

                cartx(count) = T_final(1,4); % Save the value in the x vector
                carty(count) = T_final(2,4); % Save the value in the y vector
                cartz(count) = T_final(3,4); % Save the value in the z vector
    
                count = count + 1;
end
end

crane_model = SslGenerateRobotFromDh(craneDH, "modified");
crane_model_rotate = importRover("xz");
index = manipulabilityIndex(crane_model, q);

figure
show(crane_model_rotate, Position=[0,0,0,0])
hold on
h = scatter3(cartx, cartz, index, 20, 'filled');
colormap(jet(numel(index)))
h.CData = index;
colorbar();
axis equal
title("Manipuability Index based on Cartesian Position")
xlabel("x-axis (meters)")
ylabel("z-axis (meters)")
ylim([0.1,4])
view([0,0,1]);
camproj("orthographic");