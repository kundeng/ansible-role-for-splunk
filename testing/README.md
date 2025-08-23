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
- [Task](https://taskfile.dev) command runner

### Setup Process
```bash
git clone <this-repo>
cd ansible-role-for-splunk

# Copy environment template and configure
cp .env.example .env
# Edit .env and add your Remote.it registration code

task setup              # Install dependencies + build images
```

**Required Environment Variables:**
- `R3_REGISTRATION_CODE` - Get your free registration code from [remote.it](https://remote.it)

## 🛠️ Usage

### Development Lab Environment
```bash
task bootstrap-create   # Create lab infrastructure
task bootstrap-prepare  # Setup SSH connectivity  
task status             # Check container states
```

### Testing Workflows  
```bash
task deploy-splunk      # Deploy Splunk via SSH (production-like)
task verify-deployment  # Verify Splunk cluster formation
task quick-test         # Fast development validation
```

### Container Management
```bash
task logs <container>        # View specific container logs
task shell <container>       # Shell into container
task destroy-containers      # Clean up all containers
task reset                   # Complete environment reset
```

## 🌐 Web Terminal Interface

Access the web terminal at `http://localhost:3000/wetty`:

- **Terminal Access** - Direct shell access to ansible-controller
- **SSH Connectivity** - All Splunk containers accessible via SSH
- **File Navigation** - Browse and edit configurations across the cluster
- **Persistent Sessions** - Connections survive browser refreshes
- **Ansible Environment** - Pre-configured with ansible-role-for-splunk

## 🧪 Testing Scenarios

### Role Development Testing
1. Make changes to the ansible-role-for-splunk
2. Run `just dev` to apply changes to lab environment
3. Use XPipe to verify cluster formation, app deployment, etc.
4. Run `just test` for full validation

### Local CI/CD Testing  
```bash
just test-local         # Runs the same tests as GitHub Actions
```

### Production-Like Validation
```bash
just prod-test          # Full reset + comprehensive testing
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

### Custom Scenarios
Create additional Molecule scenarios in `molecule/` for specific testing:
- `backup-restore` - Test backup/rollback workflows
- `upgrade-testing` - Validate upgrade procedures
- `app-deployment` - Test git-based app deployment

### Environment Persistence
The lab environment persists data between runs:
- Splunk configurations and apps
- Indexed data and search artifacts
- User accounts and permissions
- Custom configurations and modifications

### Integration with Production
Use this environment to:
- Test configuration changes before production deployment
- Reproduce production issues safely
- Train team members on cluster operations
- Validate new app deployments

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Test changes with `just dev` and `just test-local`
4. Submit pull request (GitHub Actions will validate)

## 📖 Documentation

- [XPipe Documentation](https://docs.xpipe.io/guide/webtop)
- [Molecule Testing Guide](https://ansible.readthedocs.io/projects/molecule/)
- [Ansible Role for Splunk](https://github.com/splunk/ansible-role-for-splunk)

---

**This framework transforms ansible-role-for-splunk testing from a development task into a comprehensive Splunk learning and experimentation platform.**