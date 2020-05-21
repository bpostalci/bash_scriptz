#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "Run as root"
   exit 1
fi

declare -a APT_APPS=(
"vim-gtk3" 
"git" 
"build-essential" 
"redshift-gtk"
"python3-pip"
"htop"
)

declare -a SNAP_APPS=(
"go"
"spotify"
)

declare -a PYTHON_APPS=(
"thefuck"
)

apt-get update
apt-get -y upgrade

for app in "${APT_APPS[@]}";do
	apt-get install -y "$app"
done

for app in "${SNAP_APPS[@]}";do
	snap install "$app" --classic
done

for app in "${PYTHON_APPS[@]}";do
	pip3 install "$app"
done
