# Simple Web Terminal + Ansible Controller for Splunk Lab
# Based on web terminal patterns, not full webtop
FROM ubuntu:22.04

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        curl \
        git \
        openssh-client \
        openssh-server \
        sudo \
        nodejs \
        npm \
        python3-venv \
        build-essential \
        make && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install wetty for web terminal
RUN npm install -g wetty

# Create ansible user
RUN useradd -m -s /bin/bash ansible && \
    echo 'ansible ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ansible && \
    chmod 0440 /etc/sudoers.d/ansible

# Install Ansible in venv for the ansible user
RUN python3 -m venv /opt/ansible-venv && \
    /opt/ansible-venv/bin/pip install --upgrade pip && \
    /opt/ansible-venv/bin/pip install \
        ansible \
        requests \
        docker \
        passlib

# Install Ansible collections
RUN /opt/ansible-venv/bin/ansible-galaxy collection install community.docker && \
    /opt/ansible-venv/bin/ansible-galaxy collection install ansible.posix && \
    /opt/ansible-venv/bin/ansible-galaxy collection install community.crypto

# Add ansible venv to PATH system-wide and for ansible user
RUN echo 'export PATH="/opt/ansible-venv/bin:$PATH"' >> /etc/bash.bashrc && \
    echo 'export PATH="/opt/ansible-venv/bin:$PATH"' >> /home/ansible/.bashrc && \
    echo 'export PATH="/opt/ansible-venv/bin:$PATH"' >> /home/ansible/.profile

# Setup SSH for ansible user
RUN mkdir -p /home/ansible/.ssh && \
    chmod 700 /home/ansible/.ssh && \
    chown -R ansible:ansible /home/ansible/.ssh

# Create workspace directory
RUN mkdir -p /workspace && \
    chown ansible:ansible /workspace

# Setup SSH server
RUN mkdir /var/run/sshd && \
    ssh-keygen -A

# Startup script
COPY <<EOF /startup.sh
#!/bin/bash
set -e

# Set PATH to include ansible venv
export PATH="/opt/ansible-venv/bin:$PATH"

# Start SSH daemon in background
/usr/sbin/sshd -D &

# Start wetty with proper environment
sudo -u ansible bash -c '
    export PATH="/opt/ansible-venv/bin:$PATH"
    export TERM=xterm-256color
    cd /workspace
    /usr/local/bin/wetty \
        --port 3000 \
        --host 0.0.0.0 \
        --command "/bin/bash --login" \
        --base /wetty/
'
EOF

RUN chmod +x /startup.sh

EXPOSE 3000 22
WORKDIR /workspace

CMD ["/startup.sh"]