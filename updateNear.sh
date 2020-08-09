#!/bin/bash


#Bash script to place in a cron job on local server to check for updates of the lastest near version
#script should be run by a cron job hourly to detect the newest release in a timely fashion

source ~/.profile
ip=$(curl ifconfig.me)
network=$NEAR_NETWORK
image=$NEARCORE_DOCKER_IMAGE
msg="msg"
USER=$(whoami)
echo "Checking for updates"

diff <(curl -s https://rpc."$network".near.org/status | jq .version.version) <(curl -s http://127.0.0.1:3030/status | jq .version.version)
if [ $? -ne 0 ]; then
    echo "start update";
    version=$(curl -s https://rpc."$network".near.org/status | jq .version.version)
    strippedversion=$(echo "$version" | awk -F "\"" '{print $2}' | awk -F "-" '{print $1}')
    
    nearup stop
    nearup "$network" --image "$image"

    #Test new release

    echo "Testing image is updated"
    diff <(curl -s https://rpc."$network".near.org/status | jq .version) <(curl -s http://127.0.0.1:303"$count"/status | jq .version)
    if [ $? -eq 0 ]
    then
        msg="Validator update with new $network $versionStripped"
        twilio.sh "$msg"
        echo "Validator update with new $network $versionStripped"
    else
        cd && mv /home/$USER/nearcore.bak /home/$USER/nearcore
        msg="Node Upgade failed - Still running old version - Check setup immediately"
        echo $msg
        twilio.sh "$msg"
        exit 1
    fi
    

    echo "Upgrade complete"


fi
