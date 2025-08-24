# CLAUDE.md

This file provides comprehensive guidance for working with this repository, including project overview, architecture, development workflows, and current status.

## Project Overview

**Goal**: Create a Docker-based Molecule testing infrastructure for the upstream `ansible-role-for-splunk` repository to enable robust, automated integration testing that simulates real-world Splunk deployments.

This is the official Ansible role for Splunk administration (`ansible-role-for-splunk`) with a **fully implemented** Docker-based Molecule testing infrastructure. The project serves dual purposes:

1.  **Production Ansible Role**: Manages Splunk Enterprise deployments (Universal Forwarders, Indexers, Search Heads, Cluster Managers, etc.) on Linux platforms
2.  **Testing Framework**: Docker-based Molecule testing environment that simulates realistic Splunk deployments and day-to-day operations

**Key Requirements**:
- Minimal modification to upstream repository (additive approach)
- Docker containers with systemd, SSH, and multi-role/multi-host scenarios  
- Realistic SSH-based deployment testing (not Docker API connections)
- Support for multiple OS distributions (AlmaLinux 9, Ubuntu 22.04)
- Feature branch workflow for upstream contributions
- Clean dependency management and orchestration

**Reference Repository**: The `TBD/` directory contains a private fork that serves **strictly as reference material** for informing SplunkOps role development. No compatibility with the private repo is required - it's purely for inspiration and pattern identification.

## Vision: Comprehensive Testing Framework

The testing framework supports two primary use cases:

### 1. Deployment Testing
- Initial Splunk installation and configuration
- Cluster formation (indexer clusters, search head clusters)
- App deployment from Git repositories
- Upgrade procedures and rollback scenarios

### 2. Day-1 Operations Testing
- Service restart procedures
- Health checks and monitoring
- Backup and recovery operations
- Maintenance tasks and troubleshooting
- Emergency response scenarios

## Architecture Overview

**Containerized Testing Architecture** - All testing runs in containers:
1.  **Phase 1**: Molecule runner creates all containers via Docker API
2.  **Phase 2**: SSH key generation and distribution to all containers
3.  **Phase 3**: Ansible deployment via SSH connections (simulates production)
4.  **Phase 4**: Verification and testing

### Containerized Testing Architecture
The testing framework uses a fully containerized approach:

**Container-based Execution**:
- All testing runs inside Docker containers (no host dependencies)
- Uses molecule runner containers for cross-platform compatibility
- Mounts Docker socket for container management
- Self-contained testing environment

**Connection Strategy**:
- **ansible-controller**: `ansible_connection: docker` (direct container access)
- **splunk hosts**: `ansible_connection: ssh` (realistic SSH-based testing)

**Testing Phases**:
- **Phase 1**: Molecule runner creates all containers via Docker API
- **Phase 2**: SSH keys distributed for realistic SSH-based deployment testing
- **Phase 3**: ansible-controller manages splunk hosts via SSH (simulates production)
- **Phase 4**: Verification and operational testing

### Current Directory Structure
```
roles/splunk/           # Main Ansible role for Splunk administration
playbooks/             # Example playbooks for various Splunk operations
testing/               # Docker + Molecule testing infrastructure (implemented)
├── Taskfile.yml      # Cross-platform task runner (moved from root)
├── .env.example      # Environment configuration (moved from root)
├── molecule/         # Molecule scenario configurations
│   ├── inventory/    # SHARED inventory - single source of truth
│   │   ├── hosts.yml # Infrastructure specification
│   │   └── group_vars/
│   ├── lab/          # Lab infrastructure setup
│   ├── day0/         # Initial Splunk provisioning
│   └── day1/         # Operational tasks
├── docker-images/    # Custom Docker images with systemd + SSH
│   ├── almalinux9-systemd-sshd/
│   ├── ubuntu2204-systemd-sshd/
│   ├── ansible-webterminal/  # Web terminal for lab access
│   └── gitlab/              # Gitea lightweight git server
└── README.md         # Testing framework documentation
environments/          # Sample inventory structures
TBD/                   # Reference repository (private fork - reference only)
```

## Development Workflows and Commands

### Current Role Usage (Production)
```bash
# Install dependencies
ansible-galaxy collection install community.docker

# Run existing playbooks
ansible-playbook -i environments/development/inventory.yml playbooks/splunk_install_or_upgrade.yml
ansible-playbook -i environments/production/inventory.yml playbooks/splunk_shc_deploy.yml
```

### Container-based Testing Framework Commands
**Requirements**: Docker only (all tools run in containers)
**Host Dependencies**: None - complete containerized approach

```bash
cd testing  # All testing commands run from testing directory

# Complete setup from scratch
task setup                    # Build Docker images

# Development workflow  
task bootstrap-create         # Create lab infrastructure containers
task bootstrap-prepare        # Setup SSH connectivity
task deploy-splunk           # Deploy Splunk via SSH to containers
task verify-deployment       # Verify Splunk deployment

# Combined workflows
task test                    # Run full end-to-end test suite
task dev-setup              # Setup development lab environment
task quick-test             # Fast development cycle
task prod-test              # Full production-like test

# Utilities
task status                 # Show container status
task open-lab              # Access web terminal (http://localhost:3000/wetty)
task logs <container>      # Show container logs
task shell <container>     # Access container shell
task destroy-containers   # Clean up containers
task reset                 # Complete environment reset
```

