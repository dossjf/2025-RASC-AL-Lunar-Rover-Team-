
close all
% clear
addpath("kinematics\")

dymaDH = [
    0            0              0.18161         0;
    0            pi/2           0.0             0;
    0           -pi/2           0.430022        0;
   -0.041402     pi/2           0.0             0;
    0.041402    -pi/2           0.37084         0;
    0.033274     pi/2           0.0             0;
   -0.033274    -pi/2           0.0             0;
    0            0              0.314325        0];

dymaDH_no_ee = [
    0            0              0.18161         0;
    0            pi/2           0.0             0;
    0           -pi/2           0.430022        0;
   -0.041402     pi/2           0.0             0;
    0.041402    -pi/2           0.37084         0;
    0.033274     pi/2           0.0             0;
   -0.033274    -pi/2           0.0             0;
    0            0              0.148247        0];

dymaDH_mod = dymaDH;
dymaDH_mod_no_ee = dymaDH_no_ee;

dyma_limits = [ -pi              pi;
                -deg2rad(120)    deg2rad(120);
                -pi              pi;
                 0               pi;
                -pi              pi;
                -pi               0;
                -pi              pi];


iter_val = deg2rad(1.25);

% % Import da robits from the URDF file
% dyma = importDyma("");
% dyma_no_ee = importDyma("no ee");
% dyma_rotate = importDyma("xz");
% dyma_rotate_no_ee = importDyma("xz_no_ee");
% 
% % PTICH ANALYSIS
% count = 1;
% for th2 = dyma_limits(2,1):iter_val:dyma_limits(2,2)
%     for th4 = dyma_limits(4,1):iter_val:dyma_limits(4,2)
%         for th6 = dyma_limits(6,1):iter_val:dyma_limits(6,2)
%             count = count+1;
%         end
%     end
% end
% use_count = count-1;
% 
% % Allocate array lengths
% q = zeros(use_count,7);
% cartx = zeros(use_count, 1);
% carty = zeros(use_count, 1);
% cartz = zeros(use_count, 1);
% cartx_ee = zeros(use_count, 1);
% carty_ee = zeros(use_count, 1);
% cartz_ee = zeros(use_count, 1);
% 
% % reset counter
% count = 1;
% for th2 = dyma_limits(2,1):iter_val:dyma_limits(2,2)
%     th2
%     for th4 = dyma_limits(4,1):iter_val:dyma_limits(4,2)
%         for th6 = dyma_limits(6,1):iter_val:dyma_limits(6,2)
%             q(count, 1) = 0;
%             q(count, 2) = th2;
%             q(count, 3) = 0;
%             q(count, 4) = th4;
%             q(count, 5) = 0;
%             q(count, 6) = th6;
%             q(count, 7) = 0;
% 
%             dymaDH_mod(1,4) = dymaDH(1,4)+0;
%             dymaDH_mod(2,4) = dymaDH(2,4)+th2;
%             dymaDH_mod(3,4) = dymaDH(3,4)+0;
%             dymaDH_mod(4,4) = dymaDH(4,4)+th4;
%             dymaDH_mod(5,4) = dymaDH(5,4)+0;
%             dymaDH_mod(6,4) = dymaDH(6,4)+th6;
%             dymaDH_mod(7,4) = dymaDH(7,4)+0;
% 
%             dymaDH_mod_no_ee(1,4) = dymaDH_no_ee(1,4)+0;
%             dymaDH_mod_no_ee(2,4) = dymaDH_no_ee(2,4)+th2;
%             dymaDH_mod_no_ee(3,4) = dymaDH_no_ee(3,4)+0;
%             dymaDH_mod_no_ee(4,4) = dymaDH_no_ee(4,4)+th4;
%             dymaDH_mod_no_ee(5,4) = dymaDH_no_ee(5,4)+0;
%             dymaDH_mod_no_ee(6,4) = dymaDH_no_ee(6,4)+th6;
%             dymaDH_mod_no_ee(7,4) = dymaDH_no_ee(7,4)+0;
% 
%             % Compute the final output pose
%             T_final = SslModifDhTableToTransf(0, 8, dymaDH_mod);
%             T_final_no_ee = SslModifDhTableToTransf(0, 8, dymaDH_mod_no_ee);
% 
%             cartx(count) = T_final(1,4); % Save the value in the x vector
%             carty(count) = T_final(2,4); % Save the value in the y vector
%             cartz(count) = T_final(3,4); % Save the value in the z vector
% 
%             cartx_no_ee(count) = T_final_no_ee(1,4); % Save the value in the x vector
%             carty_no_ee(count) = T_final_no_ee(2,4); % Save the value in the y vector
%             cartz_no_ee(count) = T_final_no_ee(3,4); % Save the value in the z vector
% 
%             count = count + 1;
%         end
%     end
% end
% 
% % get the manip index
% index = manipulabilityIndex(dyma, q);
% inverse_index = manipulabilityIndex(dyma, q, IndexType="inverse-condition");
% index_no_ee = manipulabilityIndex(dyma_no_ee, q);
% inverse_index_no_ee = manipulabilityIndex(dyma_no_ee, q, IndexType="inverse-condition");

figure
show(dyma_rotate, Position=[0,0,0.2, 0])
hold on
h = scatter3(cartx, cartz, index, 10, 'filled');
colormap(jet(numel(index)))
h.CData = index;
c = colorbar();
c.Label.String = "Manipuability Index Value";
axis equal
title("Manipuability Index based on Cartesian Position")
xlabel("x-axis (meters)")
ylabel("z-axis (meters)")
view([0,0,1]);
camproj("orthographic");
%% 
figure
show(dyma_rotate_no_ee, Position=[0,0,0.2, 0])
hold on
h = scatter3(cartx_no_ee, cartz_no_ee, index_no_ee, 10, 'filled');
colormap(jet(numel(index_no_ee)))
h.CData = index_no_ee;
c = colorbar();
c.Label.String = "Manipuability Index Value";
axis equal;
title("Manipuability Index based on Cartesian Position (Reduced Reach)");
xlabel("x-axis (meters)");
ylabel("z-axis (meters)");
view([0,0,1]);
camproj("orthographic");
%%

% Inverse
figure
show(dyma_rotate, Position=[0,0,0.2, 0])
hold on
h = scatter3(cartx, cartz, inverse_index, 10, 'filled');
colormap(jet(numel(inverse_index)))
h.CData = inverse_index;
c = colorbar();
c.Label.String = "Inverse Condition Index Value";
axis equal
title("Inverse Condition Index based on Cartesian Position")
xlabel("x-axis (meters)")
ylabel("z-axis (meters)")
view([0,0,1]);
camproj("orthographic");

%%
figure
show(dyma_rotate_no_ee, Position=[0,0,0.2, 0])
hold on
h = scatter3(cartx_no_ee, cartz_no_ee, inverse_index_no_ee, 10, 'filled');
colormap(jet(numel(inverse_index_no_ee)))
h.CData = inverse_index_no_ee;
c = colorbar();
c.Label.String = "Inverse Condition Index Value";
axis equal;
title("Inverse Condition Index based on Cartesian Position (Reduced Reach)");
xlabel("x-axis (meters)");
ylabel("z-axis (meters)");
view([0,0,1]);
camproj("orthographic");
%%


