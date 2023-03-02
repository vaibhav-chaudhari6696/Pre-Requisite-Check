#!/bin/bash

# get the file system list from the file
filesystems=$(cat file_systems.txt)

# get the file system information using the df command
df_output=$(df -T)
#df_output=$(sshpass -p "R@ckware123" ssh "root@129.146.182.179" "df -T")

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