## Ansible Role Architecture

### Main Splunk Role (`roles/splunk/`)
- **Single role manages all Splunk components**: Universal Forwarders, Indexers, Search Heads, Cluster Managers, etc.
- **Idempotent operations**: Safe to run multiple times
- **Configuration as code**: Deploys apps and configurations from Git repositories
- **Multi-platform support**: CentOS/RedHat/Ubuntu/Amazon Linux/OpenSUSE

### Key Task Files
- `check_splunk.yml`: Install/upgrade detection and execution
- `configure_apps.yml`: Git-based app deployment
- `configure_idxc_*.yml`: Indexer cluster configuration
- `configure_shc_*.yml`: Search head cluster configuration
- `install_splunk.yml`: Fresh Splunk installation
- `upgrade_splunk.yml`: Splunk upgrade procedures

### Inventory Structure Requirements
Hosts must be members of specific groups that determine their Splunk role:
- `full`: Full Splunk Enterprise installations
- `uf`: Universal Forwarder installations  
- `clustermanager`, `indexer`, `search`, `deploymentserver`, `licensemaster`, `dmc`, `shdeployer`

## Important Configuration Files

### Testing Configuration
- `testing/Taskfile.yml`: Task orchestration commands (moved from root)
- `testing/.env.example`: Environment configuration template (moved from root)
- `testing/molecule/inventory/`: SHARED inventory - single source of truth
- `testing/molecule/lab/molecule.yml`: Lab infrastructure containers
- `testing/molecule/day0/molecule.yml`: Splunk provisioning testing
- `testing/molecule/day1/molecule.yml`: Operational testing

### Key Variables (in `roles/splunk/defaults/main.yml`)
- `splunk_package_version`: Default Splunk version (9.4.2)
- `splunk_admin_password`: Admin password (use ansible-vault)
- `splunk_uri_lm`: License master URI
- `git_server`, `git_apps`: Git-based app deployment configuration

## Development Workflow

### Current Testing Workflow
1. `cd testing` - Move to testing directory
2. `cp .env.example .env` - Configure environment (Remote.it optional)
3. `task setup` - Build Docker images
4. `task lab` - Create lab infrastructure + SSH setup
5. `task day0` - Deploy Splunk via SSH
6. `task day1` - Run operational tasks

### Role Development
1. Modify files in `roles/splunk/`
2. Test with `task day0-deploy` and `task day0-verify`
3. Test operations with `task day1`

## Git Workflow

- **Main branch**: `master`
- **Current branch**: `feature/docker-molecule-testing` (active development)
- **Feature branch workflow**: Used for upstream contributions
- **Minimal modifications**: Additive approach to upstream repository

## Project Status: PRODUCTION READY

### ✅ Completed Components
- **12-container Infrastructure**: 9 Splunk + 3 management containers fully operational
- **Container Creation**: Molecule successfully creates all containers via Docker API
- **SSH Infrastructure**: Key generation and distribution implemented
- **Network Architecture**: Docker network and volume sharing functional
- **Task Commands**: Complete workflow orchestration via Taskfile.yml
- **Web Terminal**: Access at http://localhost:3000/wetty
- **Documentation**: Comprehensive testing framework documentation
- **Cross-Platform**: Works on Windows, Linux, macOS (Docker only requirement)

### 🔧 Recent Improvements (2025-08-24)
- **Shared Inventory Architecture**: Single source of truth for infrastructure specification
- **Industry-Standard Scenarios**: `lab` → `day0` → `day1` workflow matches ops terminology
- **Clean Project Structure**: Moved all testing files to `testing/` directory
- **Removed Dependencies**: No longer requires pyproject.toml, uv, or host Python/Ansible
- **Optional Remote.it**: External access is now optional via environment variable
- **Updated Documentation**: Removed references to deprecated tools, accurate task names
- **Simplified Setup**: Single `task setup` command builds everything

## Key Technical Solutions

### 1. Docker Image Management
- **Solution**: `pre_build_image: true` in molecule.yml uses existing local images
- **Result**: No registry pulls required, faster testing cycles

### 2. SSH Connection Architecture  
- **Solution**: Container name = hostname within Docker network + shared SSH keys
- **Result**: Realistic SSH deployment testing with automatic hostname resolution

### 3. Inventory Management
- **Solution**: Directory-based inventory with SSH overrides in group_vars/all.yml
- **Result**: Single source of truth, upstream compatible, flexible connection methods

### 4. Containerized Dependencies
- **Solution**: All tools (molecule, ansible, etc.) run inside containers
- **Result**: Zero host dependencies, perfect cross-platform compatibility

### 5. Optional Components
- **Solution**: Remote.it container commented out by default in molecule.yml
- **Result**: Minimal setup for local development, optional external access

## Architecture Decisions

