# Splunk Testing Framework & Development Lab

A comprehensive Docker-based testing framework for the `ansible-role-for-splunk` that doubles as a full-featured Splunk development lab environment.

## 🎯 Multi-Purpose Platform

This framework serves multiple use cases:

- **Role Testing** - Validate ansible-role-for-splunk changes across realistic topologies
- **Splunk Lab Environment** - Long-running cluster for learning and experimentation  
- **Integration Testing** - Test apps, configurations, and workflows
- **Training Platform** - Learn Splunk clustering, administration, and troubleshooting
- **POC Environment** - Test new Splunk features and configurations safely
- **CI/CD Pipeline** - Automated testing for pull requests and releases

## 🏗️ Architecture

### Complete Splunk Cluster (12 containers):
- **Cluster Manager** (`splunk-master`) - Manages indexer cluster
- **License Master + DMC** (`splunk-license`) - Licensing and monitoring
- **Deployment Server** (`splunk-fwdmanager`) - App distribution to forwarders
- **2x Indexers** (`splunkapp-prod01/02`) - Multi-site data indexing  
- **2x Search Heads** (`splunkshc-prod01/02`) - Search head cluster
- **SH Deployer** (`splunk-deploy`) - App deployment to search heads
- **Universal Forwarder** (`splunk-uf01`) - Data collection
- **Git Server** (`git-server`) - Gitea lightweight git server for app deployment testing

### Management & Access Layer:
- **Ansible Controller** (`ansible-controller`) - Web terminal and deployment control
- **Remote.it Jumpbox** (`remoteit-jumpbox`) - External secure access gateway
- **Persistent Volumes** - Maintains state across container restarts
- **Docker Networking** - Full connectivity between all components

## 🚀 Quick Start

