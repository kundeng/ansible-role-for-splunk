# CLAUDE.md

This file provides comprehensive guidance for working with this repository, including project overview, architecture, development workflows, and current status.

## Project Overview

**Goal**: Create a Docker-based Molecule testing infrastructure for the upstream `ansible-role-for-splunk` repository to enable robust, automated integration testing that simulates real-world Splunk deployments.

This is the official Ansible role for Splunk administration (`ansible-role-for-splunk`) with a **planned** Docker-based Molecule testing infrastructure. The project serves dual purposes:

1.  **Production Ansible Role**: Manages Splunk Enterprise deployments (Universal Forwarders, Indexers, Search Heads, Cluster Managers, etc.) on Linux platforms
2.  **Testing Framework Vision**: Docker-based Molecule testing environment that will simulate realistic Splunk deployments and day-to-day operations

**Key Requirements**:
- Minimal modification to upstream repository (additive approach)
- Docker containers with systemd, SSH, and multi-role/multi-host scenarios
- Realistic SSH-based deployment testing (not Docker API connections)
- Support for multiple OS distributions (AlmaLinux 9, Ubuntu 22.04)
- Feature branch workflow for upstream contributions
- Clean dependency management and orchestration

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

## Architecture Overview

**Hybrid SSH Connection Architecture** - Two-phase approach:
1.  **Phase 1**: Molecule handles container creation via Docker API
2.  **Phase 2**: SSH key generation and distribution to all containers
3.  **Phase 3**: Ansible deployment via SSH connections (simulates production)
4.  **Phase 4**: Verification and testing

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
Taskfile.yml           # Cross-platform task runner
environments/          # Sample inventory structures
TBD/                   # Reference repository (private fork - reference only)
```
**Directory Structure (Detailed)**:
```
testing/
├── molecule/
│   └── default/                    # Clean path (no nested chaos)
│       ├── molecule.yml           # Molecule configuration
│       ├── inventory/             # Directory-based inventory
│   │   ├── hosts.yml         # Base hosts (shared)
│   │   └── group_vars/
│   │       └── all.yml       # SSH connection overrides
│       ├── converge.yml
│       ├── prepare.yml
│       └── verify.yml
├── docker-images/
│   ├── almalinux9-systemd-sshd/
│   ├── ubuntu2204-systemd-sshd/
│   └── gitlab/                    # Gitea lightweight git server
├── README.md
pyproject.toml                     # Clean dependency management
Taskfile.yml                      # Task orchestration
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

### Cross-Platform Testing Framework Commands
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

### Available Workflow Commands (Detailed)

