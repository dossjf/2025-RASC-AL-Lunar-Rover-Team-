"""
from launch import LaunchDescription
from launch_ros.actions import Node
from launch.actions import IncludeLaunchDescription
from launch.launch_description_sources import PythonLaunchDescriptionSource
from ament_index_python.packages import get_package_share_directory
import os

def generate_launch_description():
    pkg_gazebo_ros = get_package_share_directory('gazebo_ros')
    urdf_file = os.path.join(get_package_share_directory('my_package'), 'urdf', 'rover_4.urdf.xacro') # Adjust path
    world_file = os.path.join(pkg_gazebo_ros, 'worlds', 'world.world') # You can change to a different world

    #gazebo = IncludeLaunchDescription(
    #    PythonLaunchDescriptionSource(
    #        os.path.join(pkg_gazebo_ros, 'launch', 'gazebo.launch.py'),
    #    launch_arguments={'world': world_file}.items()
    #)
    
    
    # --- CHANGE 1: Launch gz sim ---
    gazebo_process = ExecuteProcess(
        cmd=['gz', 'sim', '-r', world_file],
        output='screen'
    )

    # --- CHANGE 2: Update spawn_entity node ---
    spawn_entity = Node(
        package='gazebo_ros2_control',
        executable='spawn_entity.py',
        arguments=['-entity', 'my_robot', # Adjust robot name
                   '-file', urdf_file,
                   '-spawn_service_timeout', '20.0'], # Increase timeout if needed
        output='screen'
    )






    spawn_entity = Node(
        package='gazebo_ros',
        executable='spawn_entity.py',
        arguments=['-entity', 'my_robot', # Adjust robot name
                   '-file', urdf_file,
                   '-spawn_service_timeout', '20.0'], # Increase timeout if needed
        output='screen'
    )

    robot_state_publisher = Node(
        package='robot_state_publisher',
        executable='robot_state_publisher',
        name='robot_state_publisher',
        output='screen',
        parameters=[{'robot_description': open(urdf_file).read()}]
    )

    return LaunchDescription([
        gazebo,
        spawn_entity,
        robot_state_publisher,
    ])
"""

import os
from launch import LaunchDescription
from launch.actions import ExecuteProcess
from launch_ros.actions import Node
from ament_index_python.packages import get_package_share_directory

def generate_launch_description():
    package_name = 'my_package'  # This should be your package name
    world_file_name = 'world.world'  # Replace with the actual name of your world file
    robot_urdf_file_name = 'rover_4.urdf.xacro'  # Or just 'rover_4.urdf' if you're not using XACRO
    #robot_urdf_file_name = 'rover_core.xacro'  # Or just 'rover_4.urdf' if you're not using XACRO
    robot_name_in_gazebo = 'rover'
    initial_x = '-500.0'
    initial_y = '200.0'
    initial_z = '100.0'
    initial_yaw = '3.1416'

    # Path to the world file
    world_path = os.path.join(
        get_package_share_directory(package_name),
        'worlds',
        world_file_name
    )

    # Path to the robot URDF file
    robot_urdf_path = os.path.join(
        get_package_share_directory(package_name),
        'description',
        robot_urdf_file_name
    )

    # Launch gz sim
    gazebo_process = ExecuteProcess(
        cmd=['gz', 'sim', '-r', world_path],
        output='screen'
    )

    # Spawn the robot using the GazeboRosSpawnEntity node
    spawn_entity = Node(
        package='gazebo_ros2_control',
        executable='spawn_entity.py',
        arguments=['-entity', robot_name_in_gazebo,
                   '-file', robot_urdf_path,
                   '-x', initial_x,
                   '-y', initial_y,
                   '-z', initial_z,
                   '-Y', initial_yaw],
        output='screen'
    )

    # Robot state publisher (adjust for gz sim if needed)
    
    robot_state_publisher = Node(
        package='robot_state_publisher',
        executable='robot_state_publisher',
        name='robot_state_publisher',
        output='screen',
        parameters=[{'robot_description': open(robot_urdf_path).read()}]
    )
    


    return LaunchDescription([
        gazebo_process,
        spawn_entity,
        robot_state_publisher,
    ])