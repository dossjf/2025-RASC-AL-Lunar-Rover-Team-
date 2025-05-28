gz topic -t "/joint7_pos" -m gz.msgs.Double -p "data: 4"
gz topic -t "/clearance_arm_joint_pos" -m gz.msgs.Double -p "data: 0.4"
sleep 2
gz topic -t "/shoulder_mount_joint_pos" -m gz.msgs.Double -p "data: 1"
sleep 6
gz topic -t "/right_front_wheel_joint_pos" -m gz.msgs.Double -p "data: 700"
gz topic -t "/left_front_wheel_joint_pos" -m gz.msgs.Double -p "data: -700"
gz topic -t "/right_back_wheel_joint_pos" -m gz.msgs.Double -p "data: 700"
gz topic -t "/left_back_wheel_joint_pos" -m gz.msgs.Double -p "data: -700"
sleep 2
gz topic -t "/gripper_right_joint_pos" -m gz.msgs.Double -p "data: -1"
gz topic -t "/gripper_left_joint_pos" -m gz.msgs.Double -p "data: -1"
sleep 2
gz topic -t "/joint4_pos" -m gz.msgs.Double -p "data: 1"
sleep 2
gz topic -t "/gripper_right_joint_pos" -m gz.msgs.Double -p "data: -1"
gz topic -t "/gripper_left_joint_pos" -m gz.msgs.Double -p "data: 1"
sleep 2
gz topic -t "/gripper_right_joint_pos" -m gz.msgs.Double -p "data: 1"
gz topic -t "/gripper_left_joint_pos" -m gz.msgs.Double -p "data: -1"