```bash
# Individual molecule commands for bootstrap scenario
task bootstrap-create    # Create lab infrastructure containers
task bootstrap-prepare   # Setup SSH connectivity in lab infrastructure

# Individual molecule commands for Splunk role testing
task create-containers   # Create test containers (assumes bootstrap already ran)
task deploy-splunk      # Deploy Splunk via SSH (production-like testing)
task verify-deployment  # Verify Splunk deployment

# Combined workflows
task test                # Run full end-to-end test suite (bootstrap + Splunk role)
task dev-setup           # Setup development lab environment (runs full bootstrap test)
task quick-test          # Fast development cycle (assumes lab exists)
task prod-test           # Full production-like test from clean slate

# Utility commands
task build-images        # Build all Docker base images
task status              # Show container status
task destroy-containers  # Destroy test containers
task reset               # Full cleanup + Docker prune
task verify-ssh          # Test SSH connectivity between containers
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

## Project Status

### ✅ Completed Tasks
- **Foundation & Setup**
    1.  **Switch from CentOS to AlmaLinux** for better stability and availability
    2.  **Test Docker base image builds** with `task build-images` - all working
    3.  **Switch GitLab to Gitea** for lighter git server (from 1.72GB to ~180MB)
    4.  **Install Molecule on host with uv** for clean package isolation
    5.  **Create clean pyproject.toml** with all dependencies in single virtual environment
-   **Architecture Implementation**
    6.  **Design hybrid SSH connection architecture** - two-phase approach
    7.  **Implement shared SSH key volume** for container communication
    8.  **Update molecule.yml for pure container creation** with `pre_build_image: true`
    9.  **Create task commands for two-phase workflow** with advanced Taskfile features
    10. **Fix Molecule Docker image tagging issue** using `pre_build_image: true`
-   **Connection & Inventory Management**
    11. **Update inventory.yml for SSH-based deployment** with hostname resolution
    12. **Create enhanced inventory for SSH deployment** with container hostnames
    13. **Update deploy-splunk to use network-aware connection** via Docker network
    14. **Convert to directory-based inventory with SSH overrides** - upstream compatible
-   **Testing & Validation**
    15. **Test complete hybrid SSH architecture** - working end-to-end
    16. **Test dev-setup workflow with SSH connectivity** - containers + SSH keys
    17. **Test Docker base image builds** - AlmaLinux 9, Ubuntu 22.04, Gitea all cached
    18. **Install molecule-docker plugin** for Docker driver support

### 🚧 In Progress
- Docker image builds and testing
- SSH key distribution mechanism
- Molecule scenario implementation
- Deployment testing framework

### ✅ Currently Active Tasks Status: COMPLETE
- All major architecture components implemented and tested
- Ready for Production Use:
    - Container creation via Molecule working
    - SSH key generation and distribution implemented
    - Directory-based inventory with SSH overrides functional
    - Task workflow commands operational
    - Clean dependency management with uv + pyproject.toml

## Key Technical Solutions

### 1. Docker Image Management
- **Problem**: Molecule trying to rebuild images instead of using local ones
- **Solution**: Added `pre_build_image: true` to all platforms in molecule.yml
- **Result**: Uses existing local images, no registry pulls required

### 2. SSH Connection Architecture
- **Problem**: Need realistic SSH testing but containers have dynamic IPs
- **Solution**: Container name = hostname within Docker network + shared SSH keys
- **Result**: `ansible_host: "{{ inventory_hostname }}"` resolves automatically

### 3. Inventory Management
- **Problem**: Molecule needs Docker connection, Ansible needs SSH connection
- **Solution**: Directory-based inventory with SSH overrides in `group_vars/all.yml`
- **Result**: Single source of truth, upstream compatible, connection method override

### 4. Network-Aware Ansible Execution
- **Problem**: Host can't resolve container hostnames for SSH
- **Solution**: Run Ansible from container connected to same Docker network
- **Result**: Hostname resolution works, realistic SSH deployment testing

### 5. Clean Dependency Management
- **Problem**: Scattered tool installations causing version conflicts
- **Solution**: Single `pyproject.toml` with uv virtual environment
- **Result**: Clean, reproducible, isolated dependency management

## Lessons Learned

### ✅ Architecture Decisions
1.  **Hybrid approach is optimal**: Molecule for container lifecycle, SSH for deployment testing
2.  **Container names as hostnames**: Docker's built-in feature eliminates IP management complexity
3.  **Directory-based inventory**: More flexible and upstream-compatible than single files
4.  **Taskfile's advanced features**: `working-directory`, proper variable handling significantly improve UX

### 🔧 Technical Insights
1.  **Always use `pre_build_image: true`** when working with local Docker images in Molecule
2.  **SSH key distribution requires containers to be running**: Need proper startup sequence
3.  **Network-connected Ansible execution** is essential for hostname resolution testing
4.  **uv provides superior isolation** compared to system pip or separate tool installations

### 📁 File Organization
1.  **Avoid nested directory structures**: `testing/molecule/default/` vs `testing/molecule-scenarios/default/molecule/default/`
2.  **Always verify move/copy operations before removing**: Check file existence before cleanup
3.  **Group vars override precedence**: Directory-based inventory allows clean connection method overrides

### 🚀 Development Workflow
1.  **Start with container creation**: Get basic Docker setup working first
2.  **Add SSH incrementally**: Layer on SSH after containers are stable
3.  **Test phases independently**: Each phase should work in isolation
4.  **Use Taskfile for orchestration**: Hides complexity, provides clean interface

## Future Development and Testing Scenarios

### 📋 Planned
- Operational testing scenarios
- SplunkOps role with day-1 operations
- Combined deployment + operations testing
- CI/CD integration

### Immediate Opportunities
1.  **Test actual Splunk role deployment**: Run full `splunk_install_or_upgrade.yml` playbook
2.  **Add verification playbooks**: Test Splunk service status, cluster formation
3.  **CI/CD integration**: Add GitHub Actions workflow for automated testing
4.  **Multi-scenario support**: Test different Splunk topologies (standalone, distributed, etc.)

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

### Potential Enhancements
1.  **Dynamic inventory generation**: Optional IP-based fallback for edge cases
2.  **Performance optimization**: Container startup parallelization
3.  **Logging integration**: Centralized log collection and analysis
4.  **Security hardening**: Non-root containers, secret management

### Upstream Integration
1.  **Feature branch PR**: Create pull request to upstream repository
2.  **Documentation**: Add testing documentation to upstream README
3.  **CI integration**: Propose GitHub Actions integration for upstream testing

## Dependencies

### System Requirements
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

## File References

### Key Configuration Files
- `pyproject.toml`: Python dependencies and project metadata
- `Taskfile.yml`: Task orchestration and workflow commands
- `testing/molecule/default/molecule.yml`: Molecule container configuration
- `testing/molecule/default/inventory/hosts.yml`: Base inventory (shared)
- `testing/molecule/default/inventory/group_vars/all.yml`: SSH connection overrides

### Docker Images
- `testing/docker-images/almalinux9-systemd-sshd/Dockerfile`: AlmaLinux 9 with systemd + SSH
- `testing/docker-images/ubuntu2204-systemd-sshd/Dockerfile`: Ubuntu 22.04 with systemd + SSH
- `testing/docker-images/gitlab/Dockerfile`: Gitea lightweight git server

### Generated/Runtime Files
- `ssh-keys` Docker volume: Shared SSH keys for container communication
- `splunk-test-network` Docker network: Container communication network
- `.venv/`: uv-managed virtual environment with all dependencies

---
*Last Updated: 2025-01-08*
*Status: Production Ready*
