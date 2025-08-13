FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && \
    apt-get install -y \
    curl \
    git \
    docker.io \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*

# Install uv for Python package management
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Install Python tools with uv
RUN uv tool install ansible && \
    uv tool install molecule && \
    uv tool install molecule-plugins[docker] && \
    uv tool install ansible-lint && \
    uv tool install yamllint
ENV PATH="/root/.local/share/uv/tools/ansible/bin:/root/.local/share/uv/tools/molecule/bin:/root/.local/share/uv/tools/molecule-plugins/bin:/root/.local/share/uv/tools/ansible-lint/bin:/root/.local/share/uv/tools/yamllint/bin:$PATH"

# Set up Ansible configuration
RUN mkdir -p /etc/ansible && \
    echo "[defaults]" > /etc/ansible/ansible.cfg && \
    echo "host_key_checking = False" >> /etc/ansible/ansible.cfg && \
    echo "stdout_callback = yaml" >> /etc/ansible/ansible.cfg && \
    echo "inventory = ./inventory.yml" >> /etc/ansible/ansible.cfg

# Create workspace
RUN mkdir -p /workspace
WORKDIR /workspace

# Copy the role and testing files (will be mounted in real usage)
CMD ["/bin/bash"]