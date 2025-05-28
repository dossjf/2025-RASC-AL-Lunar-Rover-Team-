close all
addpath("kinematics")

%%% FOR CRANE STUFF
craneDH = [
    0            0              0.3             0;
    0           -pi/2           0.0             0;
    0            pi/2           1.4             0;
    0           -pi/2           0               0;
   -1.054        0              0               0];

% minimum reach: 1.4, maximum reach: 4.7, max extension = 3.68 (meters)
max_extension = 3.3;
crane_limits = [deg2rad(-30)    deg2rad(30);
                -pi/2            0;
                 1.4          1.4 + max_extension; 
                -pi/2        deg2rad(35)];

% Rover: length = 2.6m, height=0.5, width=1.3 (not super important)
% yaw joint is 0.2 m, so offset to edge of rover from center is 1.3 - 0.2
cart_placement = [1.1, 0, 0.5]; % cartesian offset
crane_offset = [-1.1, 0, 0.5, 0];
% pre_mult = [1 0 0 cart_placement(1);
%             0 1 0 cart_placement(2);
%             0 0 1 cart_placement(3);
%             0 0 0        1         ];
pre_mult = [1 0 0 0;
            0 1 0 0;
            0 0 1 cart_placement(3);
            0 0 0        1         ];
% Reset DH 
craneDH_mod = craneDH;

crane_yaw = 15;
crane_pitch = -45;
crane_extension = 0;
crane_elbow = -15;
craneDH_mod(1,4) = deg2rad(crane_yaw);
craneDH_mod(2,4) = deg2rad(crane_pitch);
craneDH_mod(3,3) = 1.4+crane_extension;
craneDH_mod(4,4) = deg2rad(crane_elbow);

T_final = pre_mult*SslModifDhTableToTransf(0, 5, craneDH_mod);
    
crane_cartx = T_final(1,4); % Save the value in the x vector
crane_carty = T_final(2,4); % Save the value in the y vector
crane_cartz = T_final(3,4); % Save the value in the z vector
crane_rot = T_final(1:3,1:3);
%%%



% Run the file to get dyma workspace data
if exist('dyma_ws','var') ~= 1
    dymaflight_full_workspace
end
if exist('dyma_reach','var') ~= 1
    dymaflight_reachable_workspace
end

% Import da robits from the URDF file
dyma = importDyma("");
dyma_xz = importDyma("xz");
dyma_xy = importDyma("xy");
rover_basic = importRover("");
rover_dyma = importDyma("crane");

figure
% show(rover_basic)

% set the current config as the zero config for da robits
dymaConfig = homeConfiguration(dyma);
craneConfig = homeConfiguration(rover_dyma);

position_offset = [-1.3,0.0,0.1,0];

% Below is redundant for copy-past purposes
dymaConfig(1).JointPosition = 0;
dymaConfig(2).JointPosition = 0;
dymaConfig(3).JointPosition = 0;
dymaConfig(4).JointPosition = 0;
dymaConfig(5).JointPosition = 0;
dymaConfig(6).JointPosition = 0;
dymaConfig(7).JointPosition = 0;



% % Show some plots
% %% 3D YAW PLOT
% figure
% dymaConfig(2).JointPosition = pi/2;
% show(dyma, dymaConfig);
% hold on
% fill3(dyma_reach.yaw.cartx, dyma_reach.yaw.carty, dyma_reach.yaw.cartz, "r", "FaceAlpha","0.5");
% title("Dymaflight Workspace Reach Along Global Z-Axis [3D]");
% xlabel("x-reach (meters)");
% ylabel("y-reach (meters)");
% zlabel("z-reach (meters)");
% grid on
% axis equal
% 
% %% 2D YAW PLOT
% figure;
% fill(dyma_reach.yaw.cartx, dyma_reach.yaw.carty, "r", "FaceAlpha","0.5");
% hold on
% show(dyma, dymaConfig);
% title("Dymaflight Workspace Reach Along Global Z-Axis [2D]");
% xlabel("x-reach (meters)");
% ylabel("y-reach (meters)");
% grid on
% axis equal
% 
% 
%% 3D PITCH PLOT
% hold on
dymaConfig(1).JointPosition = deg2rad(90);
dymaConfig(2).JointPosition = deg2rad(-60);
dymaConfig(3).JointPosition = 0;
dymaConfig(4).JointPosition = deg2rad(135);
dymaConfig(5).JointPosition = 0;
dymaConfig(6).JointPosition = deg2rad(-45);
dymaConfig(7).JointPosition = 0;


craneConfig(1).JointPosition = deg2rad(crane_yaw);
craneConfig(2).JointPosition = deg2rad(crane_pitch)
craneConfig(3).JointPosition = crane_extension/3;
craneConfig(4).JointPosition = crane_extension/3;
craneConfig(5).JointPosition = crane_extension/3;
craneConfig(6).JointPosition = deg2rad(crane_elbow);
craneConfig(7).JointPosition = deg2rad(90);


