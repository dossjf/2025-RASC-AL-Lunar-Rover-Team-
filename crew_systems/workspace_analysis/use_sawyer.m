close all

% Run the file to get sawyer workspace data
if exist('sawyer_ws','var') ~= 1
    sawyer_full_workspace
end
if exist('sawyer_reach','var') ~= 1
    sawyer_reachable_workspace
end

% Import da robits from the URDF file
sawyer = importSawyer("");
sawyer_xz = importSawyer("xz");

% set the current config as the zero config for da robits
sawyerConfig = homeConfiguration(sawyer);

% Below is redundant for copy-past purposes
sawyerConfig(1).JointPosition = 0;
sawyerConfig(2).JointPosition = 0;
sawyerConfig(3).JointPosition = 0;
sawyerConfig(4).JointPosition = 0;
sawyerConfig(5).JointPosition = 0;
sawyerConfig(6).JointPosition = 0;
sawyerConfig(7).JointPosition = 0;

% Show some plots
% 3D YAW PLOT
show(sawyer, sawyerConfig);
hold on
fill3(sawyer_reach.yaw.cartx, sawyer_reach.yaw.carty, sawyer_reach.yaw.cartz, "r", "FaceAlpha","0.5");
title("Sawyer Workspace Reach Along Global Z-Axis [3D]");
xlabel("x-reach (meters)");
ylabel("y-reach (meters)");
zlabel("z-reach (meters)");
grid on
axis equal

% 2D YAW PLOT
figure;
fill(sawyer_reach.yaw.cartx, sawyer_reach.yaw.carty, "r", "FaceAlpha","0.5");
hold on
show(sawyer, sawyerConfig);
title("Sawyer Workspace Reach Along Global Z-Axis [2D]");
xlabel("x-reach (meters)");
ylabel("y-reach (meters)");
grid on
axis equal


% 3D PITCH PLOT
sawyerConfig(1).JointPosition = 0;
sawyerConfig(2).JointPosition = deg2rad(30);
sawyerConfig(3).JointPosition = pi/2;
sawyerConfig(4).JointPosition = 0;
sawyerConfig(5).JointPosition = 0;
sawyerConfig(6).JointPosition = 0;
sawyerConfig(7).JointPosition = 0;
figure;
show(sawyer, sawyerConfig);
hold on
fill3(sawyer_reach.pitch.cartx, sawyer_reach.pitch.carty, sawyer_reach.pitch.cartz, "r", "FaceAlpha","0.5");
title("Sawyer Workspace Reach Along Global Y-Axis [3D]");
xlabel("x-reach (meters)");
ylabel("y-reach (meters)");
zlabel("z-reach (meters)");
grid on
axis equal

% 2D PITCH PLOT
figure;
show(sawyer, sawyerConfig);
hold on
fill3(sawyer_reach.pitch.cartx, sawyer_reach.pitch.carty, sawyer_reach.pitch.cartz, "r", "FaceAlpha","0.5");
title("Sawyer Workspace Reach Along Global Y-Axis [2D]");
view([0,1,0]);
camproj("orthographic");
xlabel("x-reach (meters)");
zlabel("z-reach (meters)");
xlim([-1.5, 1.5]);
zlim([-1, 2]);
grid on


% Full workspace plot
count = 1;
sample_interval = floor(length(sawyer_ws.full_unique.cartx)/10000);
x_sample = zeros(sample_interval, 1);
y_sample = zeros(sample_interval, 1);
z_sample = zeros(sample_interval, 1);
for i = 1:sample_interval:length(sawyer_ws.full_unique.cartx)
    x_sample(count) = sawyer_ws.full_unique.cartx(i);
    y_sample(count) = sawyer_ws.full_unique.carty(i);
    z_sample(count) = sawyer_ws.full_unique.cartz(i);
    count = count + 1;
end

figure
% Reset sawyer config
sawyerConfig(1).JointPosition = 0;
sawyerConfig(2).JointPosition = 0;
sawyerConfig(3).JointPosition = 0;
sawyerConfig(4).JointPosition = 0;
sawyerConfig(5).JointPosition = 0;
sawyerConfig(6).JointPosition = 0;
sawyerConfig(7).JointPosition = 0;

