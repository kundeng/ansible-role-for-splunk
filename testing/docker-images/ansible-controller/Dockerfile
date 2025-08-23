# Webtop + Ansible Controller for Splunk Lab Environment  
# Provides web-based desktop with Ansible tools pre-installed
FROM lscr.io/linuxserver/webtop:ubuntu-xfce

# Switch to root for installations
USER root

# Install system dependencies and Python tools
RUN apt-get update && \
    apt-get install -y \
        curl wget git vim nano htop tree jq yq unzip \
        openssh-client python3 python3-pip python3-venv \
        build-essential && \
    rm -rf /var/lib/apt/lists/*

# Install uv to system location (LinuxServer.io containers use /config as home)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    mv /config/.local/bin/uv /usr/local/bin/

# Install Python tools using uv and fix permissions
RUN uv tool install ansible && \
    uv tool install molecule && \
    uv tool install --with molecule-docker molecule && \
    uv tool install ansible-lint && \
    chown -R abc:abc /config/.local && \
    mkdir -p /config/.ansible && \
    chown -R abc:abc /config/.ansible

# Add uv tools to PATH for all users via profile scripts
RUN echo 'export PATH="/config/.local/share/uv/tools/ansible/bin:/config/.local/share/uv/tools/molecule/bin:/config/.local/share/uv/tools/ansible-lint/bin:/config/.local/bin:/usr/local/bin:$PATH"' >> /etc/profile && \
    echo 'export PATH="/config/.local/share/uv/tools/ansible/bin:/config/.local/share/uv/tools/molecule/bin:/config/.local/share/uv/tools/ansible-lint/bin:/config/.local/bin:/usr/local/bin:$PATH"' >> /etc/bash.bashrc && \
    echo 'export PATH="/config/.local/share/uv/tools/ansible/bin:/config/.local/share/uv/tools/molecule/bin:/config/.local/share/uv/tools/ansible-lint/bin:/config/.local/bin:/usr/local/bin:$PATH"' >> /config/.profile && \
    echo 'export PATH="/config/.local/share/uv/tools/ansible/bin:/config/.local/share/uv/tools/molecule/bin:/config/.local/share/uv/tools/ansible-lint/bin:/config/.local/bin:/usr/local/bin:$PATH"' >> /config/.bashrc

# Also set ENV for direct docker exec usage  
ENV PATH="/config/.local/share/uv/tools/ansible/bin:/config/.local/share/uv/tools/molecule/bin:/config/.local/share/uv/tools/ansible-lint/bin:/config/.local/bin:/usr/local/bin:$PATH"

# Create minimal Ansible configuration (will be overridden by volume mounts)
RUN mkdir -p /etc/ansible && \
    echo "[defaults]" > /etc/ansible/ansible.cfg && \
    echo "host_key_checking = False" >> /etc/ansible/ansible.cfg

# Create workspace and ensure proper permissions
RUN mkdir -p /workspace && \
    chown -R abc:abc /workspace

# Working directory (don't set USER as LinuxServer.io handles this)
WORKDIR /workspace

# Expose ports
EXPOSE 3000 3001