% figure
% show(rover_dyma, dymaConfig, Position=position_offset);
show(rover_dyma, craneConfig, Position=crane_offset);
hold on
% fill3(dyma_reach.pitch.cartx+(position_offset(1)), dyma_reach.pitch.carty+position_offset(2), dyma_reach.pitch.cartz-position_offset(3), "r", "FaceAlpha","0.5");
vec = [dyma_reach.yaw.cartx(:) dyma_reach.yaw.carty(:) dyma_reach.yaw.cartz(:)];
offset_1_vec = [crane_cartx crane_carty crane_cartz];
offset_2_vec = [0.5 -0.25 0.1];

% Rotate data first
vec_rot = (crane_rot*vec')';

% Add cart offset
vec_rot = vec_rot + offset_1_vec;

% rotate offset to match;
offset_rot = (crane_rot*offset_2_vec')';

vec_rot = vec_rot + offset_rot;


% fill3(dyma_reach.pitch.cartx+crane_cartx, dyma_reach.pitch.carty+crane_carty+0.1, dyma_reach.pitch.cartz+crane_cartz, "r", "FaceAlpha","0.5");
fill3(vec_rot(:,1), vec_rot(:,2), vec_rot(:,3), "r", "FaceAlpha","0.5");

title("Dymaflight Workspace Reach About Global Z-Axis [3D]");
xlabel("x-reach (meters)");
ylabel("y-reach (meters)");
zlabel("z-reach (meters)");
grid on
axis equal
% 
% %% 2D PITCH PLOT
% figure;
% show(dyma, dymaConfig);
% hold on
% fill3(dyma_reach.pitch.cartx, dyma_reach.pitch.carty, dyma_reach.pitch.cartz, "r", "FaceAlpha","0.5");
% title("Dymaflight Workspace Reach Along Global Y-Axis [2D]");
% view([0,1,0]);
% camproj("orthographic");
% xlabel("x-reach (meters)");
% zlabel("z-reach (meters)");
% xlim([-1.5, 1.5]);
% zlim([-1, 2]);
% grid on
% 
% %% 2D Elbow plot
% figure
% dymaConfig(1).JointPosition = 0;
% dymaConfig(2).JointPosition = deg2rad(120);
% dymaConfig(3).JointPosition = 0;
% dymaConfig(4).JointPosition = deg2rad(155);
% dymaConfig(5).JointPosition = pi;
% dymaConfig(6).JointPosition = deg2rad(-65);
% dymaConfig(7).JointPosition = 0;
% show(dyma, dymaConfig);
% hold on
% fill3(dyma_reach.pitch.cartx, dyma_reach.pitch.carty, dyma_reach.pitch.cartz, "r", "FaceAlpha","0.5");
% fill3(dyma_reach.elbow.cartx, dyma_reach.elbow.carty+0.01, dyma_reach.elbow.cartz, "g", "FaceAlpha","0.5");
% fill3(dyma_reach.wrist.cartx, dyma_reach.wrist.carty+0.02, dyma_reach.wrist.cartz, "b", "FaceAlpha","0.5");
% title("Dymaflight Workspace Reach Along Global Y-Axis [3D]");
% xlabel("x-reach (meters)");
% ylabel("y-reach (meters)");
% zlabel("z-reach (meters)");
% view([0,1,0]);
% camproj("orthographic");
% xlim([-1.5, 1.5]);
% zlim([-1, 2]);
% grid on
% axis equal
% 
% %% 3D Elbow plot
% figure
% dymaConfig(1).JointPosition = 0;
% dymaConfig(2).JointPosition = deg2rad(120);
% dymaConfig(3).JointPosition = 0;
% dymaConfig(4).JointPosition = deg2rad(155);
% dymaConfig(5).JointPosition = pi;
% dymaConfig(6).JointPosition = deg2rad(-65);
% dymaConfig(7).JointPosition = 0;
% show(dyma, dymaConfig);
% hold on
% fill3(dyma_reach.pitch.cartx, dyma_reach.pitch.carty, dyma_reach.pitch.cartz, "r", "FaceAlpha","0.5");
% fill3(dyma_reach.elbow.cartx, dyma_reach.elbow.carty+0.01, dyma_reach.elbow.cartz, "g", "FaceAlpha","0.5");
% fill3(dyma_reach.wrist.cartx, dyma_reach.wrist.carty+0.02, dyma_reach.wrist.cartz, "b", "FaceAlpha","0.5");
% title("Dymaflight Workspace Reach Along Global Y-Axis [3D]");
% xlabel("x-reach (meters)");
% ylabel("y-reach (meters)");
% zlabel("z-reach (meters)");
% grid on
% axis equal
% 
% 
% % Sample unique points
% count = 1;
% sample_interval = floor(length(dyma_ws.full_unique.cartx)/15000);
% x_sample = zeros(sample_interval, 1);
% y_sample = zeros(sample_interval, 1);
% z_sample = zeros(sample_interval, 1);
% for i = 1:sample_interval:length(dyma_ws.full_unique.cartx)
%     x_sample(count) = dyma_ws.full_unique.cartx(i);
%     y_sample(count) = dyma_ws.full_unique.carty(i);
%     z_sample(count) = dyma_ws.full_unique.cartz(i);
%     count = count + 1;
% end
% 
% %% SUBSET OF UNIQUE CART POS PLOT
% figure
% % Reset dyma config
% dymaConfig(1).JointPosition = 0;
% dymaConfig(2).JointPosition = 0;
% dymaConfig(3).JointPosition = 0;
% dymaConfig(4).JointPosition = 0;
% dymaConfig(5).JointPosition = 0;
% dymaConfig(6).JointPosition = 0;
% dymaConfig(7).JointPosition = 0;
% show(dyma, dymaConfig);
% hold on
% scatter3(x_sample,y_sample,z_sample, 0.25, ".b");
% title("Subset of Unique Cartesian Positions in Dyma Workspace")
% xlabel("Cartesian X (meters)")
% ylabel("Cartesian Y (meters)")
% zlabel("Cartesian Z (meters)")
% xlim([-2,2]);
% ylim([-2,2]);
% zlim([-3,3]);
% axis equal
% 
% %% X Y DENSITY PLOT
% dymaConfig(1).JointPosition = 0;
% dymaConfig(2).JointPosition = pi/2;
% dymaConfig(3).JointPosition = 0;
% dymaConfig(4).JointPosition = 0;
% dymaConfig(5).JointPosition = 0;
% dymaConfig(6).JointPosition = 0;
% dymaConfig(7).JointPosition = 0;
% figure
% [values, centers] = hist3([transpose(dyma_ws.full.cartx), transpose(dyma_ws.full.carty)],[61, 61]);
% imagesc(centers{:}, values.')
% colormap(jet(numel(values)))
% c = colorbar;
% xlabel(c, "Number of Repeated Positions")
% title("Density Plot of Repeated Cartesian Positions With Different Joint Configuration")
% xlabel("Cartesian X (meters)")
% ylabel("Cartesian Y (meters)")
% axis equal
% axis xy
% hold on
% show(dyma, dymaConfig);
% 
% %% X Z DENSITY PLOT
% dymaConfig(1).JointPosition = 0;
% dymaConfig(2).JointPosition = pi/2;
% dymaConfig(3).JointPosition = 0;
% dymaConfig(4).JointPosition = 0;
% dymaConfig(5).JointPosition = 0;
% dymaConfig(6).JointPosition = 0;
% dymaConfig(7).JointPosition = 0;
% figure
% [values, centers] = hist3([transpose(dyma_ws.full.cartx), transpose(dyma_ws.full.cartz)],[61, 61]);
% imagesc(centers{:}, values.')
% colormap(jet(numel(values)))
% c = colorbar;
% xlabel(c, "Number of Repeated Positions")
% title("Density Plot of Repeated Cartesian Positions With Different Joint Configuration")
% xlabel("Cartesian X (meters)")
% ylabel("Cartesian Z (meters)")
% axis equal
% axis xy
% hold on
% show(dyma_xz, dymaConfig);
% 
% %% Y Z DENSITY PLOT
% dymaConfig(1).JointPosition = pi/2;
% dymaConfig(2).JointPosition = pi/2;
% dymaConfig(3).JointPosition = 0;
% dymaConfig(4).JointPosition = 0;
% dymaConfig(5).JointPosition = 0;
% dymaConfig(6).JointPosition = 0;
% dymaConfig(7).JointPosition = 0;
% figure
% [values, centers] = hist3([transpose(dyma_ws.full.carty), transpose(dyma_ws.full.cartz)],[61, 61]);
% imagesc(centers{:}, values.')
% colormap(jet(numel(values)))
% c = colorbar;
% xlabel(c, "Number of Repeated Positions")
% title("Density Plot of Repeated Cartesian Positions With Different Joint Configuration")
% xlabel("Cartesian Y (meters)")
% ylabel("Cartesian Z (meters)")
% axis equal
% axis xy
% hold on
% show(dyma_xz, dymaConfig);

%% ANIMATION
% % figure
% % count = 1;
% % for i = 1:sample_interval:length(dyma_ws.full.q(1,:))
% %     hold off
% %     dymaConfig(1).JointPosition = dyma_ws.full.q(1,i);
% %     dymaConfig(2).JointPosition = dyma_ws.full.q(2,i);
% %     dymaConfig(3).JointPosition = dyma_ws.full.q(3,i);
% %     dymaConfig(4).JointPosition = dyma_ws.full.q(4,i);
% %     dymaConfig(5).JointPosition = dyma_ws.full.q(5,i);
% %     dymaConfig(6).JointPosition = dyma_ws.full.q(6,i);
% %     dymaConfig(6).JointPosition = dyma_ws.full.q(7,i);
% %     show(dyma, dymaConfig);
% %     hold on
% %     scatter3(x_sample, y_sample, z_sample, 0.25, ".r");
% %     count = count + 1;
% %     drawnow limitrate
% % end




clear i density samezies1 samezies2 samezies3 samezies4 samezies count tol_err_ant x_sample y_sample z_sample c values centers fig sample_interval dyma_yz



