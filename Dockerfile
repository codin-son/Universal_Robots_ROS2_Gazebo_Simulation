FROM osrf/ros:humble-desktop

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive
ENV ROS_DISTRO=humble
ENV COLCON_WS=/opt/ur_ws

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    python3-colcon-common-extensions \
    python3-rosdep \
    python3-vcstool \
    ros-humble-gazebo-ros-pkgs \
    && rm -rf /var/lib/apt/lists/*

RUN rosdep init 2>/dev/null || true
RUN rosdep update

WORKDIR ${COLCON_WS}/src

COPY . ${COLCON_WS}/src/Universal_Robots_ROS2_Gazebo_Simulation

RUN vcs import ${COLCON_WS}/src < \
    ${COLCON_WS}/src/Universal_Robots_ROS2_Gazebo_Simulation/Universal_Robots_ROS2_Gazebo_Simulation.humble.repos

RUN apt-get update && rosdep install --from-paths ${COLCON_WS}/src --ignore-src -r -y \
    --rosdistro ${ROS_DISTRO} && rm -rf /var/lib/apt/lists/*

WORKDIR ${COLCON_WS}

RUN source /opt/ros/${ROS_DISTRO}/setup.bash && \
    colcon build --symlink-install

COPY docker/entrypoint.sh /ros_entrypoint_ur.sh
RUN chmod +x /ros_entrypoint_ur.sh

ENTRYPOINT ["/ros_entrypoint_ur.sh"]
CMD ["bash"]
