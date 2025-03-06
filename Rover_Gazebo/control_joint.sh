gz topic -t "/segment_4.2_joint_pos" -m gz.msgs.Double -p "data: -1"
sleep 4
gz topic -t "/shoulder_mount_joint_pos" -m gz.msgs.Double -p "data: 2"
sleep 4
gz topic -t "/segment_3.2_joint_pos" -m gz.msgs.Double -p "data: -20"
sleep 4
#gz topic -t "/segment_2_joint_pos" -m gz.msgs.Double -p "data: -20"
#sleep 4
#gz topic -t "/segment_1_joint_pos" -m gz.msgs.Double -p "data: -20"
#sleep 4
gz topic -t "/clearance_arm_joint_pos" -m gz.msgs.Double -p "data: -2"
sleep 4
gz topic -t "/joint1_pos" -m gz.msgs.Double -p "data: -4"
sleep 4
gz topic -t "/joint2_pos" -m gz.msgs.Double -p "data: -4"
sleep 4