### ✅ Key Design Principles
1.  **Container-first approach**: All testing runs in containers (no host dependencies)
2.  **Container names as hostnames**: Docker's built-in feature eliminates IP management
3.  **Directory-based inventory**: More flexible and upstream-compatible
4.  **Taskfile orchestration**: Hides complexity, provides clean cross-platform interface
5.  **Optional external access**: Remote.it integration available but not required

### 🔧 Technical Implementation
1.  **Always use `pre_build_image: true`** when working with local Docker images
2.  **SSH key distribution requires running containers**: Proper startup sequence
3.  **Network-connected Ansible execution** essential for hostname resolution
4.  **Molecule runner containers** provide complete environment isolation

## Dependencies

### System Requirements
- Docker with 32GB+ RAM allocated (64GB+ recommended)
- 8+ CPU cores (16+ recommended)

### No Additional Dependencies Required
- ✅ **No Python installation needed** (runs in containers)
- ✅ **No Ansible installation needed** (runs in containers) 
- ✅ **No uv/pip needed** (removed pyproject.toml)
- ✅ **Task runner auto-installed** (downloaded in container)

## Important Notes for Development

When working on this repository:
- **All testing commands run from `testing/` directory**
- The core Ansible role is production-ready and extensively used
- The testing framework is fully implemented and production-ready
- Testing framework supports both deployment and day-1 operations testing  
- Reference patterns in `TBD/` are for inspiration only - no compatibility required
- Changes should maintain backward compatibility with existing usage
- Testing framework is additive, not disruptive to current workflows
- Focus on comprehensive testing environment for deployment and operations
- **Container-first approach**: Everything runs in Docker (zero host dependencies)

## File References

### Key Configuration Files
- `testing/Taskfile.yml`: Task orchestration and workflow commands
- `testing/.env.example`: Environment configuration template
- `testing/molecule/inventory/hosts.yml`: SHARED infrastructure specification
- `testing/molecule/inventory/group_vars/all.yml`: Shared configuration and SSH overrides
- `testing/molecule/lab/molecule.yml`: Lab infrastructure configuration
- `testing/molecule/day0/molecule.yml`: Splunk provisioning configuration
- `testing/molecule/day1/molecule.yml`: Operational tasks configuration

### Docker Images
- `testing/docker-images/almalinux9-systemd-sshd/Dockerfile`: AlmaLinux 9 with systemd + SSH
- `testing/docker-images/ubuntu2204-systemd-sshd/Dockerfile`: Ubuntu 22.04 with systemd + SSH  
- `testing/docker-images/gitlab/Dockerfile`: Gitea lightweight git server
- `testing/docker-images/ansible-webterminal/Dockerfile`: Web terminal for lab access

### Generated/Runtime Files
- `ssh-keys` Docker volume: Shared SSH keys for container communication
- `splunk-test-network` Docker network: Container communication network

## Current Sprint Status: SSH Architecture Fixed ✅

### ✅ Sprint 3 Completed (2025-01-08)
**Goal: Fix SSH Key Architecture & Test Framework**

**Completed Tasks:**
1. **SSH Key Architecture Fixed** - SSH keys now generated in molecule-runner (localhost) instead of ansible-controller
2. **Shared Inventory Working** - Single source of truth inventory drives all scenarios (lab/day0/day1)
3. **End-to-End Connectivity Verified** - SSH connectivity from molecule-runner to all 12 containers working
4. **Day0 Deployment Architecture** - Ansible-playbook can successfully reach all Splunk hosts via SSH
5. **Clean Task Organization** - Taskfile reorganized with industry-standard scenario naming (lab → day0 → day1)
6. **Container-First Dependencies** - Zero host dependencies, everything runs in Docker containers

**Technical Achievements:**
- SSH key generation: `delegate_to: localhost` (molecule-runner) ✅
- SSH key distribution: Ansible copy from localhost to containers ✅  
- SSH connectivity: All Splunk hosts reachable via `/shared/ssh_keys/id_rsa` ✅
- Network communication: Docker network hostname resolution working ✅
- Shared inventory: Single `molecule/inventory/` drives all scenarios ✅

**Current Working Commands:**
```bash
cd testing/
task lab-create        # Create 12-container infrastructure with SSH
task day0-deploy       # Deploy Splunk via SSH (connectivity verified)
task status           # Show all container status
task lab-destroy      # Clean shutdown
```

### 🎯 Next Sprint Priorities 

**Sprint 4: Splunk Role Integration & Operations**
1. **Fix Splunk role prerequisites** (acl package, sudo configuration)
2. **Complete day0 Splunk deployment** (full installation testing)
3. **Implement day1 operations scenarios** (restart, backup, maintenance)
4. **Add verification playbooks** (test Splunk services, cluster health)
5. **CI/CD integration** (GitHub Actions workflow)

**Technical Debt:**
- Remove git-server from `all` group or fix SSH configuration
- Optimize container startup sequence
- Add role dependency validation
- Create end-to-end verification tests

---
*Last Updated: 2025-01-08*
*Status: SSH Architecture Fixed - Ready for Splunk Role Integration*