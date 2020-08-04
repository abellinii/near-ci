# near-ci for Docker

### Notes

This script is used in conjunction with [masknetgoal634's](https://github.com/masknetgoal634) implementation of Github actions to build the new docker image [here](https://github.com/masknetgoal634/nearcore-deploy). This must first be installed and used for this script to work. It is also for the implentation of [near-terraform](https://github.com/abellinii/near-terraform) 

## Overview

[NEAR Protocol](https://near.org/) is a decentralized application platform that is secure enough to manage high value assets like money or identity and performant enough to make them useful for everyday people, putting the power of the Open Web in their hands.

This is a simple script that can be installed under a cron job and utilized to update, test and build a new release automatically for the NEAR protocol. 

** This assumes you already have a node(validator) running on your machine. 


## Dependencies

[jq](https://stedolan.github.io/jq/) for parsing json. jq is a lightweight and flexible command-line JSON processor.

[Nearup](https://github.com/near/nearup) is NEAR's public scripts to launch near betanet and testnet node. This is installed on provisioning.

[Twilio](https://www.twilio.com/) is a programmable messaging service. This will alert the node owner when a release has been deployed and the node was upgraded either successfully or unsuccessfully. You will need to sign up for an account

## Dependencies(if machine has never compiled nearcore previously)

```sudo apt update```

```sudo apt install -y git binutils-dev libcurl4-openssl-dev zlib1g-dev libdw-dev libiberty-dev cmake gcc g++ python docker.io protobuf-compiler libssl-dev pkg-config clang llvm```

```curl https://sh.rustup.rs -sSf | sh -s -- -y```

```source $HOME/.cargo/env```



## Installation

### Set environment variables for Twilio and network you are using

Add the following env vars to ~/.profile

```export NEAR_NETWORK=<network>```
```
export TWILIO_MESSAGING_SERVICE_SID=<your_twilio_messaging_service_sid>
export TWILIO_ACCOUNT_SID=<your_twilio_account_sid>
export TWILIO_AUTH_TOKEN=<your_twilio_auth_token>
export TWILIO_NUMBER_TO_SEND=<number you want the message sent to> 
export TWILIO_NUMBER=<Number in your twilio account>
export NEARCORE_DOCKER_IMAGE=<your docker image>
```
**Install jq**

```sudo apt-get install jq```

**Install nearup**

```sudo apt-get --assume-yes install python3 git curl```

```curl --proto "=https" --tlsv1.2 -sSfL https://up.near.dev | python3```

```source $HOME/.nearup/env```


**Install script to home directory**

```git clone https://github.com/abellinii/near-ci.git```

**Set cron job to run the script every hour**

```echo "@hourly        script --return --quiet --append --command \"cd /home/$USER/near-ci && ./updateNear.sh 2>&1\" /home/$USER/near-ci/update.log" | crontab -```

```sudo chmod +x /home/$USER/near-ci/updateNear.sh```

```sudo chmod +x /home/$USER/near-ci/twilio.sh```

**Add the new path to profile**

```nano ~/.profile```

Add to file

```export PATH="$HOME/near-ci:$PATH"```

```source ~/.profile```