### Prerequisites
- Docker with 32GB+ RAM allocated (64GB+ recommended)
- 8+ CPU cores (16+ recommended)  
- [Task](https://taskfile.dev) command runner (installed automatically)

### Setup Process
```bash
git clone <this-repo>
cd ansible-role-for-splunk/testing

# Copy environment template and configure (optional)
cp .env.example .env
# Edit .env and add your Remote.it registration code if needed

task setup              # Provision host secrets + build all Docker images
```

**Optional Environment Variables:**
- `R3_REGISTRATION_CODE` - Get your free registration code from [remote.it](https://remote.it) for external access

## 🛠️ Usage

### ✅ Primary Commands (Streamlined)
```bash
task lab-create         # Create 12-container lab infrastructure + SSH setup (runs setup:ensure)
task day0-deploy        # Deploy Splunk via SSH (connectivity verified)
task status            # Show all container status
task lab-destroy       # Clean shutdown
```

### 🔄 Lab Infrastructure Management
```bash
task lab-create         # Create containers and setup SSH connectivity (runs setup:ensure)
task lab-destroy        # Destroy lab infrastructure
task status            # Show container status and health
task reset             # Full cleanup (containers + volumes + networks)
```

> Note: `lab-destroy` removes containers and the scenario network but intentionally does not delete named Docker volumes (e.g., Splunk data volumes, ssh-keys). Use `task reset` between full test runs to minimize cross-run interference.

### 🚀 Day 0 - Splunk Provisioning (SSH Architecture Working ✅)
```bash
task day0-deploy        # Deploy Splunk role via SSH to existing lab
task day0-verify        # Verify Splunk deployment (in progress)
```

### 🔧 Day 1 - Operations (Planned)
```bash
task day1               # Operational tasks on running cluster (planned)
```

### 🛠️ Development Utilities
```bash
task build-images       # Build all Docker base images
task logs -- <container>    # View container logs
task shell -- <container>   # Shell into container
task verify-ssh         # Test SSH connectivity between containers
task controller:shell   # Shell into ansible-controller
task lab-status         # Show lab containers on splunk-test-network
```

**Current Status:** SSH architecture fixed across Ubuntu and AlmaLinux. Lab creation working. PAM/login gating stabilized for containerized environments.

## 🌐 Web Terminal Interface

Access the web terminal at `http://localhost:3000/wetty`:

- **Terminal Access** - Direct shell access to ansible-controller
- **SSH Connectivity** - All Splunk containers accessible via SSH
- **File Navigation** - Browse and edit configurations across the cluster
- **Persistent Sessions** - Connections survive browser refreshes
- **Ansible Environment** - Pre-configured with ansible-role-for-splunk

## 🧪 Testing Scenarios

### ✅ Current Working Workflow (Streamlined)
```bash
# Step 1: Ensure prerequisites (secrets + images), destroy+create lab, run prepare
task setup              # One-time: provision host secrets + build images
task lab-recreate       # Idempotent: setup:ensure → destroy → create → prepare

# Step 2: Deploy Splunk (SSH connectivity verified, role integration pending)
task day0-deploy        # SSH works, Splunk deployment needs role fixes

# Step 3: Check status
task status            # All containers running properly ✅
```

### 🎯 Planned Workflow 
```bash
# Complete development workflow (planned)
task lab-create         # Create lab infrastructure
task day0-deploy        # Deploy Splunk via SSH (fix role prerequisites)  
task day0-verify        # Verify Splunk deployment health
task day1               # Operations testing (restart, backup, maintenance)

# Full end-to-end testing (planned)
task full-test          # Complete automated test suite
```

### Current Development Iteration
```bash
# Working development cycle
task lab-create         # Create fresh lab environment  
task day0-deploy        # Test SSH connectivity to all hosts ✅
task status            # Verify all containers healthy ✅
task lab-destroy       # Clean shutdown ✅

# Critical Fixes Sprint (active)
# - SSH login gating repaired across distros (see PAM section below)
# - Validate/repair sudo configuration
# - Complete Splunk deployment testing (prereqs + runtime)
# - Add verification and operations testing
```

## 📊 Resource Requirements

### Minimum:
- **RAM**: 32GB (basic functionality)
- **CPU**: 8 cores
- **Disk**: 50GB free space

### Recommended:
- **RAM**: 64GB (full performance)
- **CPU**: 16+ cores  
- **Disk**: 100GB+ free space
- **Docker**: Privileged containers enabled

## 🔧 Advanced Usage

### 🏗️ SSH Architecture (Sprint 3 Achievement)
**Problem Solved:** SSH keys are generated in molecule-runner and distributed properly to all containers.

**Technical Details:**
- SSH keys: Generated on `localhost` (molecule-runner) via `delegate_to: localhost`
- Named volume: Keys persisted under `/shared/ssh_keys` (mounted into runner)
- Key distribution: Public key pushed to all containers; private key never copied to hosts
- Controller: Keys also copied to `/workspace/.ssh/` on `ansible-controller` for local SSH convenience
- Ansible: Uses `/shared/ssh_keys/id_rsa` via `group_vars/all.yml`
- Connectivity: SSH working from molecule-runner to all 12 Splunk containers
- Network: Docker hostname resolution enabling realistic SSH-based testing

### 🔐 End-to-End Key Distribution Logic (Source of Truth = molecule-runner)
1. Key generation
   - `molecule/lab/prepare.yml` runs `openssh_keypair` on `localhost` (runner) → `/shared/ssh_keys/id_rsa`
2. Publish and cache
   - `slurp` reads `/shared/ssh_keys/id_rsa(.pub)` from localhost
   - Private key stays in volume; public key is used for distribution
3. Distribution to hosts
   - Public key written to `/home/ansible/.ssh/authorized_keys` on every host
   - Client config created to disable strict host key checking
4. Controller convenience
   - Both keys copied to `ansible-controller:/workspace/.ssh/` for interactive SSH
5. Ansible configuration
   - `testing/molecule/inventory/group_vars/all.yml` sets `ansible_ssh_private_key_file: /shared/ssh_keys/id_rsa`

Guarantees:
- No keys are baked into images
- No per-scenario regeneration (lab prepares, later scenarios reuse)
- Private key is never distributed to Splunk hosts

### 📁 Scenario Structure (Current Working)
```
molecule/
├── inventory/           # Shared inventory drives all scenarios
│   ├── hosts.yml       # Infrastructure specification
│   └── group_vars/     # SSH configuration overrides
├── lab/                # Container creation + SSH setup ✅
├── day0/               # Splunk provisioning (SSH working) ✅  
└── day1/               # Operations (planned Sprint 4)
```

### 👤 End-to-End User Management Logic and Execution Contexts

**Understanding how users and processes execute throughout the testing lifecycle:**

#### Phase 1: Container Bootstrap (Molecule Create)
- **Host Process**: Docker daemon runs as root
- **Container Init**: `/sbin/init` starts as **UID=0 (root)** inside container
- **systemd Services**: SSH daemon, systemd-user-sessions run as root
- **Molecule Connection**: `ansible_connection: docker, ansible_user: root`
- **Purpose**: Container infrastructure setup, service initialization

#### Phase 2: SSH Infrastructure Setup (Molecule Prepare)  
- **Connection Method**: SSH from molecule-runner to containers
- **SSH Target User**: `ansible` user (**UID=1000**) 
- **SSH Key Authentication**: Password-less SSH keys distributed to `ansible` user
- **Privilege Escalation**: `ansible` user uses `sudo` to become root for system tasks
- **Purpose**: SSH connectivity, key distribution, system preparation

#### Phase 3: Splunk Role Deployment (ansible-playbook)
- **Connection Method**: SSH from molecule-runner to containers
- **SSH Target User**: `ansible` user (**UID=1000**)
- **Privilege Context**: 
  - Most tasks run as `ansible` user
  - System tasks use `become: true` → `sudo` → **UID=0 (root)**
- **User Management Tasks**:
  - `ansible` user (UID=1000) uses `sudo` to create `splunk` user (**UID varies**)
  - `ansible` user (UID=1000) uses `sudo` to create `splunk` group (**GID varies**)
- **File Operations**:
  - Download/extract: `ansible` user → `sudo` → root creates files
  - Ownership changes: root changes ownership to `splunk:splunk`
- **Service Management**: `ansible` user → `sudo` → root manages systemd services

#### Phase 4: Splunk Application Runtime (Post-Deployment)
- **Splunk Processes**: Run as **`splunk` user** (not root)
- **File Ownership**: `/opt/splunk/` owned by `splunk:splunk`
- **Service Control**: systemd manages splunkd service running as `splunk` user
- **Management Access**: `ansible` user can still SSH in and `sudo` for administration

#### Key User Hierarchy:
1. **Container systemd (root/UID=0)**: Container init and system services
2. **ansible user (UID=1000)**: SSH access + sudo privileges for management
3. **splunk user (UID=varies)**: Runs Splunk application processes
4. **molecule-runner**: External orchestration, connects via SSH to `ansible` user

#### Critical Sudo Requirement:
The `ansible` user **must** be able to `sudo` without password to:
- Create `splunk` user/group
- Install software to `/opt/`
- Change file ownership
- Manage systemd services
- Configure system files

**Critical Fix Focus**: Validate AlmaLinux sudo/PAM behavior using distro defaults (no custom PAM overrides). Repair only if issues persist.

### 🔒 PAM and Login Gating in Containers

Containerized systemd environments can block non-root SSH logins during early boot or due to PAM account policies. This lab applies minimal, distro-appropriate fixes:

- Ubuntu/Debian family
  - Issue: `/run/nologin` may be present during boot; `pam_nologin` denies non-root users with “System is booting up…”.
  - Fix: `systemd-user-sessions.service` enabled in the base image and started in `molecule/lab/prepare.yml`. It removes `/run/nologin` when the system is ready.

- RedHat/AlmaLinux family
  - Issue: PAM account phase can deny the `ansible` user via `pam_sepermit.so` in minimal/container contexts (e.g., SELinux mappings or environment not fully initialized).
  - Fix (image-level): In `almalinux9-systemd-sshd/Dockerfile`, `pam_sepermit` is relaxed from `required` to `optional` in `/etc/pam.d/sshd`.
  - What “optional” means: If a PAM module marked `optional` fails or denies, it does not by itself cause the whole PAM stack to fail. The decision defers to other `sufficient`/`required` modules that follow. This avoids hard-failing SSH logins solely due to `pam_sepermit` in containerized lab setups where SELinux/policy contexts may be atypical. Security tradeoff is acceptable for this isolated test lab; production systems should keep distro defaults.

These changes are intentionally narrow, preserve distro defaults where possible, and are documented/reversible. The Splunk role under test remains untouched.

### 🎯 Sprint 4 Status - Container User Management Fixed

**Completed Issues:**
- ✅ git-server SSH configuration (excluded from `all` group)
- ✅ acl package installation (skipped via conditional)
- ✅ duplicate user creation conflicts (removed from prepare.yml)
- ✅ SSH key architecture (generate in molecule-runner, distribute properly)

**Current Issue:**
- 🚧 AlmaLinux PAM configuration for `ansible` user `sudo` in systemd containers

### Environment Persistence  
The lab environment persists data between runs:
- SSH keys in shared volume (working ✅)
- Splunk configurations and data (planned)
- Container networking and hostname resolution (working ✅)

### Integration Testing
Use this environment to:
- Test ansible-role-for-splunk changes with SSH connectivity ✅
- Validate deployment across multiple OS distributions
- Test cluster operations and maintenance procedures (planned)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch  
3. Test SSH connectivity: `task lab-create && task day0-deploy`
4. Verify changes work across all container types
5. Submit pull request

## 📖 Documentation

- [CLAUDE.md](../CLAUDE.md) - Complete project documentation and current status
- [SPRINT_LOG.md](SPRINT_LOG.md) - Sprint progress and technical achievements  
- [Molecule Testing Guide](https://ansible.readthedocs.io/projects/molecule/)

---

**Status: SSH Architecture Fixed ✅ - Ready for Splunk Role Integration**