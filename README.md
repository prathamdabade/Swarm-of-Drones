# Swarm Of Drones

Initial documentation and setup guide for getting started

## Summary

  - [Getting Started](#getting-started)
  - [Running the tests](#running-the-tests)
  - [A breakdown of the utils_api](#a-breakdown-of-the-utils_api)
  - [Development](#development)

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. Most of the code currently is made in python.

### Prerequisites

What things you need to get started and how to install them:
- ArduPilot, ROS, MAVROS:
    - You must have ArduPilot, ROS and MAVROS installed and working correctly on your system. If you've attended the Aero Club Summer School 2021 then you should have all three up and running. in case you do not have them, [install.sh](https://github.com/prathamdabade/Swarm-of-Drones/blob/master/scripts/install.sh) should get you going.  
- A ready-to-go catkin workspace: 
    - You should also have this requirement met If you've attended the Aero Club Summer School. if not then follow the [wiki](http://wiki.ros.org/ROS/Tutorials/InstallingandConfiguringROSEnvironment) to create your own catkin workspace(use catkin build instead of catkin_make).

### Installing

A step by step explanation of how to get the examples running:
1. first git clone the swarm_utils and swarm_main repos inside your workspace (~/catkin_ws/src/)
    - `git clone https://github.com/prathamdabade/swarm_utils.git`
    - `git clone https://github.com/prathamdabade/swarm_main.git`
2. Build the workspace using 
    - `catkin build`
3. Get your environment setup by  `source devel/setup.bash` or `source devel/setup.zsh` depending on the shell you use. (recommended that everyone switch to zsh in the future.)
4. Changes to ArduPilot files for ease of use.
    - Each Drone in your swarm will be producing mavlink messages. In order to discern what message is from which drone, we will need to assign each drone a unique system ID. This is controlled by the parameter `SYSID_THISMAV`.
    - First, we will want to edit the file `ardupilot/Tools/autotest/pysim/vehicleinfo.py` add the following lines in the SIM section. (Just after `gazebo-iris` entry)
    ```
            "gazebo-drone1": {
                "waf_target": "bin/arducopter",
                "default_params_filename": ["default_params/copter.parm",
                                            "default_params/gazebo-drone1.parm"],
            },
            "gazebo-drone2": {
                "waf_target": "bin/arducopter",
                "default_params_filename": ["default_params/copter.parm",
                                            "default_params/gazebo-drone2.parm"],
            },
            "gazebo-drone3": {
                "waf_target": "bin/arducopter",
                "default_params_filename": ["default_params/copter.parm",
                                            "default_params/gazebo-drone3.parm"],
            },

    ```
    - Now we need to add the corresponding `.parm` file in the `ardupilot/Tools/autotest/default_params` folder.
        - `gazebo-drone1.parm`
        - `gazebo-drone2.parm`
        - `gazebo-drone3.parm`
    - The `gazebo-drone1.parm` should look like this
    ```
    # Iris is X frame
    FRAME_CLASS 1
    FRAME_TYPE  1
    # IRLOCK FEATURE
    RC8_OPTION 39
    PLND_ENABLED    1
    PLND_TYPE       3
    # SONAR FOR IRLOCK
    SIM_SONAR_SCALE 10
    RNGFND1_TYPE 1
    RNGFND1_SCALING 10
    RNGFND1_PIN 0
    RNGFND1_MAX_CM 5000
    SYSID_THISMAV 1
    ```
    - The other two files should be exactly the same, just change the `SYSID_THISMAV` to `2` and `3` respectively.
    - Finally add the path to the models to the `GAZEBO_MODEL_PATH` variable by adding the following line to your bashrc or zshrc.`export GAZEBO_MODEL_PATH=${GAZEBO_MODEL_PATH}:$HOME/catkin_ws/src/swarm_main/models`. Then for the changes to take effect, do a `source ~/.bashrc` or `source ~/.zshrc`
## Running the tests

Some basic functionality is already implemented for testing and ease of use in future development

- `roslaunch swarm_main multi_drone.launch` should launch gazebo with three drones ready to be connected to SITL instances.
- The `multi_sitl.sh` script in `swarm_main/scripts` should get you the required SITL instances with proper parameters.
- `roslaunch swarm_main multi_apm.launch` should start up MAVROS and expose the drone inputs inside ROS.
- doing a `rostopic list` should give you a list of all the topics with proper drone namespaces.

### A breakdown of the tests

You can use the included `multi_takeoff.launch` file to issue a simple takeoff and land mission to the drones. Run it by `roslaunch swarm_main multi_takeoff.launch`. You should see all the three drones take off and land.

If you run the scripts one after the other too quickly you might see in the console a lot of arming errors. Don't panic, it's likely because the drones have not yet got a GPS lock which sometimes takes a minute or two to happen. The errors should clear out on their own and you should be able to arm properly.
## A breakdown of the utils_api
The `utils_api` is a collection of basic functions which are used in autonomous flight control applications in python.

To start using the api in your code use `from swarm_utils.utils_api import utils_api` to import and then instantiate to start using it.(`drone = utils_api()` used here as an example)

Listed below are the functions currently implemented:
- `utils_api.connect()` Waits for FCU (ArduPilot SITL) connection to be established.
    - eg. `drone.connect()` will wait for connection from SITL. 
- `utils_api.set_mode(mode)` Set the flight mode to the `string mode` argument provided.
    - eg. `drone.set_mode("GUIDED")` will set flight mode to "GUIDED".
- `utils_api.arm()` Attempts to arm the drone.
    - `drone.arm()` will try to arm the motors.
- `utils_api.takeoff(altitude)` Attempts to arm and take off to the given `float altitude` height.
    - eg. `drone.takeoff(3.5)` will start a takeoff to height a of 3.5m.
- `utils_api.land()` Initiates landing sequence over the current position.
    - eg. `drone.land()` initiates landing sequence.
- `utils_api.set_waypoint(x,y,z,yaw)` Move the drone to (x,y,z) with heading (yaw) degrees.
    - eg. `drone..set_waypoint(5,5,3,45)` will move the drone to (5,5,3) heading 45 deg.

Feel free to poke around and change some code to see the effects!

## Development

You can now start developing! The `utils_api` has almost all the bare minimum basic functions working readily, you just need to plug and play. But this is not completed yet. There are some incomplete functions which will be completed in due course. Feel free to complete the work or add some functions you think should be there!  
