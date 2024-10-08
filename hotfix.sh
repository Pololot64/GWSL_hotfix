#!/bin/bash

# THIS IS ONLY FOR WSL2 USERS


# Check if the "ip route" command is available

echo "Checking for ip command..."
if command -v ip &> /dev/null
then
    # Use ip route
    ip=$(ip route show | grep default | awk '{print $3}')
    # Create DISPLAY and PULSE_SERVER variables in such a way that they are interpreted on run and not when this script is run
    DISPLAY=$(ip route show | grep default | awk '{print $3}'):"0.0"
    PULSE_SERVER="tcp:"$(ip route show | grep default | awk '{print $3}')

    echo "Using ip route with ip" $ip
else
    # Otherwise, we use windows ipconfig
    ip=$(ipconfig.exe | grep -A 10 "vEthernet (WSL (Hyper-V firewall))" | grep "IPv4 Address" | sed -E 's/.*: ([0-9.]+)/\1/')

    # Create DISPLAY and PULSE_SERVER variables in such a way that they are interpreted on run and not when this script is run
    DISPLAY=$(ipconfig.exe | grep -A 10 "vEthernet (WSL (Hyper-V firewall))" | grep "IPv4 Address" | sed -E 's/.*: ([0-9.]+)/\1/'):"0.0"
    PULSE_SERVER="tcp:"$(ipconfig.exe | grep -A 10 "vEthernet (WSL (Hyper-V firewall))" | grep "IPv4 Address" | sed -E 's/.*: ([0-9.]+)/\1/')


    echo "Using ipconfig with ip" $ip
fi




# Now, the user may be using bash, zsh, or fish.
# We need to be able to add DISPLAY and PULSE_SERVER to their config files as environment variables.

# These could be .bashrc .profile .zshrc .config/fish/config.fish
# a list of the possible env files
env_files=(~/.bashrc ~/.profile ~/.zshrc ~/.config/fish/config.fish)

# First, however, we want to remove existing values of those variables using sed -i.bak

# Remove DISPLAY and PULSE_SERVER variable

echo "Removing existing DISPLAY and PULSE_SERVER variables from the following files:"

for file in "${env_files[@]}"
do
    sed -i.bak '/DISPLAY/d' $file
    sed -i.bak '/PULSE_SERVER/d' $file
    echo $file
done

# Now, we add the new values to the files. Add the comment #GWSL to each added line so we know where they came from
# for fish, we need to use set -gx instead of export
echo "Adding new DISPLAY and PULSE_SERVER variables to the following files:"

for file in "${env_files[@]}"
do
    if [[ $file == *".fish" ]]
    then
        echo "set -gx DISPLAY $DISPLAY #GWSL" >> $file
        echo "set -gx PULSE_SERVER $PULSE_SERVER #GWSL" >> $file
    else
        echo "export DISPLAY=$DISPLAY #GWSL" >> $file
        echo "export PULSE_SERVER=$PULSE_SERVER #GWSL" >> $file
    fi
    echo $file
done
