#!/bin/bash

# dockercli script - created by RevHarryPowell
# User-friendly way of starting a shell in a docker contaier
# Run this from your docker host machine
# Optionally, create an alias in your .bashrc to point to this script

# Color definitions
RED='\033[1;31m'       	# Bold Red
YELLOW='\033[1;33m'    	# Bold Yellow
NC='\033[0m' 			# No Color

container=""
function container_chooser {

        # List containers and prompt user to select one
        declare -i ContainerNum=$(docker ps | wc -l)-1
        #echo $ContainerNum
        docker ps --format "{{.Names}}" | nl -s ") "
        echo -e "${YELLOW}Choose a docker container (index)${NC}"

        # Only accept an integer input
        declare -i dc=0
        while [[ $dc -le 0 ]] || [[ $dc -gt $ContainerNum ]]; do
                read dc
                if [[ $dc -le 0 ]] || [[ $dc -gt $ContainerNum ]]; then
                        echo -e "${RED}Invalid input. Please enter a valid index.${NC}"
                fi
        done

        container=$(docker ps --format "{{.Names}}" | awk "NR==$dc")
}

# Process input to get container name
if [ -z "$1" ]; then

	# If no argument (i.e. container name) is provided, run container_chooser func
	container_chooser
else

	# If argument is provided, check if it's a valid container name, otherwise run container_chooser func
	input=$1
	running=$(docker ps --format "{{.Names}}")
	if echo "$running" | grep -q "^${input}$"; then
		container=$1
	else
		echo -e "${RED}\""$1"\" is not a valid container name${NC}"
		container_chooser
	fi
fi

# Start bash or sh terminal in selected container, whichever is supported
if docker exec $container /bin/bash | grep -q "exec failed"; then
	echo -e "${YELLOW}Entering "$container" sh CLI...${NC}"
	docker exec -it $container /bin/sh
else
	echo -e "${YELLOW}Entering "$container" bash CLI...${NC}"
    docker exec -it $container /bin/bash
fi
