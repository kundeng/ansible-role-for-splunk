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

task setup              # Build all Docker images
```

**Optional Environment Variables:**
- `R3_REGISTRATION_CODE` - Get your free registration code from [remote.it](https://remote.it) for external access

## 🛠️ Usage

### ✅ Current Working Commands (Sprint 3 Complete)
```bash
task lab-create         # Create 12-container lab infrastructure + SSH setup
task day0-deploy        # Deploy Splunk via SSH (connectivity verified)  
task status            # Show all container status
task lab-destroy       # Clean shutdown
```

### 🔄 Lab Infrastructure Management
```bash
task lab-create         # Create containers and setup SSH connectivity
task lab-destroy        # Destroy lab infrastructure
task status            # Show container status and health
task reset             # Full cleanup (containers + volumes + networks)
```

### 🚀 Day 0 - Splunk Provisioning (SSH Architecture Working ✅)
```bash
task day0-deploy        # Deploy Splunk role via SSH to existing lab
task day0-verify        # Verify Splunk deployment (planned)
```

### 🔧 Day 1 - Operations (Planned Sprint 4)
```bash
task day1               # Operational tasks on running cluster (planned)
```

### 🛠️ Development Utilities
```bash
task build-images       # Build all Docker base images
task logs -- <container>    # View container logs
task shell -- <container>   # Shell into container
task verify-ssh         # Test SSH connectivity between containers
```

**Current Status:** SSH architecture fixed, 12-container lab creation working, ready for Splunk role integration.

## 🌐 Web Terminal Interface

Access the web terminal at `http://localhost:3000/wetty`:

- **Terminal Access** - Direct shell access to ansible-controller
- **SSH Connectivity** - All Splunk containers accessible via SSH
- **File Navigation** - Browse and edit configurations across the cluster
- **Persistent Sessions** - Connections survive browser refreshes
- **Ansible Environment** - Pre-configured with ansible-role-for-splunk

## 🧪 Testing Scenarios

### ✅ Current Working Workflow (Sprint 3)
```bash
# Step 1: Create lab infrastructure with SSH connectivity
task lab-create         # Creates 12 containers + SSH keys ✅

# Step 2: Deploy Splunk (SSH connectivity verified, role integration pending)
task day0-deploy        # SSH works, Splunk deployment needs role fixes

# Step 3: Check status
task status            # All containers running properly ✅
```

### 🎯 Planned Sprint 4 Workflow 
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

# Sprint 4: Role integration testing (planned)
# - Fix acl package installation 
# - Fix sudo configuration
# - Complete Splunk deployment testing
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
**Problem Solved:** SSH keys are now generated in molecule-runner and distributed properly to all containers.

**Technical Details:**
- SSH keys: Generated on `localhost` (molecule-runner) via `delegate_to: localhost`
- Key distribution: Ansible copy from localhost to containers via shared volume
- Connectivity: SSH working from molecule-runner to all 12 Splunk containers
- Network: Docker hostname resolution enabling realistic SSH-based testing

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

### 🎯 Sprint 4 Planning - Splunk Role Integration
**Current Issues to Fix:**
- git-server SSH configuration (exclude from `all` group or fix SSH)
- acl package installation across different OS distributions
- sudo configuration for ansible user
- Splunk role prerequisites validation

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
- [TESTING_PROGRESS.md](TESTING_PROGRESS.md) - Sprint progress and technical achievements  
- [Molecule Testing Guide](https://ansible.readthedocs.io/projects/molecule/)

---

**Status: SSH Architecture Fixed ✅ - Ready for Splunk Role Integration**