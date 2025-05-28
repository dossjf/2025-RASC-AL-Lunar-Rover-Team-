close all
clear
addpath("kinematics\")

crane_dyma_DH = [
    0            0              0.3             0; % 1 J1
    0           -pi/2           0.0             0; % 2 J2
    0            pi/2           1.4+3.3             0; % 3 J3
    0           -pi/2           0               0; % 4 J4
   -1.054        0              0               0; % 5 Tip
    0.05         0              0.18161+0.1     0; % j1 6
    0            pi/2           0.0             pi/2; % j2 7
    0           -pi/2           0.430022        pi/2; % j3 8
   -0.041402     pi/2           0.0             0; % j4 9
    0.041402    -pi/2           0.37084         0; % j5 10
    0.033274     pi/2           0.0             0; % j6 11
   -0.033274    -pi/2           0.0             0; % j7 12
    0            0              0.314325        0]; % T 13

crane_dyma_DH_mod = crane_dyma_DH;


% minimum reach: 1.4, maximum reach: 4.7, max extension = 3.68 (meters)
max_extension = 3.3;
crane_limits = [deg2rad(-30)    deg2rad(30);
                -pi/2            0;
                 1.4          1.4 + max_extension; 
                -pi/2        deg2rad(35)];

dyma_limits = [ -pi              pi;
                -deg2rad(120)    deg2rad(120);
                -pi              pi;
                 0               pi;
                -pi              pi;
                -pi               0;
                -pi              pi];

% Rover: length = 2.6m, height=0.5, width=1.3 (not super important)
cart_placement = [1, 0, 0.5]; % cartesian offset
pre_mult = [1 0 0 cart_placement(1);
            0 1 0 cart_placement(2);
            0 0 1 cart_placement(3);
            0 0 0        1         ];

rad_iter_val = deg2rad(10);
m_iter_val = 3.3+1.4;

% ANALYSIS
count = 1;
for th2_crane = crane_limits(2,1):deg2rad(15):crane_limits(2,2) % Crane Pitch
for th4_crane = crane_limits(4,1):deg2rad(15):crane_limits(4,2) % Crane Elbow Pitch
    for th1 = dyma_limits(1,1):deg2rad(10):dyma_limits(1,2)
        for th4 = dyma_limits(4,1):rad_iter_val:dyma_limits(4,2)
            for th6 = dyma_limits(6,1):rad_iter_val:dyma_limits(6,2)
                count = count+1;
            end
        end
    end
end
end


use_count = count-1;

% Allocate array lengths
q = zeros(use_count,13);
cartx = zeros(use_count, 1);
carty = zeros(use_count, 1);
cartz = zeros(use_count, 1);

count = 1;
for th2_crane = crane_limits(2,1):deg2rad(20):crane_limits(2,2) % Crane Pitch
    th2_crane
for th4_crane = crane_limits(4,1):deg2rad(20):crane_limits(4,2) % Crane Elbow Pitch
    % th4_crane
    for th1 = dyma_limits(1,1):deg2rad(15):dyma_limits(1,2)
        % th1
        for th4 = dyma_limits(4,1):rad_iter_val:dyma_limits(4,2)
            for th6 = dyma_limits(6,1):rad_iter_val:dyma_limits(6,2)

                crane_dyma_DH_mod(2,4) = crane_dyma_DH(2,4)+th2_crane;
                crane_dyma_DH_mod(4,4) = crane_dyma_DH(4,4)+th4_crane;
                crane_dyma_DH_mod(6,4) = crane_dyma_DH(6,4)+th1;
                crane_dyma_DH_mod(9,4) = crane_dyma_DH(9,4)+th4;
                crane_dyma_DH_mod(11,4) = crane_dyma_DH(11,4)+th6;

                q(count, 1) = crane_dyma_DH_mod(1,4);
                q(count, 2) = crane_dyma_DH_mod(2,4);
                q(count, 3) = 0;
                q(count, 4) = crane_dyma_DH_mod(4,4);
                q(count, 5) = crane_dyma_DH_mod(5,4);
                q(count, 6) = crane_dyma_DH_mod(6,4);
                q(count, 7) = crane_dyma_DH_mod(7,4);
                q(count, 8) = crane_dyma_DH_mod(8,4);
                q(count, 9) = crane_dyma_DH_mod(9,4);
                q(count, 10) = crane_dyma_DH_mod(10,4);
                q(count, 11) = crane_dyma_DH_mod(11,4);
                q(count, 12) = crane_dyma_DH_mod(12,4);
                q(count, 13) = crane_dyma_DH_mod(13,4);
    
                % Compute the final output pose
                T_final = pre_mult*SslModifDhTableToTransf(0, 13, crane_dyma_DH_mod);

                cartx(count) = T_final(1,4); % Save the value in the x vector
                carty(count) = T_final(2,4); % Save the value in the y vector
                cartz(count) = T_final(3,4); % Save the value in the z vector
    
                count = count + 1;
            end
        end
    end
end
end




crane_dyma = SslGenerateRobotFromDh(crane_dyma_DH, "modified");
crane_dyma_model = importRover("dyma");
index = manipulabilityIndex(crane_dyma, q);

crane_dyma_rotate = importRover("dyma_xz");
crane_dyma_config = homeConfiguration(crane_dyma_rotate);
crane_dyma_config(2).JointPosition = (deg2rad(-45));
crane_dyma_config(3).JointPosition = 1.1;
crane_dyma_config(4).JointPosition = 1.1;
crane_dyma_config(5).JointPosition = 1.1;
crane_dyma_config(6).JointPosition = (deg2rad(10));
crane_dyma_config(7).JointPosition = (deg2rad(10));
crane_dyma_config(8).JointPosition = pi/2;
crane_dyma_config(9).JointPosition = -pi/2;
crane_dyma_config(10).JointPosition = pi/4;


show(crane_dyma_model, crane_dyma_config)
hold on
scatter3(cartx, carty, cartz)

figure
show(crane_dyma_rotate, crane_dyma_config, Position=[0,0,40,0])
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

% % ANALYSIS
% count = 1;
% for th2_crane = crane_limits(2,1):deg2rad(15):crane_limits(2,2) % Crane Pitch
% for th4_crane = crane_limits(4,1):deg2rad(15):crane_limits(4,2) % Crane Elbow Pitch
%     for th1 = dyma_limits(1,1):deg2rad(10):dyma_limits(1,2)
%         for th4 = dyma_limits(4,1):rad_iter_val:dyma_limits(4,2)
%             for th6 = dyma_limits(6,1):rad_iter_val:dyma_limits(6,2)
%                 count = count+1;
%             end
%         end
%     end
% end
% end
% 
% 
% use_count = count-1;
% 
% % Allocate array lengths
% q = zeros(use_count,13);
% cartx = zeros(use_count, 1);
% carty = zeros(use_count, 1);
% cartz = zeros(use_count, 1);
% 
% crane_dyma_DH(3,3) = 3.3+1.4;
% 
% count = 1;
% for th2_crane = crane_limits(2,1):deg2rad(30):crane_limits(2,2) % Crane Pitch
%     th2_crane
% for th4_crane = crane_limits(4,1):deg2rad(30):crane_limits(4,2) % Crane Elbow Pitch
%     % th4_crane
%     for th1 = dyma_limits(1,1):deg2rad(15):dyma_limits(1,2)
%         % th1
%         for th4 = dyma_limits(4,1):rad_iter_val:dyma_limits(4,2)
%             for th6 = dyma_limits(6,1):rad_iter_val:dyma_limits(6,2)
% 
%                 crane_dyma_DH_mod(2,4) = crane_dyma_DH(2,4)+th2_crane;
%                 crane_dyma_DH_mod(4,4) = crane_dyma_DH(4,4)+th4_crane;
%                 crane_dyma_DH_mod(6,4) = crane_dyma_DH(6,4)+th1;
%                 crane_dyma_DH_mod(9,4) = crane_dyma_DH(9,4)+th4;
%                 crane_dyma_DH_mod(11,4) = crane_dyma_DH(11,4)+th6;
% 
%                 q(count, 1) = crane_dyma_DH_mod(1,4);
%                 q(count, 2) = crane_dyma_DH_mod(2,4);
%                 q(count, 3) = 0;
%                 q(count, 4) = crane_dyma_DH_mod(4,4);
%                 q(count, 5) = crane_dyma_DH_mod(5,4);
%                 q(count, 6) = crane_dyma_DH_mod(6,4);
%                 q(count, 7) = crane_dyma_DH_mod(7,4);
%                 q(count, 8) = crane_dyma_DH_mod(8,4);
%                 q(count, 9) = crane_dyma_DH_mod(9,4);
%                 q(count, 10) = crane_dyma_DH_mod(10,4);
%                 q(count, 11) = crane_dyma_DH_mod(11,4);
%                 q(count, 12) = crane_dyma_DH_mod(12,4);
%                 q(count, 13) = crane_dyma_DH_mod(13,4);
% 
%                 % Compute the final output pose
%                 T_final = pre_mult*SslModifDhTableToTransf(0, 13, crane_dyma_DH_mod);
% 
%                 cartx(count) = T_final(1,4); % Save the value in the x vector
%                 carty(count) = T_final(2,4); % Save the value in the y vector
%                 cartz(count) = T_final(3,4); % Save the value in the z vector
% 
%                 count = count + 1;
%             end
%         end
%     end
% end
% end
% 
% 
% 
% 
% crane_dyma = SslGenerateRobotFromDh(crane_dyma_DH, "modified");
% crane_dyma_model = importRover("dyma");
% index = manipulabilityIndex(crane_dyma, q);
% 
% crane_dyma_rotate = importRover("dyma_xz");
% show(crane_dyma_model)
% hold on
% scatter3(cartx, carty, cartz)
% 
% % crane_dyma_config = homeConfiguration();
% 
% 
% figure
% show(crane_dyma_rotate, Position=[0,0,40,0])
% hold on
% h = scatter3(cartx, cartz, index, 20, 'filled');
% colormap(jet(numel(index)))
% h.CData = index;
% colorbar();
% axis equal
% title("Manipuability Index based on Cartesian Position")
% xlabel("x-axis (meters)")
% ylabel("z-axis (meters)")
% ylim([0.1,4])
% view([0,0,-1]);
% camproj("orthographic");
  