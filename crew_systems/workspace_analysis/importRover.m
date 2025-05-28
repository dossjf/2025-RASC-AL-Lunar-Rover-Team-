function robot = importRover(rbt)
    if(rbt == "dyma")
        robot = importrobot("./dymaflight/urdf/rover_crane_dyma.urdf");
    elseif(rbt == "dyma_xz")
        robot = importrobot("./dymaflight/urdf/rover_crane_dyma_xz.urdf");
    elseif(rbt == "sawyer")
        robot = importrobot("./rover_crane/urdf/rover_crane_arms/rover_crane_sawyer.urdf");
    elseif(rbt == "xz")
        robot = importrobot("./rover_crane/urdf/rover_crane/rover_crane_for_density_xz.urdf");
    elseif(rbt == "manip")
        robot = importrobot("./rover_crane/urdf/rover_crane/rover_crane_manip.urdf");
    elseif(rbt == "old1")
        robot = importrobot("./rover_crane/urdf/rover_crane/rover_crane_old1.urdf");
    elseif(rbt == "old2")
        robot = importrobot("./rover_crane/urdf/rover_crane/rover_crane_old2.urdf");
    elseif(rbt == "crane_old2")
        robot = importrobot("./rover_crane/urdf/crane/crane_old2.urdf");
    elseif(rbt == "crane")
        robot = importrobot("./rover_crane/urdf/crane/crane.urdf");
    else
        robot = importrobot("./rover_crane/urdf/rover_crane/rover_crane.urdf");
    end

end