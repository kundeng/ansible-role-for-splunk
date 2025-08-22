# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the official Ansible role for Splunk administration (`ansible-role-for-splunk`) with a **planned** Docker-based Molecule testing infrastructure. The project serves dual purposes:

1. **Production Ansible Role**: Manages Splunk Enterprise deployments (Universal Forwarders, Indexers, Search Heads, Cluster Managers, etc.) on Linux platforms
2. **Testing Framework Vision**: Docker-based Molecule testing environment that will simulate realistic Splunk deployments and day-to-day operations

**Current State**: The testing framework is **implemented and functional** on the `feature/docker-molecule-testing` branch with cross-platform support.

**Reference Repository**: The `TBD/` directory contains a private fork that serves **strictly as reference material** for informing SplunkOps role development. No compatibility with the private repo is required - it's purely for inspiration and pattern identification.

## Vision: Comprehensive Testing Framework

The testing framework will support two primary use cases:

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

## Testing Architecture (Current)

### Ephemeral Molecule Runner Architecture
The testing framework uses a containerized approach for cross-platform compatibility:

**Ephemeral molecule-runner container**:
- Runs all molecule commands (create, prepare, converge, verify, destroy)
- Mounts Docker socket for container management
- No host dependencies (Python/Ansible not needed on host)
- Self-contained testing environment

**Connection Strategy**:
- **ansible-controller**: `ansible_connection: docker` (direct container access)
- **splunk hosts**: `ansible_connection: ssh` (realistic SSH-based testing)

**Testing Phases**:
- **Phase 1**: molecule-runner creates all containers via Docker API
- **Phase 2**: SSH keys distributed for realistic SSH-based deployment testing  
- **Phase 3**: ansible-controller manages splunk hosts via SSH (simulates production)
- **Phase 4**: Verification and operational testing

### Target Directory Structure
```
roles/splunk/           # Main Ansible role for Splunk administration
playbooks/             # Example playbooks for various Splunk operations
testing/               # Docker + Molecule testing infrastructure (implemented)
├── molecule/default/  # Molecule scenario configuration
├── docker-images/     # Custom Docker images with systemd + SSH
│   ├── molecule-runner/    # Ephemeral testing container
│   ├── ansible-controller/ # Webtop lab environment
│   └── ...systemd images   # AlmaLinux/Ubuntu with SSH
└── README.md         # Testing framework documentation
Taskfile.yml           # Cross-platform task runner (replaces justfile)
environments/          # Sample inventory structures
TBD/                   # Reference repository (private fork - reference only)
```

## Development Commands

### Current Role Usage (Production)
```bash
# Install dependencies
ansible-galaxy collection install community.docker

# Run existing playbooks
ansible-playbook -i environments/development/inventory.yml playbooks/splunk_install_or_upgrade.yml
ansible-playbook -i environments/production/inventory.yml playbooks/splunk_shc_deploy.yml
```

