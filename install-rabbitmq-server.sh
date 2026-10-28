#!/bin/bash

# Adapted from https://www.rabbitmq.com/docs/install-debian

sudo apt-get install curl gnupg apt-transport-https -y

# Team RabbitMQ's signing key
curl -1sLf "https://keys.openpgp.org/vks/v1/by-fingerprint/0A9AF2115F4687BD29803A206B73A36E6026DFCA" | sudo gpg --dearmor | sudo tee /usr/share/keyrings/com.rabbitmq.team.gpg > /dev/null

# Add apt repositories maintained by Team RabbitMQ.
sudo tee /etc/apt/sources.list.d/rabbitmq.list <<EOF
## Modern Erlang/OTP releases
deb [arch=amd64 signed-by=/usr/share/keyrings/com.rabbitmq.team.gpg] https://deb1.rabbitmq.com/rabbitmq-erlang/ubuntu/noble noble main
deb [arch=amd64 signed-by=/usr/share/keyrings/com.rabbitmq.team.gpg] https://deb2.rabbitmq.com/rabbitmq-erlang/ubuntu/noble noble main

## Latest RabbitMQ releases
deb [arch=amd64 signed-by=/usr/share/keyrings/com.rabbitmq.team.gpg] https://deb1.rabbitmq.com/rabbitmq-server/ubuntu/noble noble main
deb [arch=amd64 signed-by=/usr/share/keyrings/com.rabbitmq.team.gpg] https://deb2.rabbitmq.com/rabbitmq-server/ubuntu/noble noble main
EOF

# Update package indices.
sudo apt-get update -y

# Install Erlang packages
sudo apt-get install -y erlang-base \
                        erlang-asn1 erlang-crypto erlang-eldap erlang-ftp erlang-inets \
                        erlang-mnesia erlang-os-mon erlang-parsetools erlang-public-key \
                        erlang-runtime-tools erlang-snmp erlang-ssl \
                        erlang-syntax-tools erlang-tftp erlang-tools erlang-xmerl

# Install rabbitmq-server and its dependencies
sudo apt-get install rabbitmq-server -y --fix-missing

# Create the config file for limits.
sudo systemctl stop rabbitmq-server
SERVICED=/etc/systemd/system/rabbitmq-server.service.d
sudo rm -f $SERVICED/limits.conf
sudo mkdir -p $SERVICED
rm -f /tmp/limits.conf
cat > /tmp/limits.conf <<EOF
[Service]
LimitNOFILE=64000
EOF
sudo mv /tmp/limits.conf $SERVICED/
sudo chown root:root $SERVICED/limits.conf
sudo systemctl daemon-reload
sudo systemctl start rabbitmq-server
