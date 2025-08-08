# Splunk Testing Framework with Docker + Molecule
# Usage: just <command>

# Variables - following engineering best practices
repo_root := justfile_directory()
testing_dir := repo_root / "testing"
docker_images_dir := testing_dir / "docker-images"
molecule_dir := testing_dir / "molecule-scenarios"
workflows_dir := repo_root / ".github" / "workflows"

# Default recipe - show available commands
default:
    @just --list

# Setup and installation tasks
install-deps:
    @echo "🔧 Installing development dependencies..."
    @echo "Installing act (GitHub Actions local runner)..."
    curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
    @echo "Installing Python dependencies..."
    python3 -m pip install --upgrade pip
    pip3 install molecule[docker] docker-py ansible-lint yamllint
    @echo "✅ All dependencies installed!"

install-act:
    @echo "🎭 Installing act (GitHub Actions local runner)..."
    curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
    @echo "✅ act installed! Test with: just test-local"

check-deps:
    @echo "🔍 Checking dependencies..."
    @command -v docker >/dev/null 2>&1 || (echo "❌ Docker not found" && exit 1)
    @command -v act >/dev/null 2>&1 || (echo "⚠️  act not found - run 'just install-act'" && exit 1)  
    @python3 -c "import molecule" 2>/dev/null || (echo "⚠️  Molecule not found - run 'just install-deps'" && exit 1)
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
    docker build -t splunk-gitlab:latest {{docker_images_dir}}/gitlab/
    docker build -t ansible-controller:latest {{docker_images_dir}}/ansible-controller/
    @echo "✅ All images built successfully!"

# Build individual images
build-almalinux:
    docker build -t splunk-base-almalinux9:latest {{docker_images_dir}}/almalinux9-systemd-sshd/

build-ubuntu:
    docker build -t splunk-base-ubuntu2204:latest {{docker_images_dir}}/ubuntu2204-systemd-sshd/

build-gitlab:
    docker build -t splunk-gitlab:latest {{docker_images_dir}}/gitlab/

build-controller:
    docker build -t ansible-controller:latest {{docker_images_dir}}/ansible-controller/

# Molecule testing commands  
test: build-images
    @echo "🧪 Running full Molecule test suite..."
    cd {{molecule_dir}} && molecule test

# Start containers for development (don't destroy)
dev: build-images
    @echo "🚀 Starting development environment..."
    cd {{molecule_dir}} && molecule converge --destroy never

# Create containers only (no provisioning)
create: build-images
    @echo "📦 Creating containers..."
    cd {{molecule_dir}} && molecule create

# Run Ansible provisioning on existing containers
converge:
    @echo "⚙️  Running Ansible provisioning..."
    cd {{molecule_dir}} && molecule converge

# Verify the deployment
verify:
    @echo "✅ Verifying deployment..."
    cd {{molecule_dir}} && molecule verify

# Clean up containers
cleanup:
    @echo "🧹 Cleaning up containers..."
    cd {{molecule_dir}} && molecule cleanup

# Destroy all containers and cleanup
destroy:
    @echo "💥 Destroying test environment..."
    cd {{molecule_dir}} && molecule destroy

# Reset everything - destroy and clean Docker
reset: destroy
    @echo "🔄 Resetting Docker environment..."
    docker system prune -f
    docker volume prune -f

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
quick-test: build-images create converge verify
    @echo "🎉 Quick test completed!"

# Production-like test (full cycle)
prod-test: reset test
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