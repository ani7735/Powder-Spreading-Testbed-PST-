#Program for a spreading testbed with 2 axis (XY) configuration


# Homes the group, including both positioners, Z axis first, then X axis

# The maximum velocity of the recoater and the layer height are user controlled

# The total gap (T.G.) and Initial gap (I.G.) has been manually evaluated

# Build platform or Z axis moves first, Z axis is sent directly to the layer height 

# Move X axis or recoater to the end point.

# There is a 3 second delay between every movement to reduce vibration 

# The recoater speed is converted to allow user input in cm/s

# This program has been calibrated for the small spreader

# The maximum possible input velocity is 14.5 cm/s, do not exceed this limit.


# Main process 

set TimeOut 20 

set code 0 

set group "Assembly"

set axis1 "Assembly.recoater"

set axis2 "Assembly.build_platform"

# Start point set to the home preset

# The start points and end points are arbitrary for now

set start_point 10 

set end_point 20

#Set a starting position for the build platform

set build_platform_start 0

after 3000


# Open TCP socket 

OpenConnection $TimeOut socketID 

if {$socketID == -1} { 

	puts stdout "OpenConnection failed => $socketID" 

	return 

} 

# Recover the input arguments entered by the user



# In total there are eight aruguments, in this case argument 0 is used for Telnet channel identifier

if {$tcl_argc == 2} {

#Here the entire velocity profile will be taken, the controller uses a Sgamma type of motion profile

#Do not exceed Max Velocity of 14.5 it will damage

set MaximumVelocity $tcl_argv(0) 

set layer_height $tcl_argv(1)

# layer_height = T.G.- Z.G., here a random value of dist has been used


set vel [expr $MaximumVelocity/0.243]

set max_acceleration 2

set min_jerktime 0.005

set max_jerktime 0.05

} else {

puts "Wrong number of parameters, 2 arguments are needed"

set code [catch "TCP_CloseSocket $socketID"]

return

}

# Currently only the recoater speed is user controllable

set code [catch "PositionerSGammaParametersSet $socketID Assembly.recoater $vel $max_acceleration $min_jerktime $max_jerktime"] 

if {$code != 0} { 

	DisplayErrorAndClose $socketID $code "PositionerSGammaParametersSet" 

	return 

} 

#Sequence 1: Homing

#Kills the group

set code [catch "GroupKill $socketID Assembly"]

if {$code != 0} {

DisplayErrorAndClose $socketID $code "GroupKill"

return
}


# Initalize the group

set code [catch "GroupInitialize $socketID Assembly"]

if {$code != 0} {

DisplayErrorAndClose $socketID $code "GroupInitialize"

return
}

# Homes the group

set code [catch "GroupHomeSearch $socketID Assembly"]

if {$code != 0} {

DisplayErrorAndClose $socketID $code "GroupHomeSearch"

return
}

after 3000

# Sequence 2: Motion for build platform

# Move the build platform upwards to the desired layer_height = T.G.-Z.G.

set code [catch "GroupMoveAbsolute $socketID $axis2 $layer_height"]

if {$code != 0} {

DisplayErrorAndClose $socketID $code "GroupMoveAbsolute"

return

}

after 3000

# Sequence 3: Now move the X axis

# Move recoater to end position

set code [catch "GroupMoveAbsolute $socketID $axis1 $end_point"]

if {$code != 0} {

DisplayErrorAndClose $socketID $code "GroupMoveAbsolute" 

return
}

# Close TCP socket 

TCP_CloseSocket $socketID 

