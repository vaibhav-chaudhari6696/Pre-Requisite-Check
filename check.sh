#!/bin/bash



# Define the path to the text file containing the list of devices
devices_list="./devices.txt"

# Loop through each line in the text file

while read line; do
    # Extract the host address, username, and password from the line
    host=$(echo $line | cut -d ' ' -f 1)
    username=$(echo $line | cut -d ' ' -f 2)
    password=$(echo $line | cut -d ' ' -f 3)


    # host=$1
    # username=$2
    # password=$3


    #get the operating system and version
    os=$(sshpass -p "$password" ssh "$username@$host" "cat /etc/*-release ")
    osname=$(echo "$os" | grep "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/"//g')
    # check if the os and version are in the list
    if grep -q "^$osname$" os_list.txt; then
        echo "OS $osname is Supported."
    else
        echo "OS $osname is not Supported."
    fi


    # Check if the current user is root user or not
    idval=$(sshpass -p "$password" ssh "$username@$host" "id -u")
    if [ $idval -eq 0 ]; then
        echo "User $username is the root user."
    else
        echo "User $username is not the root user."
    fi


    # check if port 22 is open and listening
    if $(sshpass -p "$password" ssh "$username@$host" "ss -tln | grep -q ":22 ""); then
        echo "Port 22 is already open and listening."
    else
        # if port 22 is not open, open it using ufw
        echo "Port 22 is not open. "
        #$(sshpass -p "$password" ssh "$username@$host" "sudo ufw allow 22")
        #echo "Port 22 is now open."
    fi

    #check if the hypervisor is in the list.
    hypervisor=$(sshpass -p "$password" ssh "$username@$host" "systemd-detect-virt")
    if grep -qi "^${hypervisor// /.*}.*$" hypervisor_list.txt; then
        echo "Hypervisor $hypervisor is Supported."
    else
        echo "Hypervisor $hypervisor is not Supported."
    fi





    # get the file system list from the file
    filesystems=$(cat file_systems.txt)
    # get the file system information using the df command
    df_output=$(sshpass -p "$password" ssh "$username@$host" "df -T")

    # loop through each file system in the list
    while read -r fs; do
        # search for a match in the df output
        if echo "$df_output" | grep -q "^/.*$fs "; then
            if echo "$filesystems" | grep -q "^$fs$"; then
                echo "Partition $(echo "$df_output" | grep "^/.*$fs " | awk '{print $1}') has file system $fs and it is in the list of file systems in the txt file."
            else
                echo "Partition $(echo "$df_output" | grep "^/.*$fs " | awk '{print $1}') has file system $fs and it is not in the list of file systems in the txt file."
            fi
        else
            echo "Partition with file system $fs not found on the system."
        fi
    done <<< "$filesystems"




done < "$devices_list"





