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

### Complete Splunk Cluster (10 containers):
- **Cluster Manager** (`splunk-master`) - Manages indexer cluster
- **License Master + DMC** (`splunk-license`) - Licensing and monitoring
- **Deployment Server** (`splunk-fwdmanager`) - App distribution to forwarders
- **2x Indexers** (`splunkapp-prod01/02`) - Multi-site data indexing  
- **2x Search Heads** (`splunkshc-prod01/02`) - Search head cluster
- **SH Deployer** (`splunk-deploy`) - App deployment to search heads
- **Universal Forwarder** (`splunk-uf01`) - Data collection
- **GitLab** (`gitlab`) - Internal git server for app deployment testing

### Management Layer:
- **XPipe Controller** - Web-based connection manager and terminal interface
- **Persistent Volumes** - Maintains state across container restarts
- **Docker Networking** - Full connectivity between all components

## 🚀 Quick Start

### Prerequisites
- Docker with 64GB+ RAM allocated
- 16+ CPU cores recommended  
- [just](https://github.com/casey/just) command runner

### One-Command Setup
```bash
git clone <this-repo>
cd ansible-role-for-splunk
just setup              # Install dependencies + build images
```

## 🛠️ Usage

### Development Lab Environment
```bash
just dev                # Start persistent Splunk lab
just open-xpipe         # Access web management interface
just status             # Check container states
```

### Testing Workflows  
```bash
just test               # Full role test suite
just test-local         # Test GitHub Actions locally (with act)
just quick-test         # Fast development validation
```

### Container Management
```bash
just logs splunk-master      # View specific container logs
just shell splunk-master     # Shell into container
just destroy                 # Clean up all containers
just reset                   # Complete environment reset
```

## 🌐 XPipe Web Interface

Access the management interface at `http://localhost:3000`:

- **Connection Manager** - Visual overview of all Splunk instances
- **Multiple Terminals** - Concurrent SSH sessions to different components
- **File Browser** - Navigate and edit configurations across the cluster
- **Persistent Sessions** - Connections survive browser refreshes
- **Git Sync** - Share connection configurations with team

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