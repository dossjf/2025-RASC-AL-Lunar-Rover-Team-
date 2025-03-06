gz topic -t "/segment_4.2_joint_pos" -m gz.msgs.Double -p "data: -1"
sleep 4
gz topic -t "/shoulder_mount_joint_pos" -m gz.msgs.Double -p "data: 2"
gz topic -t "/right_front_wheel_joint_pos" -m gz.msgs.Double -p "data: 10"
gz topic -t "/right_back_wheel_joint_pos" -m gz.msgs.Double -p "data: 10"
gz topic -t "/left_front_wheel_joint_pos" -m gz.msgs.Double -p "data: 10"
gz topic -t "/left_back_wheel_joint_pos" -m gz.msgs.Double -p "data: 10"
sleep 10
