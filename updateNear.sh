#!/bin/bash

source ~/.profile
network=$NEAR_NETWORK
msg="msg"
USER=$(whoami)
nodekey=$(cat /home/$USER/near-ci/localnet/localnet-node0/validator_key.json | jq .public_key | tr -d '"')



#check node version diff
diff <(curl -s https://rpc.$network.near.org/status | jq .version) <(curl -s http://127.0.0.1:3030/status | jq .version)

#start update if local version is different
if [ $? -eq 0 ]; then
    echo "start update";
    sudo apt-get update
    sudo apt-get --assume-yes upgrade
    sudo apt-get --assume-yes dist-upgrade
    sudo curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source ~/.profile
    rustup component add clippy-preview
    rustup default nightly
    [ -d /home/$USER/nearcore.new ] && sudo rm -rf /home/$USER/nearcore.new
    version=$(curl -s https://rpc.$network.near.org/status | jq .version.version)
    strippedversion=$(echo "$version" | awk -F "\"" '{print $2}' | awk -F "-" '{print $1}')
    mkdir /home/$USER/nearcore.new
    git clone --branch $strippedversion https://github.com/nearprotocol/nearcore.git /home/$USER/nearcore.new
    cd /home/$USER/nearcore.new
    sudo make release

        #if make was succesfully test a new node
        if [ $? -eq 0 ]; then
        echo "new build was successfull, run test nodes"

        /home/$USER/nearcore.new/target/release/neard --home /home/$USER/near-ci/localnet/localnet-node0 run &> /dev/null &
        /home/$USER/nearcore.new/target/release/neard --home /home/$USER/near-ci/localnet/localnet-node1 run --boot-nodes $nodekey@127.0.0.1:24550 &> /dev/null &
        /home/$USER/nearcore.new/target/release/neard --home /home/$USER/near-ci/localnet/localnet-node2 run --boot-nodes $nodekey@127.0.0.1:24550 &> /dev/null &
        /home/$USER/nearcore.new/target/release/neard --home /home/$USER/near-ci/localnet/localnet-node3 run --boot-nodes $nodekey@127.0.0.1:24550 &> /dev/null &
        sleep 10
        echo "run test"        
        for count in {0..3}
        do
            diff <(curl -s https://rpc."$network".near.org/status | jq .version) <(curl -s http://127.0.0.1:307"$count"/status | jq .version)
            if [ $? -eq 0 ]
            then
                echo "Node $count Operational"
            else
                msg="Node upgade failed - Test Failed: Node $count  Not Operational"
                echo $msg
                ./twilio.sh "$msg"

                #Remove testing data
                rm -rf /home/$USER/near-ci/localnet/localnet-node0/data
                rm -rf /home/$USER/near-ci/localnet/localnet-node1/data
                rm -rf /home/$USER/near-ci/localnet/localnet-node2/data
                rm -rf /home/$USER/near-ci/localnet/localnet-node3/data
                exit 1
            fi
        done
        echo 'Testing localnet complete'

        #Remove testing data
        rm -rf /home/$USER/near-ci/localnet/localnet-node0/data
        rm -rf /home/$USER/near-ci/localnet/localnet-node1/data
        rm -rf /home/$USER/near-ci/localnet/localnet-node2/data
        rm -rf /home/$USER/near-ci/localnet/localnet-node3/data
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


