# Splunk Testing Framework with Docker + Molecule
# Usage: just <command>

# Variables - using just's built-in functions and proper directory handling
testing_dir := justfile_directory() / "testing"
docker_images_dir := testing_dir / "docker-images" 
molecule_scenario_dir := testing_dir / "molecule" / "default"

# Default recipe - show available commands
default:
    @just --list

# Setup and installation tasks
install-deps:
    @echo "🔧 Installing development dependencies..."
    @echo "Installing uv (Python package manager)..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    @echo "Installing Python dependencies with uv..."
    uv sync --no-install-project
    @echo "Installing Ansible collections..."
    uv run ansible-galaxy collection install community.docker
    @echo "✅ All dependencies installed!"

install-act:
    @echo "🎭 Installing act (GitHub Actions local runner)..."
    curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
    @echo "✅ act installed! Test with: just test-local"

check-deps:
    @echo "🔍 Checking dependencies..."
    @command -v docker >/dev/null 2>&1 || (echo "❌ Docker not found" && exit 1)
    @command -v uv >/dev/null 2>&1 || (echo "⚠️  uv not found - run 'just install-deps'" && exit 1)
    @command -v molecule >/dev/null 2>&1 || (echo "⚠️  Molecule not found - run 'just install-deps'" && exit 1)
    @command -v ansible >/dev/null 2>&1 || (echo "⚠️  Ansible not found - run 'just install-deps'" && exit 1)
    @echo "✅ All dependencies found!"

# Complete setup from scratch
setup: install-deps build-images
    @echo "🚀 Complete setup finished!"
    @echo "Next steps:"
    @echo "  just test        # Run full test suite" 
    @echo "  just dev         # Start development environment"
    @echo "  just test-local  # Test GitHub Actions locally"
    @echo "  just open-xpipe  # Access web interface"

# Build all base Docker images
build-images:
    @echo "Building Splunk testing framework Docker images..."
    docker build -t splunk-base-almalinux9:latest {{docker_images_dir}}/almalinux9-systemd-sshd/
    docker build -t splunk-base-ubuntu2204:latest {{docker_images_dir}}/ubuntu2204-systemd-sshd/
    docker build -t splunk-git-server:latest {{docker_images_dir}}/gitlab/
    @echo "✅ All images built successfully!"

# Build individual images
build-almalinux:
    docker build -t splunk-base-almalinux9:latest {{docker_images_dir}}/almalinux9-systemd-sshd/

build-ubuntu:
    docker build -t splunk-base-ubuntu2204:latest {{docker_images_dir}}/ubuntu2204-systemd-sshd/

build-git-server:
    docker build -t splunk-git-server:latest {{docker_images_dir}}/gitlab/

build-controller:
    docker build -t ansible-controller:latest {{docker_images_dir}}/ansible-controller/

# === PHASE 1: Container Management (Molecule) ===
[working-directory: "testing/molecule-scenarios/default"]
create-containers: build-images
    @echo "📦 Phase 1: Creating containers via Molecule..."
    uv run molecule create

[working-directory: "testing/molecule-scenarios/default"]
destroy-containers:
    @echo "💥 Destroying containers..."
    uv run molecule destroy

# === PHASE 2: SSH Key Setup ===
setup-ssh-keys:
    @echo "🔑 Phase 2: Setting up SSH keys for container communication..."
    #!/usr/bin/env bash
    set -euo pipefail
    # Create SSH key volume if it doesn't exist
    docker volume inspect ssh-keys >/dev/null 2>&1 || docker volume create ssh-keys
    # Generate SSH key pair in the shared volume
    docker run --rm -v ssh-keys:/shared/ssh_keys alpine:latest sh -c 'apk add --no-cache openssh-keygen && cd /shared/ssh_keys && if [ ! -f id_rsa ]; then ssh-keygen -t rsa -b 2048 -f id_rsa -N "" -C "splunk-test-cluster" && chmod 600 id_rsa && chmod 644 id_rsa.pub && echo "✅ SSH key pair generated"; else echo "✅ SSH keys already exist"; fi'
    
    @echo "🔐 Distributing SSH keys to all containers..."
    @for container in splunk-master splunk-license splunk-fwdmanager splunkapp-prod01 splunkapp-prod02 splunkshc-prod01 splunkshc-prod02 splunk-deploy splunk-uf01; do \
        if docker ps --format "{{ '{{' }}.Names{{ '}}' }}" | grep -q "^$${container}$$"; then \
            echo "📋 Setting up SSH for $${container}..."; \
            docker exec $$container sh -c 'mkdir -p /home/ansible/.ssh && if [ -f /shared/ssh_keys/id_rsa.pub ]; then cp /shared/ssh_keys/id_rsa.pub /home/ansible/.ssh/authorized_keys && cp /shared/ssh_keys/id_rsa /home/ansible/.ssh/ && chmod 700 /home/ansible/.ssh && chmod 600 /home/ansible/.ssh/authorized_keys && chmod 600 /home/ansible/.ssh/id_rsa && chown -R ansible:ansible /home/ansible/.ssh && (service ssh start 2>/dev/null || systemctl start sshd 2>/dev/null || /usr/sbin/sshd || true); fi' || echo "⚠️  Warning: Could not setup SSH for $${container}"; \
        else \
            echo "⚠️  Container $${container} not running"; \
        fi; \
    done
    @echo "✅ SSH setup completed"

