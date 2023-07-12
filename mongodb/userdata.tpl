#!/bin/bash

sudo apt-get update
curl -fsSL https://pgp.mongodb.com/server-6.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-6.0.gpg --dearmor
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
sudo apt-get update
sudo apt install -y python3 python3-pip
sudo pip3 install awscli
echo 'export PATH=$PATH:$HOME/.local/bin' >> ~/.bashrc
source ~/.bashrc
sudo apt-get install -y mongodb-org
sudo hostnamectl set-hostname ${bind_ip}
sudo systemctl enable mongod
sudo systemctl start mongod


if [ "${is_primary}" = true ]; then
  sudo sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/g' /etc/mongod.conf
  sudo sed -i '/^security:/,/^\S/ { /^security:/! { /^\S/! d } }' /etc/mongod.conf
  
  sudo tee -a /etc/mongod.conf > /dev/null <<EOF
replication:
  replSetName: "${replica_set}"
EOF

  sleep 10
  export primary_ip=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

  aws ec2 describe-instances --region us-east-1 --filters "Name=tag:Name,Values=mongodb-secondary*" --query "Reservations[].Instances[].InstanceId" --output text > /tmp/instance_ids.txt &
  wait $!

  export instance_ids=$(cat /tmp/instance_ids.txt)

  aws ec2 describe-instances --region us-east-1 --instance-ids $instance_ids --query "Reservations[].Instances[].PrivateIpAddress" --output text > /tmp/private_ips.txt &
  wait $!


  mongosh --eval "rs.initiate(
    {
      _id: \"${replica_set}\",
      members: [
        { _id: 0, host: \"$primary_ip:27017\" }
      ]
    }
  )"


  while IFS= read -r ip; do
    echo "$ip"
    mongosh --eval "rs.add('$ip:27017')"
  done < /tmp/private_ips.txt

  mongosh --eval "rs.status()"


else
  sudo sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/g' /etc/mongod.conf

  echo "replication:
  replSetName: \"${replica_set}\"
" | sudo tee -a /etc/mongod.conf
  sudo systemctl start mongod
fi



# Configure MongoDB authentication
mongosh --eval "db.getSiblingDB('admin').createUser({user: '${mongo_username}', pwd: '${mongo_password}', roles: ['root']})"
mongosh --eval "db.getSiblingDB('${mongo_database}').createUser({user: '${mongo_username}', pwd: '${mongo_password}', roles: ['readWrite']})"


mongosh --eval "db.getSiblingDB('admin').createUser({user: 'nw_attendance', pwd: 'pass', roles: ['root']})"
mongosh --eval "db.getSiblingDB('nw_attendance').createUser({user: 'nw_attendance', pwd: 'pass123', roles: ['readWrite']})"