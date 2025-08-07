FROM xpipe/xpipe-webtop:latest
ENV container=docker

# XPipe is already installed in this image

# Install additional tools if needed (adjust based on base image)
RUN apt-get update && \
    apt-get install -y python3-pip git curl && \
    pip3 install --upgrade pip && \
    pip3 install ansible molecule[docker] docker-py ansible-lint yamllint && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create directories for Ansible work
RUN mkdir -p /ansible-workspace

# Set up Ansible configuration
RUN mkdir -p /etc/ansible && \
    echo "[defaults]" > /etc/ansible/ansible.cfg && \
    echo "host_key_checking = False" >> /etc/ansible/ansible.cfg && \
    echo "stdout_callback = yaml" >> /etc/ansible/ansible.cfg && \
    echo "inventory = ./inventory" >> /etc/ansible/ansible.cfg

# XPipe already provides:
# - Connection management for Docker containers
# - Web-based desktop environment  
# - Terminal access and file management
# This image adds Ansible/Molecule for infrastructure testing

WORKDIR /ansible-workspace