FROM ubuntu:20.04

# Update package lists and install necessary packages
RUN apt-get update && apt-get install -y openssh-server

# Create SSH directory and necessary files
RUN mkdir /var/run/sshd

# SSH login fix (Keeping Session Alive)
RUN sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

# Environment variables
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# Create the SFTP root directory
RUN mkdir -p /var/sftp/uploads \
    && chown root:root /var/sftp \
    && chmod 755 /var/sftp

# Create the sftp_users group
RUN groupadd sftp_users

# Update SSHD config to allow SFTP for specific users
RUN echo '\n\
Match Group sftp_users \n\
ForceCommand internal-sftp \n\
PasswordAuthentication yes \n\
ChrootDirectory /var/sftp/uploads n\
PermitTunnel no \n\
AllowAgentForwarding no \n\
AllowTcpForwarding no \n\
X11Forwarding no' >> /etc/ssh/sshd_config

# Create an entrypoint script for adding users
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose SSH port
EXPOSE 22

# Start SSH
CMD ["/entrypoint.sh"]

