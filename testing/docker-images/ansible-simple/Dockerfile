# Simple Ansible container - just the software, no complex setup
FROM ubuntu:22.04

# Install basic system dependencies
RUN apt-get update && \
    apt-get install -y \
        python3 \
        python3-pip \
        curl \
        git \
        openssh-client && \
    apt-get clean

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

# Create working directory
WORKDIR /workspace

# Default command
CMD ["/bin/bash"]