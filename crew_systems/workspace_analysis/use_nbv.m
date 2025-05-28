close all

% % Run the file to get sawyer workspace data
% if exist('nbv_ws','var') ~= 1
%     nbv_full_workspace
% end
% if exist('nbv_reach','var') ~= 1
%     nbv_reachable_workspace
% end
% 
% % Import da robits from the URDF file
% nbv = importNBV("");
% nbv_xz = importNBV("xz");
% 
% % set the current config as the zero config for da robits
% nbvConfig = homeConfiguration(nbv);
% 
% % Below is redundant for copy-past purposes
% nbvConfig(1).JointPosition = 0;
% nbvConfig(2).JointPosition = 0;
% nbvConfig(3).JointPosition = 0;
% nbvConfig(4).JointPosition = 0;
% nbvConfig(5).JointPosition = 0;
% nbvConfig(6).JointPosition = 0;
% 
% nbvConfig(2).JointPosition = pi;
% nbvConfig(3).JointPosition = pi/2;
% 
% % Show some plots
% % 3D YAW PLOT
% show(nbv, nbvConfig);
% hold on
% fill3(nbv_reach.yaw.cartx, nbv_reach.yaw.carty, nbv_reach.yaw.cartz, "r", "FaceAlpha","0.5");
% title("NBV Workspace Reach Along Global Z-Axis [3D]");
% xlabel("x-reach (meters)");
% ylabel("y-reach (meters)");
% zlabel("z-reach (meters)");
% grid on
% axis equal
% 
% % 2D YAW PLOT
% figure;
% fill(nbv_reach.yaw.cartx, nbv_reach.yaw.carty, "r", "FaceAlpha","0.5");
% hold on
% show(nbv, nbvConfig);
% title("NBV Workspace Reach Along Global Z-Axis [2D]");
% xlabel("x-reach (meters)");
% ylabel("y-reach (meters)");
% grid on
% axis equal
% 
% 
% nbvConfig(1).JointPosition = 0;
% nbvConfig(2).JointPosition = pi+deg2rad(25);
% nbvConfig(3).JointPosition = pi/2;
% nbvConfig(4).JointPosition = 0;
% nbvConfig(5).JointPosition = 0;
% nbvConfig(6).JointPosition = 0;
% % 3D PITCH PLOT
% figure;
% show(nbv, nbvConfig);
% hold on
% fill3(nbv_reach.pitch.cartx, nbv_reach.pitch.carty, nbv_reach.pitch.cartz, "r", "FaceAlpha","0.5");
% title("NBV Workspace Reach Along Global Y-Axis [3D]");
% xlabel("x-reach (meters)");
% ylabel("y-reach (meters)");
% zlabel("z-reach (meters)");
% grid on
% axis equal
% 
% % 2D PITCH PLOT
% figure;
% show(nbv, nbvConfig);
% hold on
% fill3(nbv_reach.pitch.cartx, nbv_reach.pitch.carty, nbv_reach.pitch.cartz, "r", "FaceAlpha","0.5");
% title("NBV Workspace Reach Along Global Y-Axis [2D]");
% view([0,1,0]);
% camproj("orthographic");
% 
% xlabel("x-reach (meters)");
% zlabel("z-reach (meters)");
% xlim([-1.5, 1.5]);
% zlim([-1,2]);
% grid on
% 
% nbvConfig(1).JointPosition = 0;
% nbvConfig(2).JointPosition = pi+deg2rad(25);
% nbvConfig(3).JointPosition = -deg2rad(10);
% nbvConfig(4).JointPosition = 0;
% nbvConfig(5).JointPosition = 0;
% nbvConfig(6).JointPosition = 0;
% % 3D Elbow plot
% figure
% show(nbv, nbvConfig);
% hold on
% fill3(nbv_reach.pitch.cartx, nbv_reach.pitch.carty, nbv_reach.pitch.cartz, "r", "FaceAlpha","0.5");
% fill3(nbv_reach.elbow.cartx, nbv_reach.elbow.carty+0.01, nbv_reach.elbow.cartz, "g", "FaceAlpha","0.5");
% title("NBV Workspace Reach Along Global Y-Axis [3D]");
% xlabel("x-reach (meters)");
% ylabel("y-reach (meters)");
% zlabel("z-reach (meters)");
% grid on
% axis equal
% 
% % Full workspace plot
% count = 1;
% sample_interval = floor(length(nbv_ws.full_unique.cartx)/10000);
% x_sample = zeros(sample_interval, 1);
% y_sample = zeros(sample_interval, 1);
% z_sample = zeros(sample_interval, 1);
% for i = 1:sample_interval:length(nbv_ws.full_unique.cartx)
%     x_sample(count) = nbv_ws.full_unique.cartx(i);
%     y_sample(count) = nbv_ws.full_unique.carty(i);
%     z_sample(count) = nbv_ws.full_unique.cartz(i);
%     count = count + 1;
% end
% 
% figure
% % Reset NBV config
% nbvConfig(1).JointPosition = pi;
% nbvConfig(2).JointPosition = deg2rad(101.5);
% nbvConfig(3).JointPosition = deg2rad(-78.5);
% nbvConfig(4).JointPosition = 0;
% nbvConfig(5).JointPosition = deg2rad(90);
% nbvConfig(6).JointPosition = 0;
% show(nbv, nbvConfig);
% hold on
% scatter3(x_sample,y_sample,z_sample, 0.25, ".b");
% title("Subset of Unique Cartesian Positions in NBV Workspace");
% xlabel("Cartesian X (meters)");
% ylabel("Cartesian Y (meters)");
% zlabel("Cartesian Z (meters)");
% xlim([-2,2]);
% ylim([-2,2]);
% zlim([-1,2]);
% axis equal
% 
% % Plot density plots
% figure
% [values, centers] = hist3([transpose(nbv_ws.full.cartx), transpose(nbv_ws.full.carty)],[51 51]);
% imagesc(centers{:}, values.');
% c = colorbar;
% xlabel(c, "Number of Repeated Positions");
% title("Density Plot of Repeated Cartesian Positions With Different Joint Configuration");
% xlabel("Cartesian X (meters)");
% ylabel("Cartesian Y (meters)");
% axis equal;
% axis xy;
% hold on;
% nbvConfig(1).JointPosition = 0;
% nbvConfig(2).JointPosition = pi;
% nbvConfig(3).JointPosition = pi/2;
% nbvConfig(4).JointPosition = 0;
% nbvConfig(5).JointPosition = 0;
% nbvConfig(6).JointPosition = 0;
% show(nbv, nbvConfig)
% 
% figure
% [values, centers] = hist3([transpose(nbv_ws.full.cartx), transpose(nbv_ws.full.cartz)],[51 51]);
% imagesc(centers{:}, values.');
% c = colorbar;
% xlabel(c, "Number of Repeated Positions");
% title("Density Plot of Repeated Cartesian Positions With Different Joint Configuration");
% xlabel("Cartesian X (meters)");
% ylabel("Cartesian Z (meters)");
% axis equal;
% axis xy;
% hold on;
% nbvConfig(1).JointPosition = 0;
% nbvConfig(2).JointPosition = pi;
% nbvConfig(3).JointPosition = pi/2;
% nbvConfig(4).JointPosition = 0;
% nbvConfig(5).JointPosition = 0;
% nbvConfig(6).JointPosition = 0;
% show(nbv_xz, nbvConfig)
% 
% figure;
% [values, centers] = hist3([transpose(nbv_ws.full.carty), transpose(nbv_ws.full.cartz)],[51 51]);
% imagesc(centers{:}, values.');
% c = colorbar;
% xlabel(c, "Number of Repeated Positions");
% title("Density Plot of Repeated Cartesian Positions With Different Joint Configuration");
% xlabel("Cartesian Y (meters)");
% ylabel("Cartesian Z (meters)");
% axis equal;
% axis xy;
% hold on;
% nbvConfig(1).JointPosition = pi/2;
% nbvConfig(2).JointPosition = pi;
% nbvConfig(3).JointPosition = pi/2;
% nbvConfig(4).JointPosition = 0;
% nbvConfig(5).JointPosition = 0;
% nbvConfig(6).JointPosition = 0;
% show(nbv_xz, nbvConfig)
% % 
% % figure
% % count = 1;
% % for i = 1:sample_interval:length(nbv_ws.full.q(1,:))
% %     hold off
% %     nbvConfig(1).JointPosition = nbv_ws.full.q(1,i);
% %     nbvConfig(2).JointPosition = nbv_ws.full.q(2,i);
% %     nbvConfig(3).JointPosition = nbv_ws.full.q(3,i);
% %     nbvConfig(4).JointPosition = nbv_ws.full.q(4,i);
% %     nbvConfig(5).JointPosition = nbv_ws.full.q(5,i);
% %     nbvConfig(6).JointPosition = nbv_ws.full.q(6,i);
% %     show(nbv, nbvConfig);
% %     hold on
% %     scatter3(x_sample, y_sample, z_sample, 0.25, ".r");
% %     count = count + 1;
% %     drawnow limitrate
% % end


% Plot manip index plots
figure
[X,Y] = meshgrid(1:0.5:10,1:20);
Z = sin(X) + cos(Y);
surf(X,Y,Z)



clear i density samezies1 samezies2 samezies3 samezies4 samezies count tol_err_ant c ans centers x_sample y_sample z_sample sample_interval nbv_xz nbv values



%%% DEPRECATED
% % Condition data for contouring
% tol_err_ant = 1e-8; % tolerance value
% 
% % First, xy plane:
% x = transpose(nbv_ws.full.cartx);
% y = transpose(nbv_ws.full.carty);
% [x_ordered, index] = sort(x); % create and ordered list of x values
% y_ordered(length(index)) = 0;
% y_ordered(:) = y(index(:)); % create a non-ordered list of y values, but they correspond to their matching x values
% 
% % get array size
% count = 1;
% for i = 2:length(nbv_ws.full.cartx)
%     % compare the values with a tolerance and see if they are equal
%     samezies1 = x_ordered(i) < x_ordered(i-1)+tol_err_ant;
%     samezies2 = y_ordered(i) < y_ordered(i-1)+tol_err_ant;
%     samezies3 = x_ordered(i) > x_ordered(i-1)-tol_err_ant;
%     samezies4 = y_ordered(i) > y_ordered(i-1)-tol_err_ant;
%     samezies = [samezies1,samezies2,samezies3,samezies4];
%     % samezies = [x_ordered(i), y_ordered(i)] == [x_ordered(i-1), y_ordered(i-1)];
% 
%     % Check to see if both logical arrays contain true values - if any
%     % element is false then they are not the same xy point
%     if(all(samezies) == true) % Then they are the same x-y coordinates
%     else
%         count = count + 1;
%     end
% end
% 
% % Allocate density array
% xy_density(count,3) = 0;
% 
% % Now get the actual data
% count = 1;
% density = 0;
% xy_density(1, 1) = x_ordered(1); % initial value
% xy_density(1, 2) = y_ordered(1); % initial value
% for i = 2:length(nbv_ws.full.cartx)
%     % Compare the values with a tolerance and see if they are equal
%     samezies1 = x_ordered(i) < x_ordered(i-1)+tol_err_ant;
%     samezies2 = y_ordered(i) < y_ordered(i-1)+tol_err_ant;
%     samezies3 = x_ordered(i) > x_ordered(i-1)-tol_err_ant;
%     samezies4 = y_ordered(i) > y_ordered(i-1)-tol_err_ant;
%     samezies = [samezies1,samezies2,samezies3,samezies4];
% 
%     % get data
%     xy_density(count, 1) = x_ordered(i);
%     xy_density(count, 2) = y_ordered(i);
%     if(all(samezies) == true) % Then they are the same x-y coordinates
%         density = density + 1;
%         xy_density(count, 4) = density;
%     else
%         count = count + 1;
%         density = 0;
%     end
% end