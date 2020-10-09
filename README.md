# near-ci

## Overview

[NEAR Protocol](https://near.org/) is a decentralized application platform that is secure enough to manage high value assets like money or identity and performant enough to make them useful for everyday people, putting the power of the Open Web in their hands.

This is a simple script that can be installed under a cron job and utilized to update, test and build a new release automatically for the NEAR protocol. 

** This assumes you already have a node(validator) running on your machine. 


## Dependencies

[jq](https://stedolan.github.io/jq/) for parsing json. jq is a lightweight and flexible command-line JSON processor.

[Twilio](https://www.twilio.com/) is a programmable messaging service. This will alert the node owner when a release has been deployed and the node was upgraded either successfully or unsuccessfully. You will need to sign up for an account

## Dependencies(if machine has never compiled nearcore previously)

```sudo apt update```

```sudo apt install -y python3 git curl libclang-dev build-essential llvm runc gcc g++ unattended-upgrades make clang pkg-config libssl-dev libudev-dev g++ g++-multilib lib32stdc++6-7-dbg libx32stdc++6-7-dbg cmake```

```curl https://sh.rustup.rs -sSf | sh -s -- -y```

```source $HOME/.cargo/env```

```rustup default nightly```



## Installation

### Set environment variables for Twilio and network you are using

Add the following env vars to ~/.profile

```
export NEAR_NETWORK=<network>
export TWILIO_MESSAGING_SERVICE_SID=<your_twilio_messaging_service_sid>
export TWILIO_ACCOUNT_SID=<your_twilio_account_sid>
export TWILIO_AUTH_TOKEN=<your_twilio_auth_token>
export TWILIO_NUMBER_TO_SEND=<number you want the message sent to> 
export TWILIO_NUMBER=<Number in your twilio account>
```
**Install jq**

```sudo apt-get install jq```



**Install script to home directory**

```git clone https://github.com/abellinii/near-ci.git```

**Set cron job to run the script every hour**

```echo "@daily        script --return --quiet --append --command \"cd /home/$USER/near-ci && ./updateNear.sh 2>&1\" /home/$USER/near-ci/update.log" | crontab -```

```sudo chmod +x /home/$USER/near-ci/updateNear.sh```

```sudo chmod +x /home/$USER/near-ci/twilio.sh```

**Add the new path to profile**

```nano ~/.profile```

Add to file

```export PATH="$HOME/near-ci:$HOME/.cargo:$PATH"```

```source ~/.profile```




