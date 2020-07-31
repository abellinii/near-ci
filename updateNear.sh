#!/bin/bash


#Bash script to place in a cron job on local server to check for updates of the lastest near version
#script should be run by a cron job hourly to detect the newest release in a timely fashion

ip=$(curl ifconfig.me)
network=$NEAR_NETWORK
msg="msg"
diff <(curl -s https://rpc."$network".near.org/status | jq .version) <(curl -s http://127.0.0.1:3030/status | jq .version)

if [ $? -ne 0 ]; then
    echo "start update";
    version=$(curl -s http://127.0.0.1:3030/status | jq .version)
    strippedversion=$("$version" | cut -f 4  -d\"| cut  -d "-" -f 1)
    rm -rf /home/$USER/nearcore.bak
    mv /home/$USER/nearcore /home/$USER/nearcore.bak
    git clone --branch $strippedversion https://github.com/nearprotocol/nearcore.git
    cd /home/$USER/nearcore
    make release
    nearup stop


    #Test new release
    nearup localnet --nodocker --binary-path /home/$USER/nearcore/target/debug
    echo "Testing localnet"

    for count in {0..4}
    diff <(curl -s https://rpc."$network".near.org/status | jq .version) <(curl -s http://127.0.0.1:303"$count"/status | jq .version)
    if [ $? -ne 0 ]
    then
        echo "Node $count Operational"
    else    
        msg="Node Upgade failed - Test Failed: Node $count  Not Operational"
        echo $msg
        twilio.sh $msg
        nearup stop
        exit 1
    fi
    done

    echo "Testing localnet complete"
    nearup stop
    nearup betanet --binary-path /home/$USER/nearcore/target/release/

    

    #Configure msg text
    msg="Validator update with new $network $versionStripped"

    #Send msg to phone about the status of the update 
    twilio.sh "$msg"

    echo "done"