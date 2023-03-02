#!/bin/bash

# Check if the current user is root user or not
if [ $(id -u) -eq 0 ]; then
    echo "You are the root user."
else
    echo "You are not the root user."
fi
