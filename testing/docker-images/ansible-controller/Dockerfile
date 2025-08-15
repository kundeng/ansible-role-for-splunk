# Webtop + XPipe + Ansible Controller for Splunk Lab Environment
# Provides web-based desktop with file management across all lab nodes
FROM lscr.io/linuxserver/webtop:ubuntu-xfce

# Environment variables for webtop
ENV PUID=1000 \
    PGID=1000 \
    TZ=America/New_York \
    SUBFOLDER=/ \
    KEYBOARD=en-us-qwerty \
    TITLE="Splunk Lab Controller"

# Switch to root for installations
USER root

# Install system dependencies for Ansible + SSH + Docker client
RUN apt-get update && \
    apt-get install -y \
    curl \
    wget \
    git \
    vim \
    nano \
    htop \
    tree \
    jq \
    yq \
    unzip \
    docker.io \
    openssh-client \
    openssh-server \
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Install uv for Python package management
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Install Ansible ecosystem with uv
RUN uv tool install ansible && \
    uv tool install molecule && \
    uv tool install molecule-plugins[docker] && \
    uv tool install ansible-lint && \
    uv tool install yamllint
ENV PATH="/root/.local/share/uv/tools/ansible/bin:/root/.local/share/uv/tools/molecule/bin:/root/.local/share/uv/tools/molecule-plugins/bin:/root/.local/share/uv/tools/ansible-lint/bin:/root/.local/share/uv/tools/yamllint/bin:$PATH"

# Install XPipe for SSH connection management and file access
RUN wget -O /tmp/xpipe.deb https://github.com/xpipe-io/xpipe/releases/latest/download/xpipe-installer-linux-x86_64.deb && \
    dpkg -i /tmp/xpipe.deb || apt-get install -f -y && \
    rm /tmp/xpipe.deb

# Set up Ansible configuration
RUN mkdir -p /etc/ansible && \
    echo "[defaults]" > /etc/ansible/ansible.cfg && \
    echo "host_key_checking = False" >> /etc/ansible/ansible.cfg && \
    echo "stdout_callback = yaml" >> /etc/ansible/ansible.cfg && \
    echo "inventory = /workspace/testing/molecule/default/inventory/" >> /etc/ansible/ansible.cfg && \
    echo "roles_path = /workspace/roles" >> /etc/ansible/ansible.cfg && \
    echo "interpreter_python = auto_silent" >> /etc/ansible/ansible.cfg

# Create workspace directories
RUN mkdir -p /workspace /config/Desktop /config/.config

# Create desktop shortcuts for common tasks
RUN echo '[Desktop Entry]' > /config/Desktop/XPipe.desktop && \
    echo 'Version=1.0' >> /config/Desktop/XPipe.desktop && \
    echo 'Type=Application' >> /config/Desktop/XPipe.desktop && \
    echo 'Name=XPipe SSH Manager' >> /config/Desktop/XPipe.desktop && \
    echo 'Comment=Manage SSH connections to Splunk lab nodes' >> /config/Desktop/XPipe.desktop && \
    echo 'Exec=xpipe open' >> /config/Desktop/XPipe.desktop && \
    echo 'Icon=utilities-terminal' >> /config/Desktop/XPipe.desktop && \
    echo 'Terminal=false' >> /config/Desktop/XPipe.desktop && \
    chmod +x /config/Desktop/XPipe.desktop

RUN echo '[Desktop Entry]' > /config/Desktop/Terminal.desktop && \
    echo 'Version=1.0' >> /config/Desktop/Terminal.desktop && \
    echo 'Type=Application' >> /config/Desktop/Terminal.desktop && \
    echo 'Name=Ansible Terminal' >> /config/Desktop/Terminal.desktop && \
    echo 'Comment=Terminal for Ansible operations' >> /config/Desktop/Terminal.desktop && \
    echo 'Exec=xfce4-terminal --working-directory=/workspace' >> /config/Desktop/Terminal.desktop && \
    echo 'Icon=utilities-terminal' >> /config/Desktop/Terminal.desktop && \
    echo 'Terminal=false' >> /config/Desktop/Terminal.desktop && \
    chmod +x /config/Desktop/Terminal.desktop

# Create startup script for SSH key setup and XPipe configuration
RUN echo '#!/bin/bash' > /etc/cont-init.d/99-ansible-setup && \
    echo 'echo "Setting up SSH keys for lab access..."' >> /etc/cont-init.d/99-ansible-setup && \
    echo 'mkdir -p /config/.ssh' >> /etc/cont-init.d/99-ansible-setup && \
    echo 'if [ -f /shared/ssh_keys/id_rsa ]; then' >> /etc/cont-init.d/99-ansible-setup && \
    echo '  cp /shared/ssh_keys/id_rsa /config/.ssh/' >> /etc/cont-init.d/99-ansible-setup && \
    echo '  cp /shared/ssh_keys/id_rsa.pub /config/.ssh/' >> /etc/cont-init.d/99-ansible-setup && \
    echo '  chmod 600 /config/.ssh/id_rsa' >> /etc/cont-init.d/99-ansible-setup && \
    echo '  chmod 644 /config/.ssh/id_rsa.pub' >> /etc/cont-init.d/99-ansible-setup && \
    echo '  chown abc:abc /config/.ssh/id_rsa*' >> /etc/cont-init.d/99-ansible-setup && \
    echo 'fi' >> /etc/cont-init.d/99-ansible-setup && \
    echo 'echo "SSH keys configured for lab access"' >> /etc/cont-init.d/99-ansible-setup && \
    chmod +x /etc/cont-init.d/99-ansible-setup

# Switch back to abc user (webtop default)
USER abc
WORKDIR /workspace

# Expose webtop ports
EXPOSE 3000 3001