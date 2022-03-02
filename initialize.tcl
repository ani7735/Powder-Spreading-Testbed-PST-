#Program for a spreading testbed with 2 axis (XY) configuration


# Homes the group, including both positioners, does nothing else



# Main process 

set TimeOut 20 

set code 0 

set group "Assembly"

set axis1 "Assembly.recoater"

set axis2 "Assembly.build_platform"



# Open TCP socket 

OpenConnection $TimeOut socketID 

if {$socketID == -1} { 

	puts stdout "OpenConnection failed => $socketID" 

	return 

} 

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



# Close TCP socket 

TCP_CloseSocket $socketID 

