gz topic -t "/gripper_right_joint_pos" -m gz.msgs.Double -p "data: -16"
sleep 2
gz topic -t "/gripper_left_joint_pos" -m gz.msgs.Double -p "data: 16"
sleep 2
sleep 4
gz topic -t "/shoulder_mount_joint_pos" -m gz.msgs.Double -p "data: 2"
sleep 4
gz topic -t "/right_front_wheel_joint_pos" -m gz.msgs.Double -p "data: 10"
gz topic -t "/right_back_wheel_joint_pos" -m gz.msgs.Double -p "data: 10"
gz topic -t "/left_front_wheel_joint_pos" -m gz.msgs.Double -p "data: 10"
gz topic -t "/left_back_wheel_joint_pos" -m gz.msgs.Double -p "data: 10"
sleep 10
#kill %1
#echo "Recording completed. Log file saved to $LOG_FILE"
#cat ~/.gazebo/log/rover_motion_*.log
