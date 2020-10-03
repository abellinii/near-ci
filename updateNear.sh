##!/bin/bash

source ~/.profile
ip=$(curl ifconfig.me)
network=$NEAR_NETWORK
msg="msg"
USER=$(whoami)

#check node version diff
diff <(curl -s https://rpc.$network.near.org/status | jq .version) <(curl -s http://127.0.0.1:3030/status | jq .version)

#start update if local version is different
if [ $? -ne 0 ]; then
    echo "start update";
    rustup default nightly
    rm -rf /home/$USER/nearcore.new
    version=$(curl -s https://rpc.$network.near.org/status | jq .version.version)
    strippedversion=$(echo "$version" | awk -F "\"" '{print $2}' | awk -F "-" '{print $1}')
    git clone --branch $strippedversion https://github.com/nearprotocol/nearcore.git /home/$USER/nearcore.new
    cd /home/$USER/nearcore.new
    make release

        #if make was succesfully test a new node
        if [ $? -eq 0 ]; then
        echo "new build was successfull, run test nodes"

        /home/$USER/nearcore.new/target/release/neard --home /home/$USER/near-update/localnet/node0 run
        /home/$USER/nearcore.new/target/release/neard --home /home/$USER/near-update/localnet/node1 run --boot-nodes ed25519:7PGseFbWxvYVgZ89K1uTJKYoKetWs7BJtbyXDzfbAcqX@127.0.0.1:24550
        /home/$USER/nearcore.new/target/release/neard --home /home/$USER/near-update/localnet/node2 run --boot-nodes ed25519:7PGseFbWxvYVgZ89K1uTJKYoKetWs7BJtbyXDzfbAcqX@127.0.0.1:24550
        /home/$USER/nearcore.new/target/release/neard --home /home/$USER/near-update/localnet/node3 run --boot-nodes ed25519:7PGseFbWxvYVgZ89K1uTJKYoKetWs7BJtbyXDzfbAcqX@127.0.0.1:24550
        sleep 10
        echo "run test"        
        for count in {0..3}
        do
            diff <(curl -s https://rpc."$network".near.org/status | jq .version) <(curl -s http://127.0.0.1:305"$count"/status | jq .version)
            if [ $? -eq 0 ]
            then
                echo "Node $count Operational"
            else
                msg="Node upgade failed - Test Failed: Node $count  Not Operational"
                echo $msg
                ./twilio.sh "$msg"

                #Remove testing data
                rm -rf /home/$USER/near-update/localnet/node0/data
                rm -rf /home/$USER/near-update/localnet/node1/data
                rm -rf /home/$USER/near-update/localnet/node2/data
                rm -rf /home/$USER/near-update/localnet/node3/data
                exit 1
            fi
        done
        echo 'Testing localnet complete'

        #Remove testing data
        rm -rf /home/$USER/near-update/localnet/node0/data
        rm -rf /home/$USER/near-update/localnet/node1/data
        rm -rf /home/$USER/near-update/localnet/node2/data
        rm -rf /home/$USER/near-update/localnet/node3/data
        pkill neard

        echo 'test is succesfull, deploy a new node'
        mv /home/$USER/nearcore /home/$USER/nearcore.bak/nearcore-"`date +"%Y-%m-%d(%H:%M)"`"
        mv /home/$USER/nearcore.new /home/$USER/nearcore
        cd /home/$USER/
        nearcore/target/release/neard run 2>&1|tee -a validator.log

        #Configure msg text
        msg="Validator update with new $network $versionStripped"

        #Send msg to phone about the status of the update 
        ./twilio.sh "$msg"

        echo "done"

        fi
fi