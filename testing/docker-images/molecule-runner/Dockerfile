# Ephemeral Molecule Runner for Cross-Platform Testing
# Runs molecule commands to provision containers via Docker socket
FROM python:3.12-slim

# Install system dependencies
RUN apt-get update && \
    apt-get install -y \
        curl \
        git \
        openssh-client \
        docker.io \
        build-essential && \
    rm -rf /var/lib/apt/lists/*

# Install uv for fast Python package management
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Install latest Python testing tools with molecule-plugins (preferred for 2024-2025)
RUN uv tool install --with molecule-plugins --with requests --with docker --with passlib molecule && \
    uv tool install ansible-lint

# Add tools to PATH - use molecule's bundled ansible
ENV PATH="/root/.local/share/uv/tools/molecule/bin:/root/.local/share/uv/tools/ansible-lint/bin:$PATH"

# Install required Ansible collections
RUN ansible-galaxy collection install community.docker && \
    ansible-galaxy collection install ansible.posix && \
    ansible-galaxy collection install community.crypto

# Create workspace
WORKDIR /workspace

# Default command
CMD ["molecule", "--help"]