show(sawyer, sawyerConfig);
hold on
scatter3(x_sample,y_sample,z_sample, 0.25, ".b");
title("Subset of Unique Cartesian Positions in Sawyer Workspace")
xlabel("Cartesian X (meters)")
ylabel("Cartesian Y (meters)")
zlabel("Cartesian Z (meters)")
xlim([-2,2]);
ylim([-2,2]);
zlim([-3,3]);
axis equal

figure
[values, centers] = hist3([transpose(sawyer_ws.full.cartx), transpose(sawyer_ws.full.carty)],[101 101]);
imagesc(centers{:}, values.')
colormap(jet(numel(values)))
c = colorbar;
xlabel(c, "Number of Repeated Positions")
title("Density Plot of Repeated Cartesian Positions With Different Joint Configuration")
xlabel("Cartesian X (meters)")
ylabel("Cartesian Y (meters)")
axis equal
axis xy
hold on
show(sawyer, sawyerConfig);

figure
[values, centers] = hist3([transpose(sawyer_ws.full.cartx), transpose(sawyer_ws.full.cartz)],[101 101]);
imagesc(centers{:}, values.')
colormap(jet(numel(values)))
c = colorbar;
xlabel(c, "Number of Repeated Positions")
title("Density Plot of Repeated Cartesian Positions With Different Joint Configuration")
xlabel("Cartesian X (meters)")
ylabel("Cartesian Z (meters)")
axis equal
axis xy
hold on
sawyerConfig(1).JointPosition = pi;
sawyerConfig(2).JointPosition = 0;
sawyerConfig(3).JointPosition = 0;
sawyerConfig(4).JointPosition = 0;
sawyerConfig(5).JointPosition = 0;
sawyerConfig(6).JointPosition = 0;
sawyerConfig(7).JointPosition = 0;
show(sawyer_xz, sawyerConfig);

figure
[values, centers] = hist3([transpose(sawyer_ws.full.carty), transpose(sawyer_ws.full.cartz)],[101 101]);
imagesc(centers{:}, values.')
colormap(jet(numel(values)))
c = colorbar;
xlabel(c, "Number of Repeated Positions")
title("Density Plot of Repeated Cartesian Positions With Different Joint Configuration")
xlabel("Cartesian Y (meters)")
ylabel("Cartesian Z (meters)")
axis equal
axis xy
hold on
sawyerConfig(1).JointPosition = -pi/2;
sawyerConfig(2).JointPosition = 0;
sawyerConfig(3).JointPosition = 0;
sawyerConfig(4).JointPosition = 0;
sawyerConfig(5).JointPosition = 0;
sawyerConfig(6).JointPosition = 0;
sawyerConfig(7).JointPosition = 0;
show(sawyer_xz, sawyerConfig);

% figure
% count = 1;
% for i = 1:sample_interval:length(sawyer_ws.full.q(1,:))
%     hold off
%     sawyerConfig(1).JointPosition = sawyer_ws.full.q(1,i);
%     sawyerConfig(2).JointPosition = sawyer_ws.full.q(2,i);
%     sawyerConfig(3).JointPosition = sawyer_ws.full.q(3,i);
%     sawyerConfig(4).JointPosition = sawyer_ws.full.q(4,i);
%     sawyerConfig(5).JointPosition = sawyer_ws.full.q(5,i);
%     sawyerConfig(6).JointPosition = sawyer_ws.full.q(6,i);
%     sawyerConfig(6).JointPosition = sawyer_ws.full.q(7,i);
%     show(sawyer, sawyerConfig);
%     hold on
%     scatter3(x_sample, y_sample, z_sample, 0.25, ".r");
%     count = count + 1;
%     drawnow limitrate
% end




clear i density samezies1 samezies2 samezies3 samezies4 samezies count tol_err_ant x_sample y_sample z_sample c values centers fig sample_interval sawyer_yz