# === PHASE 3: Splunk Deployment ===
deploy-splunk:
    @echo "🚀 Phase 3: Deploying Splunk via SSH from network-connected container..."
    @echo "⚠️  Running Ansible from within Docker network for hostname resolution"
    # Create temporary Ansible runner container on same network
    docker run --rm -i \
        --network splunk-test-network \
        -v ssh-keys:/shared/ssh_keys:ro \
        -v {{justfile_directory()}}:/workspace:ro \
        -w /workspace \
        --name ansible-runner \
        python:3.10-slim \
        bash -c 'pip install --quiet ansible && ansible-playbook -i testing/molecule/default/inventory/ playbooks/splunk_install_or_upgrade.yml'

# === PHASE 4: Verification ===
verify-ssh:
    @echo "🔍 Phase 4: Verifying SSH connectivity using container hostnames..."
    @echo "Testing SSH connectivity from within Docker network..."
    # Use network-connected container to test SSH with hostname resolution
    docker run --rm \
        --network splunk-test-network \
        -v ssh-keys:/shared/ssh_keys:ro \
        alpine:latest \
        sh -c 'apk add --quiet --no-cache openssh-client && \
        for container in splunk-master splunk-license splunk-fwdmanager splunkapp-prod01 splunkapp-prod02 splunkshc-prod01 splunkshc-prod02 splunk-deploy splunk-uf01; do \
            printf "Testing $$container: "; \
            if ssh -i /shared/ssh_keys/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=5 ansible@$$container "echo SSH_OK" 2>/dev/null; then \
                echo "✅"; \
            else \
                echo "❌"; \
            fi; \
        done'

verify-deployment:
    @echo "🔍 Verifying Splunk deployment via SSH..."
    # Run verification from network-connected container
    docker run --rm \
        --network splunk-test-network \
        -v ssh-keys:/shared/ssh_keys:ro \
        -v {{justfile_directory()}}:/workspace:ro \
        -w /workspace \
        python:3.10-slim \
        bash -c 'pip install --quiet ansible && ansible-playbook -i testing/molecule/default/inventory/ testing/molecule/default/verify.yml'

# === COMBINED WORKFLOWS ===
full-deploy: create-containers setup-ssh-keys deploy-splunk verify-deployment
    @echo "🎉 Full deployment completed!"

dev-setup: create-containers setup-ssh-keys
    @echo "🚀 Development environment ready!"
    @echo "Next steps:"
    @echo "  just deploy-splunk     # Deploy Splunk to containers"
    @echo "  just verify-ssh        # Test SSH connectivity"
    @echo "  just shell <container> # Access container shell"

# === LEGACY MOLECULE COMMANDS (for reference) ===
[working-directory: "testing/molecule-scenarios/default"]
molecule-test: build-images
    @echo "🧪 Running legacy Molecule test suite..."
    uv run molecule test

[working-directory: "testing/molecule-scenarios/default"]
molecule-converge:
    @echo "⚙️  Running Molecule converge..."
    uv run molecule converge

# Reset everything - destroy and clean Docker
reset: destroy-containers
    @echo "🔄 Resetting Docker environment..."
    docker system prune -f
    docker volume prune -f

# Recipe function to run molecule commands with proper error handling
_molecule_cmd cmd:
    #!/usr/bin/env bash
    set -euo pipefail
    cd {{molecule_scenario_dir}}
    if ! molecule {{cmd}}; then
        echo "❌ Molecule {{cmd}} failed!"
        echo "📊 Container status:"
        docker ps -a --format "table {{ '{{' }}.Names{{ '}}' }}\\t{{ '{{' }}.Status{{ '}}' }}"
        exit 1
    fi

# Show status of containers
status:
    @echo "📊 Container status:"
    docker ps -a --format "table {{ '{{' }}.Names{{ '}}' }}\t{{ '{{' }}.Status{{ '}}' }}\t{{ '{{' }}.Ports{{ '}}' }}"

# Open XPipe web interface
open-xpipe:
    @echo "🌐 Opening XPipe web interface..."
    open http://localhost:3000

# Show logs for specific container
logs container:
    docker logs {{ '{{' }}container{{ '}}' }}

# Execute shell in container
shell container:
    docker exec -it {{ '{{' }}container{{ '}}' }} /bin/bash

# Monitor all container logs
monitor:
    docker logs -f ansible-controller

# Quick development workflow
quick-test: dev-setup verify-ssh
    @echo "🎉 Quick test completed!"

# Production-like test (full cycle)
prod-test: reset full-deploy
    @echo "🎯 Production test completed!"

# Local GitHub Actions testing with act
test-local: check-deps
    @echo "🎭 Running GitHub Actions locally with act..."
    act --container-daemon-socket /var/run/docker.sock

test-local-workflow workflow: check-deps
    @echo "🎭 Running specific workflow locally: {{ '{{' }}workflow{{ '}}' }}"
    act -W .github/workflows/{{ '{{' }}workflow{{ '}}' }} --container-daemon-socket /var/run/docker.sock

test-local-event event: check-deps  
    @echo "🎭 Running GitHub Actions for event: {{ '{{' }}event{{ '}}' }}"
    act {{ '{{' }}event{{ '}}' }} --container-daemon-socket /var/run/docker.sock

# Show what act would do without running
dry-run:
    @echo "🔍 Showing what act would do (dry run)..."
    act --list --container-daemon-socket /var/run/docker.sock

# GitHub Actions utilities
act-list:
    @echo "📋 Available GitHub Actions workflows:"
    act --list

act-version:
    @command -v act >/dev/null 2>&1 && act --version || echo "❌ act not installed - run 'just install-act'"