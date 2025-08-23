# Simple Ansible Controller based on Ubuntu with SSH and web terminal
FROM ubuntu:22.04

# Install system dependencies
RUN apt-get update && \
    apt-get install -y \
        systemd \
        openssh-server \
        openssh-client \
        sudo \
        python3 \
        python3-pip \
        curl \
        git \
        passwd \
        nodejs \
        npm && \
    apt-get clean

# Clean up systemd for container use
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do \
      [ "$i" = systemd-tmpfiles-setup.service ] || rm -f "$i"; done) && \
    rm -f /lib/systemd/system/multi-user.target.wants/* \
          /etc/systemd/system/*.wants/* \
          /lib/systemd/system/local-fs.target.wants/* \
          /lib/systemd/system/sockets.target.wants/*udev* \
          /lib/systemd/system/sockets.target.wants/*initctl* \
          /lib/systemd/system/basic.target.wants/*

# Configure SSH
RUN mkdir /var/run/sshd && \
    ssh-keygen -A && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
    sed -i 's/^UsePAM no$/#UsePAM no/' /etc/ssh/sshd_config

# Install uv for fast Python package management
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Install Ansible and related tools
RUN uv tool install --with requests --with docker --with passlib ansible && \
    uv tool install molecule && \
    uv tool install --with molecule-docker molecule && \
    uv tool install ansible-lint

# Add tools to PATH
ENV PATH="/root/.local/share/uv/tools/ansible/bin:/root/.local/share/uv/tools/molecule/bin:/root/.local/share/uv/tools/ansible-lint/bin:$PATH"

# Install Ansible collections
RUN ansible-galaxy collection install community.docker && \
    ansible-galaxy collection install ansible.posix

# Create ansible user with sudo privileges
RUN useradd -m -s /bin/bash ansible && \
    echo 'ansible:ansible' | chpasswd && \
    echo 'ansible ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ansible && \
    chmod 0440 /etc/sudoers.d/ansible

# Install web terminal (lightweight web-based terminal access)
RUN npm install -g wetty

# Create working directories
RUN mkdir -p /workspace /shared

# Enable systemd services
RUN systemctl enable ssh && \
    systemctl enable systemd-user-sessions

# Expose ports for SSH and web terminal
EXPOSE 22 3000

# Start systemd
CMD ["/usr/sbin/init"]