function robot = importDyma(rbt)
    if(rbt == "xz")
        robot = importrobot("./dymaflight/urdf/dymaflight_for_density_xz.urdf");
    elseif(rbt == "xz_no_ee")
        robot = importrobot("./dymaflight/urdf/dymaflight_for_density_xz_no_ee.urdf");
    elseif(rbt == "xy")
        robot = importrobot("./dymaflight/urdf/dymaflight_for_density_xy.urdf");
    elseif(rbt == "no ee")
        robot = importrobot("./dymaflight/urdf/dymaflight_no_ee.urdf");
    elseif(rbt == "crane")
        robot = importrobot("./dymaflight/urdf/rover_crane_dyma.urdf");
    else
        robot = importrobot("./dymaflight/urdf/dymaflight.urdf");
    end
end