### Cross-Platform Testing Framework (Current)
**Requirements**: Docker + go-task (https://taskfile.dev)
**Host Dependencies**: None - all testing runs in containers

```bash
# Complete setup from scratch  
task setup                    # Install dependencies + build Docker images

# Development workflow
task dev-setup                # Create containers + setup SSH keys
task deploy-splunk            # Deploy Splunk via SSH to containers
task verify-ssh               # Test SSH connectivity
task verify-deployment        # Verify Splunk deployment

# Operational testing  
task test-operations          # Test day-1 operations scenarios
task test-backups             # Test backup and recovery procedures
task test-restarts            # Test service restart scenarios
task test-maintenance         # Test maintenance operations

# Combined workflows
task full-deploy              # Complete end-to-end deployment test
task full-ops                 # Complete operational testing
task quick-test               # Fast development cycle
task prod-test                # Full production-like test

# Utilities
task status                   # Show container status
task open-lab                 # Access web lab environment (http://localhost:3000)
task logs <container>         # Show container logs
task shell <container>        # Access container shell
task reset                    # Clean everything and start fresh
```

### Testing Architecture Details (Current)
**Ephemeral Molecule Runner**: 
- Runs in `molecule-runner` container with Docker socket mounted
- Provisions all containers including ansible-controller
- No host dependencies (Python/Ansible not needed on host)

**Connection Types**:
- `ansible-controller`: Uses `ansible_connection: docker` (direct container access)
- `splunk hosts`: Use `ansible_connection: ssh` (realistic production testing)

**SSH Testing**:
- SSH keys generated and distributed by molecule-runner
- Splunk role tested with real SSH connections between containers
- Mirrors production deployment scenarios

## Ansible Role Architecture (Current)

### Main Splunk Role (`roles/splunk/`)
- **Single role manages all Splunk components**: Universal Forwarders, Indexers, Search Heads, Cluster Managers, etc.
- **Idempotent operations**: Safe to run multiple times
- **Configuration as code**: Deploys apps and configurations from Git repositories
- **Multi-platform support**: CentOS/RedHat/Ubuntu/Amazon Linux/OpenSUSE

### Key Task Files (Current)
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

## SplunkOps Role Development (Informed by Reference)

The reference repository in `TBD/` provides inspiration for operational patterns:

### Operational Categories (Reference Patterns)
- **On-Call Operations**: Restart procedures, health checks, emergency fixes
- **Git-Based App Management**: Synchronization, version control, deployments
- **Task Automation**: Discovery, maintenance, standardized procedures
- **Backup Operations**: Pre-change backups, recovery procedures

### Key Insights from Reference (No Compatibility Required)
- Serial execution for safety (`serial: 1`)
- Backup-before-change patterns
- Conditional execution based on service state
- Parameterized operational playbooks
- Vault integration for secrets management

## Important Configuration Files

### Current Configuration
- `pyproject.toml`: Python dependencies (Ansible, Molecule, etc.)
- `Taskfile.yml`: Task orchestration commands (framework defined)
- `roles/splunk/defaults/main.yml`: All configurable variables with defaults

### Planned Testing Configuration
- `testing/molecule/default/molecule.yml`: Container and platform definitions
- `testing/molecule/default/inventory/`: Directory-based inventory structure
- `testing/molecule/default/verify.yml`: Deployment verification tests
- `testing/molecule/operations/`: Operational testing scenarios (planned)

### Key Variables (in `roles/splunk/defaults/main.yml`)
- `splunk_package_version`: Default Splunk version (9.4.2)
- `splunk_admin_password`: Admin password (use ansible-vault)
- `splunk_uri_lm`: License master URI
- `git_server`, `git_apps`: Git-based app deployment configuration

## Development Workflow

### Current Role Development
1. Modify files in `roles/splunk/`
2. Test manually with existing inventory and playbooks
3. Reference `TBD/` patterns for operational insights (no compatibility needed)

### Planned Testing Workflow
1. Modify files in `roles/splunk/`
2. Test deployment with `task bootstrap-create && task bootstrap-prepare && task deploy-splunk`
3. Test operations with `task test-operations`
4. Verify with `task verify-deployment`

### SplunkOps Role Development
1. Study patterns in `TBD/` for inspiration (reference only)
2. Develop independent operational playbooks
3. Focus on common day-1 operations scenarios
4. Test both deployment and operations in the same framework

## Git Workflow

- **Main branch**: `master`
- **Current branch**: `feature/docker-molecule-testing` (active development)
- **Feature branch workflow**: Used for upstream contributions
- **Minimal modifications**: Additive approach to upstream repository

## Implementation Status

### ✅ Completed
- Core Ansible role (production-ready)
- Foundation Docker image definitions
- Taskfile framework setup
- Python dependency management with uv
- Reference repository analysis (for inspiration)

### 🚧 In Progress
- Docker image builds and testing
- SSH key distribution mechanism
- Molecule scenario implementation
- Deployment testing framework

### 📋 Planned
- Operational testing scenarios
- SplunkOps role with day-1 operations
- Combined deployment + operations testing
- CI/CD integration

## Testing Scenarios (Planned)

### Deployment Scenarios
- Fresh Splunk installation
- Cluster formation and configuration
- App deployment from Git
- Upgrade procedures

### Operational Scenarios
- Service restarts (individual and cluster-wide)
- Health checks and status verification
- Backup and recovery procedures
- Maintenance operations
- Troubleshooting scenarios

## Dependencies

### System Requirements (Current)
- Python 3.10+
- Ansible >= 8.0.0
- SSH client for manual testing

### Additional Requirements (When Testing Framework Complete)
- Docker with 32GB+ RAM allocated
- Task command runner

### Python Dependencies (managed by uv)
- ansible >= 8.0.0
- molecule >= 6.0.0
- molecule-docker >= 2.1.0
- ansible-lint >= 6.0.0

## Important Notes for Development

When working on this repository:
- The core Ansible role is production-ready and extensively used
- The testing framework is the primary innovation being developed
- The testing framework should support both deployment and day-1 operations testing
- Reference patterns in `TBD/` are for inspiration only - no compatibility required
- Changes should maintain backward compatibility with existing usage
- Testing framework should be additive, not disruptive to current workflows
- Focus on creating a comprehensive testing environment for both deployment and operations
- remember to always go in correct sequence. from task to the right container to the right container etc etc.
- don't you remember we can't assume we have a linux system on the docker host, thus we do provisin through molecule container???