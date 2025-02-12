close all
addpath("kinematics\")

sawyerDH = [ 
    0.081       -pi/2           0.317            0;
    0           -pi/2           0.1925          -pi/2;
    0           -pi/2           0.4             -pi;
    0           -pi/2          -0.1685          -pi;
    0           -pi/2           0.4             -pi;
    0           -pi/2           0.1363          -pi;
    0            0               0.13375         -pi;
    0            0               0                0];

craneDH = [
    0            0              0.3             0;
    0           -pi/2           0.0             0;
    0            pi/2           3.396           0;
   -0.1         -pi/2           0              -1.261657;
   -0.34         pi/2           0.1             0];

% Run the file to get crane reach workspace data
if exist('crane_reach','var') ~= 1
    crane_reachable_workspace
end

% Run the file to get crane full workspace data
if exist('crane_ws','var') ~= 1
    crane_full_workspace
end

% Run the file to get sawyer workspace data
if exist('sawyer_ws','var') ~= 1
    sawyer_full_workspace
end
if exist('sawyer_reach','var') ~= 1
    sawyer_reachable_workspace
end

% Import da robits from the URDF file
sawyer = importSawyer;
rover = importRover("sawyer");

roverConfig = homeConfiguration(rover);
roverConfig(1).JointPosition = 0;%deg2rad(-15);
roverConfig(2).JointPosition = -pi/2;
roverConfig(3).JointPosition = 2.264;
show(rover, roverConfig)
xlim([-6.5,6.5])
ylim([-6.5,6.5])
zlim([0,8])
hold on
fill3(crane_reach.yaw.cartx, crane_reach.yaw.carty, crane_reach.yaw.cartz, "r", "FaceAlpha","0.5");

roverConfig(1).JointPosition = 0;
roverConfig(2).JointPosition = deg2rad(-45);
roverConfig(3).JointPosition = 2.264;
show(rover, roverConfig)
xlim([-6.5,6.5])
ylim([-6.5,6.5])
zlim([0,8])
hold on
fill3(crane_reach.pitch.cartx, crane_reach.pitch.carty, crane_reach.pitch.cartz, "g", "FaceAlpha","0.5");

figure
roverConfig(1).JointPosition = 0;
roverConfig(2).JointPosition = deg2rad(-45);
roverConfig(3).JointPosition = 2.264;
show(rover, roverConfig)
xlim([-6.5,6.5])
ylim([-6.5,6.5])
zlim([0,8])
hold on
scatter3(crane_ws.full_unique.cart(:,1),crane_ws.full_unique.cart(:,2),crane_ws.full_unique.cart(:,3), "r");

% figure
% % set the current config as the zero config for da robits
% sawyerConfig = homeConfiguration(sawyer);
% robotConfig = homeConfiguration(robot);
% 
% % Below is redundant for copy-past purposes
% sawyerConfig(1).JointPosition = 0;
% sawyerConfig(2).JointPosition = 0;
% sawyerConfig(3).JointPosition = 0;
% sawyerConfig(4).JointPosition = 0;
% sawyerConfig(5).JointPosition = 0;
% sawyerConfig(6).JointPosition = 0;
% sawyerConfig(7).JointPosition = 0;
% 
% % show(sawyer, sawyerConfig)
% show(sawyer)
% hold on
% show(robot, robotConfig)
% 
% 
% % sawyerConfig(2).JointPosition = pi;
% % sawyerConfig(3).JointPosition = pi/2;
% % 
% % Show some plots
% % 3D YAW PLOT
% show(sawyer, sawyerConfig)
% hold on
% fill3(sawyer_reach.yaw.cartx, sawyer_reach.yaw.carty, sawyer_reach.yaw.cartz, "r", "FaceAlpha","0.5");
% title("Sawyer Workspace Reach Along Global Z-Axis [3D]")
% xlabel("x-reach (meters)")
% ylabel("y-reach (meters)")
% zlabel("z-reach (meters)")
% grid on
% axis equal
% 
% % 2D YAW PLOT
% figure
% fill(sawyer_reach.yaw.cartx, sawyer_reach.yaw.carty, "r", "FaceAlpha","0.5");
% hold on
% show(sawyer, sawyerConfig)
% title("Sawyer Workspace Reach Along Global Z-Axis [2D]")
% xlabel("x-reach (meters)")
% ylabel("y-reach (meters)")
% grid on
% axis equal
% 
% 
% sawyerConfig(1).JointPosition = 0;
% sawyerConfig(2).JointPosition = pi+deg2rad(25);
% sawyerConfig(3).JointPosition = 0;
% sawyerConfig(4).JointPosition = 0;
% sawyerConfig(5).JointPosition = 0;
% sawyerConfig(6).JointPosition = 0;
% sawyerConfig(7).JointPosition = 0;
% % 3D PITCH PLOT
% figure
% show(sawyer, sawyerConfig)
% hold on
% fill3(sawyer_reach.pitch.cartx, sawyer_reach.pitch.carty, sawyer_reach.pitch.cartz, "r", "FaceAlpha","0.5");
% title("Sawyer Workspace Reach Along Global Y-Axis [3D]")
% xlabel("x-reach (meters)")
% ylabel("y-reach (meters)")
% zlabel("z-reach (meters)")
% grid on
% axis equal
% 
% % 2D PITCH PLOT
% fig = figure;
% show(sawyer, sawyerConfig)
% hold on
% fill3(sawyer_reach.pitch.cartx, sawyer_reach.pitch.carty, sawyer_reach.pitch.cartz, "r", "FaceAlpha","0.5");
% title("Sawyer Workspace Reach Along Global Y-Axis [2D]")
% view([0,1,0])
% camproj("orthographic")
% 
% xlabel("x-reach (meters)")
% zlabel("z-reach (meters)")
% xlim([-1.5, 1.5])
% zlim([-1,2])
% grid on
% 
% sawyerConfig(1).JointPosition = 0;
% sawyerConfig(2).JointPosition = 0;
% sawyerConfig(3).JointPosition = 0;
% sawyerConfig(4).JointPosition = 0;
% sawyerConfig(5).JointPosition = 0;
% sawyerConfig(6).JointPosition = 0;
% sawyerConfig(7).JointPosition = 0;
% % 3D PITCH PLOT
% figure
% show(sawyer, sawyerConfig)
% hold on
% fill3(sawyer_reach.pitch.cartx, sawyer_reach.pitch.carty, sawyer_reach.pitch.cartz, "r", "FaceAlpha","0.5");
% fill3(sawyer_reach.yaw.cartx, sawyer_reach.yaw.carty, sawyer_reach.yaw.cartz, "r", "FaceAlpha","0.5");
% title("Sawyer Workspace Reach Along Global Y-Axis [3D]")
% xlabel("x-reach (meters)")
% ylabel("y-reach (meters)")
% zlabel("z-reach (meters)")
% grid on
% axis equal

% % Plot full workspace
% sawyerConfig(1).JointPosition = 0;
% sawyerConfig(2).JointPosition = 0;
% sawyerConfig(3).JointPosition = 0;
% sawyerConfig(4).JointPosition = 0;
% sawyerConfig(5).JointPosition = 0;
% sawyerConfig(6).JointPosition = 0;
% sawyerConfig(7).JointPosition = 0;
% figure
% show(sawyer, sawyerConfig)
% [x, y, z] = sphere(35);
% r = max(sawyer_reach.yaw.cartx);
% hold on
% surf(x*r,y*r,(z*r)+sawyerDH(1,3), FaceAlpha=0.25, FaceColor="g");
% fill3(sawyer_reach.yaw.cartx, sawyer_reach.yaw.carty, sawyer_reach.yaw.cartz, "r", "FaceAlpha","0.5");
% grid on
% axis equal


