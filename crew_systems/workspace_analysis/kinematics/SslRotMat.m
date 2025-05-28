% --------------------- %
% -- ROMEO PERLSTEIN -- %
% Rotation Matrix Maker %
% UMD Space Systems Lab %
% --------------------- %

% Returns the rotation matrix, in radians
function R = SslRotMat(angle, axis, deg_or_rad, size)
    if(deg_or_rad == "deg")
        angle = angle*(pi/180);
    elseif(deg_or_rad == "rad")
    else
        error("[ERROR - RotMat] deg_to_rad must be a string! Either input 'deg' or 'rad'")
    end
    if(size == 4)
        if(axis == "x" || axis == "X")
            R = [1 0 0 0; 0 cos(angle) -sin(angle) 0; 0 sin(angle) cos(angle) 0; 0 0 0 1];
        elseif(axis == "y" || axis == "Y")
            R = [cos(angle) 0 sin(angle) 0; 0 1 0 0; -sin(angle) 0 cos(angle) 0; 0 0 0 1];
        elseif(axis == "z" || axis == "Z")
            R = [cos(angle) -sin(angle) 0 0; sin(angle) cos(angle) 0 0; 0 0 1 0; 0 0 0 1];
        else
            error("[ERROR - RotMat] axis must either be 'x', 'y', or 'z' as a string!\n\n")
        end
    elseif(size == 3)
        if(axis == "x" || axis == "X")
            R = [1 0 0; 0 cos(angle) -sin(angle); 0 sin(angle) cos(angle)];
        elseif(axis == "y" || axis == "Y")
            R = [cos(angle) 0 sin(angle); 0 1 0; -sin(angle) 0 cos(angle)];
        elseif(axis == "z" || axis == "Z")
            R = [cos(angle) -sin(angle) 0; sin(angle) cos(angle) 0; 0 0 1];
        else
            error("[ERROR - RotMat] axis must either be 'x', 'y', or 'z' as a string!\n\n")
        end
    else
            error("[ERROR - RotMat] Supported sizes are 3x3 and 4x4!")
    end
end