#!/bin/bash

set -e

echo "*****************************************************************************"
echo
echo "Setup script to install ros melodic, Ardupilot sitl with Gazebo "
echo
echo


wget  http://packages.osrfoundation.org/gazebo.key
sudo apt-key add gazebo.key


sudo apt-get update && sudo apt-get upgrade -y

read -p "Do you want to install ros-melodic-desktop-full ? [y/n]: " tempvar

tempvar=${tempvar:-q}

if [ "$tempvar" = "y" ]; then
    echo
    echo "Installing ros-melodic"
    echo
    cd $HOME
    sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
    sudo apt install git curl -y
    curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
    sudo apt update
    sudo apt install ros-melodic-desktop-full -y
    echo 'source /opt/ros/melodic/setup.sh' >> ~/.bashrc
    sudo apt install python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential -y
    sudo apt install python-rosdep -y
    sudo apt install python3-pip -y
    pip3 install -U rospkg
    pip3 install pymavlink
    sudo apt-get install python-rospkg -y
    sudo rosdep init
    rosdep update
    echo 
    echo "ROS installation completed"
    echo

elif [ "$tempvar" = "n" ];then
    echo
    echo "Skipping ros installation"
    echo
fi

read -p "do you want to install Ardupilot ? [y/n] : " tempvar

tempvar=${tempvar:-q}

if [ "$tempvar" = "y" ] ; then
    echo
    echo "Setting Ardupilot"
    echo
    cd $HOME
    sudo apt-get update
    sudo apt install python-pip -y
    pip install -U pymavlink MAVProxy
    sudo apt-get install libcanberra-gtk-module -y
    sudo apt-get install git -y
    sudo apt-get install gitk git-gui -y
    git clone https://github.com/ArduPilot/ardupilot.git
    sudo chown -R $(whoami): $HOME/ardupilot
    cd ardupilot
    git submodule update --init --recursive
    echo
    echo "git clone completed"
    echo
    sudo chown -R $(whoami): $HOME/ardupilot
    cd $HOME
    cd ardupilot
    Tools/environment_install/install-prereqs-ubuntu.sh -y
    . ~/.profile
    echo
    echo "Building bebop board"
    echo
    ./waf configure --board bebop --static
    ./waf copter
    cd $HOME
    echo 'export PATH=$PATH:$HOME/ardupilot/Tools/autotest' >> ~/.bashrc
    echo 'export PATH=/usr/lib/ccache:$PATH' >> ~/.bashrc
    echo
    echo "Building ardupilot_gazebo plugin"
    echo
    sudo sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list'
    wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -
    sudo apt update
    sudo apt install gazebo9 libgazebo9-dev -y
    echo 'export SVGA_VGPU10=0' >> ~/.bashrc
    git clone https://github.com/SwiftGust/ardupilot_gazebo
    sudo chown -R $(whoami): $HOME/ardupilot_gazebo
    cd $HOME
    cd ardupilot_gazebo
    git checkout gazebo9
    mkdir build
    cd build
    cmake ..
    make -j4
    sudo make install
    cd ../../
    echo 'source /usr/share/gazebo/setup.sh' >> ~/.bashrc
    echo 'export GAZEBO_MODEL_PATH=~/ardupilot_gazebo/gazebo_models' >> ~/.bashrc
    echo 'export GAZEBO_RESOURCE_PATH=~/ardupilot_gazebo/gazebo_worlds:${GAZEBO_RESOURCE_PATH}' >> ~/.bashrc
    echo
    echo "Ardupilot Installation completed"
    echo
elif [ "$tempvar" = "n" ];then
    echo
    echo "Skipping this step"
    echo
fi
read -p "Do you want to install mavros (y/n): " tempvar

tempvar=${tempvar:-q}

if [ "$tempvar" = "y" ]; then
    cd ..
    echo
    echo "Installing Mavros"
    echo
    sudo apt-get install ros-melodic-mavros ros-melodic-mavros-extras -y
    sudo wget https://raw.githubusercontent.com/mavlink/mavros/master/mavros/scripts/install_geographiclib_datasets.sh
    sudo chmod a+x install_geographiclib_datasets.sh
    sudo ./install_geographiclib_datasets.sh
    sudo apt-get install ros-melodic-rqt ros-melodic-rqt-common-plugins ros-melodic-rqt-robot-plugins -y
    sudo apt-get install python-catkin-tools -y
    echo
    echo "Mavros installation completed"
    echo

elif [ "$tempvar" = "n" ];then
    echo
    echo "Skipping this step"
    echo
fi