#!/bin/bash

# Start SSHD in the background
/usr/sbin/sshd

# Function to create a new user
create_user() {
  username=$1
  password=$2

  if id "$username" &>/dev/null; then
    echo "User $username already exists."
  else
    useradd -m -d /home/$username -s /bin/bash $username
    echo "$username:$password" | chpasswd
    usermod -aG sftp_users $username
    mkdir -p /var/sftp/uploads/$username
    chown $username:sftp_users /var/sftp/uploads/$username
  fi
}

# Create the sftp_users group if it doesn't exist
if ! getent group sftp_users > /dev/null; then
  groupadd sftp_users
fi

# Check for SFTP_USERS environment variable
if [ -n "$SFTP_USERS" ]; then
  # SFTP_USERS format: "user1:pass1,user2:pass2"
  IFS=',' read -ra USERS <<< "$SFTP_USERS"
  for user in "${USERS[@]}"; do
    IFS=':' read -ra USER_CRED <<< "$user"
    create_user "${USER_CRED[0]}" "${USER_CRED[1]}"
    
    # Set the home directory for the user
    usermod -d /var/sftp/uploads/${USER_CRED[0]} ${USER_CRED[0]}

  done
fi

# Keep the container running
tail -f /dev/null

