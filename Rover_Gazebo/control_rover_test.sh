gz topic -t "/clearance_arm_joint_pos" -m gz.msgs.Double -p "data: 0.6"
sleep 2
gz topic -t "/shoulder_mount_joint_pos" -m gz.msgs.Double -p "data: 1"
sleep 6
gz topic -t "/right_front_wheel_joint_pos" -m gz.msgs.Double -p "data: 250"
gz topic -t "/left_front_wheel_joint_pos" -m gz.msgs.Double -p "data: -250"
gz topic -t "/right_back_wheel_joint_pos" -m gz.msgs.Double -p "data: 250"
gz topic -t "/left_back_wheel_joint_pos" -m gz.msgs.Double -p "data: -250"
sleep 12
gz topic -t "/joint1_pos" -m gz.msgs.Double -p "data: 4"
sleep 4
#gz topic -t "/joint2_pos" -m gz.msgs.Double -p "data: 2"
sleep 4
gz topic -t "/joint3_pos" -m gz.msgs.Double -p "data: 1"
sleep 4
gz topic -t "/joint4_pos" -m gz.msgs.Double -p "data: 2"
sleep 4
#gz topic -t "/joint5_pos" -m gz.msgs.Double -p "data: 3"
#sleep 4
#gz topic -t "/joint6_pos" -m gz.msgs.Double -p "data: 2"
sleep 4
#gz topic -t "/joint1_pos" -m gz.msgs.Double -p "data: 2"
sleep 4
gz topic -t "/gripper_right_joint_pos" -m gz.msgs.Double -p "data: 2"
gz topic -t "/gripper_left_joint_pos" -m gz.msgs.Double -p "data: -2"
