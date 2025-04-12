#!/bin/bash

echo -e " \033[33;5m         ______                 __  _          __          __       \033[0m"
echo -e " \033[33;5m        / ____/________ _____  / /_( )_____   / /   ____ _/ /_      \033[0m"
echo -e " \033[33;5m       / /_  / ___/ __ \/ __ \/ //_/// ___/  / /   / __ \/ __ \     \033[0m"
echo -e " \033[33;5m      / __/ / /  / /_/ / / / / ,<   (__  )  / /___/ /_/ / /_/ /     \033[0m"
echo -e " \033[33;5m     /_/   /_/   \__,_/_/ /_/_/|_| /____/  /_____/\__,_/_.___/      \033[0m"
echo -e " \033[33;5m                                                                    \033[0m"

echo -e " \033[36;5m            __ ____________    ____             __                  \033[0m" 
echo -e " \033[36;5m           / //_/__  / ___/   / __ \___  ____  / /___  __  __       \033[0m"
echo -e " \033[36;5m          / ,<   /_ <\__ \   / / / / _ \/ __ \/ / __ \/ / / /       \033[0m"
echo -e " \033[36;5m         / /| |___/ /__/ /  / /_/ /  __/ /_/ / / /_/ / /_/ /        \033[0m"
echo -e " \033[36;5m        /_/ |_/____/____/  /_____/\___/ .___/_/\____/\__, /         \033[0m"
echo -e " \033[32;5m                                /_/            /____/               \033[0m"
echo -e " \033[36;5m                                                                    \033[0m"
echo -e " \033[32;5m               https://github.com/mali9n/kubernetes                 \033[0m"
echo -e " \033[32;5m                                                                    \033[0m"


#############################################
# YOU SHOULD ONLY NEED TO EDIT THIS SECTION #
#############################################

# Version of Kube-VIP to deploy
KVVERSION="v0.8.10"

# K3S Version
k3sVersion="v1.31.5+k3s1"

# Set the IP addresses of the work nodes, add more as needed
master=192.168.40.21

# User of remote machines
user=ubuntu

# Interface used on remotes
interface=eth0

#ssh certificate name variable
certName=id_rsa

#ssh config file
config_file=~/.ssh/config

#############################################
#        WORKER NODE INPUT MENU             #
#############################################

echo -e "\n\033[36;1mEnter the IP addresses of the worker nodes.\033[0m"
echo -e "\033[36;1mSeparate multiple IPs with a space, then press [Enter]:\033[0m"
read -rp "Worker IPs: " -a workers

if [ ${#workers[@]} -eq 0 ]; then
  echo -e "\033[31;1mNo worker IPs provided. Exiting.\033[0m"
  exit 1
fi

#############################################
#            DO NOT EDIT BELOW              #
#############################################
# Step 1: Install policycoreutils for each node
for newnode in "${workers[@]}"; do
  ssh $user@$newnode -i ~/.ssh/$certName sudo su <<EOF
NEEDRESTART_MODE=a apt-get install policycoreutils -y
exit
EOF
  echo -e " \033[32;5mPolicyCoreUtils installed!\033[0m"
done

# Step 2: Add new workers
for newagent in "${workers[@]}"; do
  k3sup join \
    --ip $newagent \
	  --user $user \
	  --sudo \
		--k3s-version $k3sVersion \
		--server-ip $master \
		--ssh-key $HOME/.ssh/$certName \
		--k3s-extra-args "--node-label \"longhorn=true\" --node-label \"worker=true\""
  echo -e " \033[32;5mAgent node joined successfully!\033[0m"
done
