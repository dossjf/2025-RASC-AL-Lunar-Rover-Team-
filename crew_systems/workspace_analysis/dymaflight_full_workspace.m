% --------------------- %
% ---- ENAE484 TEAM --- %
%  Workspace generator  %
% --------------------- %
% --------------------- %

addpath("./kinematics/")

% RECALL THAT DH TABLES START i=0 IS THE BASE LINK, i.e [0,0,0]
% units are degrees and meters

% Make a DH table for refernce
% __|      a(i-1),            alpha(i-1),       d(i),         theta(i)
% 1 |       a0,                 alpha0,         d1,           theta1 
% 2 |       a1,                 alpha1,         d2,           theta2;  
%   |       .                     .             .               .   
%   |       .                     .             .               .   
%   |       .                     .             .               .  
% j |       aj-1,               alphaj-1,       dj,           thetaj;  

% DYMAFLIGHT DH table (for reference)
% __|       a(i-1)      alpha(i-1)      d(i)        theta(i)
% 1 |       0           0               0.18161        th1
% 2 |       0           pi/2            0.0            th2
% 3 |       0          -pi/2            0.430022       th3
% 4 |      -0.041402    pi/2            0.0            th4
% 5 |       0.041402   -pi/2            0.37084        th5
% 6 |       0.033274    pi/2            0.0            th6
% 7 |      -0.033274   -pi/2            0.0            th7
% T |       0           0               0.314325       0

dymaDH = [
    0            0              0.18161         0;
    0            pi/2           0.0             0;
    0           -pi/2           0.430022        0;
   -0.041402     pi/2           0.0             0;
    0.041402    -pi/2           0.37084         0;
    0.033274     pi/2           0.0             0;
   -0.033274    -pi/2           0.0             0;
    0            0              0.0             0];
    % 0            0              0.314325        0];

dymaDH_mod = dymaDH;

dyma_limits = [ -pi              pi;
                -deg2rad(120)    deg2rad(120);
                -pi              pi;
                 0               pi;
                -pi              pi;
                -pi               0;
                -pi              pi];

iter_per_joint_array = [deg2rad(45),deg2rad(10),deg2rad(20),deg2rad(15),deg2rad(20),deg2rad(15),deg2rad(90)];


% Get the recquired vector length so we don't make it too big
if(length(iter_per_joint_array) ~= 7)
    error("Dymaflights's iter_per_joint_array must be length of 7! must contain desired iterations for each joint")
end

count = 1;
for th1=dyma_limits(1,1):iter_per_joint_array(1):dyma_limits(1,2)
    for th2=dyma_limits(2,1):iter_per_joint_array(2):dyma_limits(2,2)
        for th3=dyma_limits(3,1):iter_per_joint_array(3):dyma_limits(3,2)
            for th4=dyma_limits(4,1):iter_per_joint_array(4):dyma_limits(4,2)
                for th5=dyma_limits(5,1):iter_per_joint_array(5):dyma_limits(5,2)
                    for th6=dyma_limits(6,1):iter_per_joint_array(6):dyma_limits(6,2)
                        for th7=dyma_limits(7,1):iter_per_joint_array(7):dyma_limits(7,2)
                            count = count+1;
                        end
                    
                    end
                end
            end
        end
    end
end
fprintf("Array length: " + int2str(count) + "\n")

% Pre-allocate the array sizes
dyma_ws.full.cartx = zeros(1,count);
dyma_ws.full.carty = zeros(1,count);
dyma_ws.full.cartz = zeros(1,count);
dyma_ws.full.q = zeros(7,count);

% reset counter
count = 1; 
% Begin the long ass iteration (its so over)
for th1=dyma_limits(1,1):iter_per_joint_array(1):dyma_limits(1,2)
    fprintf("Started interation, current J1 angle is " )
    th1
    for th2=dyma_limits(2,1):iter_per_joint_array(2):dyma_limits(2,2)
        for th3=dyma_limits(3,1):iter_per_joint_array(3):dyma_limits(3,2)
            for th4=dyma_limits(4,1):iter_per_joint_array(4):dyma_limits(4,2)
                for th5=dyma_limits(5,1):iter_per_joint_array(5):dyma_limits(5,2)
                    for th6=dyma_limits(6,1):iter_per_joint_array(6):dyma_limits(6,2)
                        for th7=dyma_limits(7,1):iter_per_joint_array(7):dyma_limits(7,2)
                            % Iterate the joint positions (theta values)
                            dymaDH_mod(1,4) = th1;
                            dymaDH_mod(2,4) = th2;
                            dymaDH_mod(3,4) = th3;
                            dymaDH_mod(4,4) = th4;
                            dymaDH_mod(5,4) = th5;
                            dymaDH_mod(6,4) = th6;
                            dymaDH_mod(7,4) = th7;

    
                            % Compute the final output pose
                            T_final = SslModifDhTableToTransf(0, 8, dymaDH_mod);
                            dyma_ws.full.cartx(count) = T_final(1,4); % Save the value in the x vector
                            dyma_ws.full.carty(count) = T_final(2,4); % Save the value in the y vector
                            dyma_ws.full.cartz(count) = T_final(3,4); % Save the value in the z vector
                            % Save the joint state that we are currently at
                            dyma_ws.full.q(1,count) = dymaDH(1,4) + th1;
                            dyma_ws.full.q(2,count) = dymaDH(2,4) + th2;
                            dyma_ws.full.q(3,count) = dymaDH(3,4) + th3;
                            dyma_ws.full.q(4,count) = dymaDH(4,4) + th4;
                            dyma_ws.full.q(5,count) = dymaDH(5,4) + th5;
                            dyma_ws.full.q(6,count) = dymaDH(6,4) + th6;
                            dyma_ws.full.q(7,count) = dymaDH(7,4) + th7;
                            count = count + 1; % iterate up
                        end
                    end
                end
            end
        end
    end
end

dyma_mat = [dyma_ws.full.cartx(:), dyma_ws.full.carty(:), dyma_ws.full.cartz(:)];
cart = unique(dyma_mat, "rows", "stable");
dyma_ws.full_unique.cartx(:) = cart(:,1);
dyma_ws.full_unique.carty(:) = cart(:,2);
dyma_ws.full_unique.cartz(:) = cart(:,3);

% Now save the vector outputs
file_name = "data/dyma_ws_no_ee";
save(file_name, "dyma_ws", "-v7.3");


clear cart dyma_mat dymaDH_mod th1 th2 th3 th4 th5 th6 th7 data_length iter_per_joint_array T_final count file_name i 