#!/bin/bash

# Usage: ./add_sftp_user.sh <container_id> <username> <password>

CONTAINER_ID=$1
USERNAME=$2
PASSWORD=$3

# Execute commands inside the running container
docker exec $CONTAINER_ID bash -c "
  useradd -m -d /home/$USERNAME -s /bin/bash $USERNAME && \
  echo \"$USERNAME:$PASSWORD\" | chpasswd && \
  usermod -aG sftp_users $USERNAME && \
  mkdir -p /var/sftp/uploads/$USERNAME && \
  chown $USERNAME:sftp_users /var/sftp/uploads/$USERNAME
"

