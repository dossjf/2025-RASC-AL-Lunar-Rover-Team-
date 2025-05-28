
close all

addpath("kinematics\")
addpath("gridfitdir\gridfitdir\")

% Import da robits from the URDF file
nbv = importNBV("");

% set the current config as the zero config for da robits
nbvConfig = homeConfiguration(nbv);

nbvDH = [
  0.0,        0.0,          0.2872,        0.0; 
  0.0,        pi/2,         0.0,           0.0;  
  0.5589,    -pi,           0.0,           0.0;    
  0.1514,     pi/2,         0.5388,        0.0;  
  0.0,       -pi/2,         0.0,           0.0;
  0.0,        pi/2,         0.0,           0.0;
  0.0,        0.0,          0.2666,        0.0];

nbvDH_mod = nbvDH;

nbv_limits = [-pi    pi;
      -deg2rad(25)   pi+deg2rad(25);
            -pi/2    pi/2;
              -pi    pi;
 -pi/2-deg2rad(25)   pi/2+deg2rad(25);
              -pi    pi];

iter_per_joint_array = [deg2rad(90),deg2rad(15),deg2rad(15),deg2rad(15),deg2rad(15),deg2rad(180)];

iter_val = deg2rad(2);

% PTICH ANALYSIS
count = 1;
for th2 = nbv_limits(2,1):iter_val:nbv_limits(2,2)
    for th3 = nbv_limits(3,1):iter_val:nbv_limits(3,2)
        for th5 = nbv_limits(5,1):iter_val:nbv_limits(5,2)
            count = count+1;
        end
    end
end
use_count = count-1;

% Allocate array lengths
q = zeros(use_count,6);
cartx = zeros(use_count, 1);
carty = zeros(use_count, 1);
cartz = zeros(use_count, 1);

% reset counter
count = 1;
for th2 = nbv_limits(2,1):iter_val:nbv_limits(2,2)
    th2
    for th3 = nbv_limits(3,1):iter_val:nbv_limits(3,2)
        for th5 = nbv_limits(5,1):iter_val:nbv_limits(5,2)
            q(count, 1) = 0;
            q(count, 2) = th2;
            q(count, 3) = th3;
            q(count, 4) = 0;
            q(count, 5) = th5;
            q(count, 6) = 0;

            nbvDH_mod(1,4) = nbvDH(1,4)+0;
            nbvDH_mod(2,4) = nbvDH(2,4)+th2;
            nbvDH_mod(3,4) = nbvDH(3,4)+th3;
            nbvDH_mod(4,4) = nbvDH(4,4)+0;
            nbvDH_mod(5,4) = nbvDH(5,4)+th5;
            nbvDH_mod(6,4) = nbvDH(6,4)+0;

            % Compute the final output pose
            T_final = SslModifDhTableToTransf(0, 7, nbvDH_mod);
            cartx(count) = T_final(1,4); % Save the value in the x vector
            carty(count) = T_final(2,4); % Save the value in the y vector
            cartz(count) = T_final(3,4); % Save the value in the z vector
            count = count + 1;
        end
    end
end

% get the manip index
nbv = importNBV("");
nbv_rotate = importNBV("xz");
index = manipulabilityIndex(nbv, q);

figure
show(nbv_rotate, Position=[0,0,0.5, 0])
hold on
h = scatter3(cartx, cartz, index, 10, 'filled');
colormap(jet(numel(index)))
h.CData = index;
colorbar();
axis equal;
title("Manipuability Index based on Cartesian Position")
xlabel("x-axis (meters)")
ylabel("z-axis (meters)")
view([0,0,1]);
camproj("orthographic");


