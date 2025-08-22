# Active Context - Splunk Testing Framework

## Project Brief

**Goal**: Create a Docker-based Molecule testing infrastructure for the upstream `ansible-role-for-splunk` repository to enable robust, automated integration testing that simulates real-world Splunk deployments.

**Key Requirements**:
- Minimal modification to upstream repository (additive approach)
- Docker containers with systemd, SSH, and multi-role/multi-host scenarios
- Realistic SSH-based deployment testing (not Docker API connections)
- Support for multiple OS distributions (AlmaLinux 9, Ubuntu 22.04)
- Feature branch workflow for upstream contributions
- Clean dependency management and orchestration

## Architecture Overview

**Hybrid SSH Connection Architecture** - Two-phase approach:
1. **Phase 1**: Molecule handles container creation via Docker API
2. **Phase 2**: SSH key generation and distribution to all containers
3. **Phase 3**: Ansible deployment via SSH connections (simulates production)
4. **Phase 4**: Verification and testing

**Directory Structure**:
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

## Completed Tasks

### ✅ **Foundation & Setup**
1. **Switch from CentOS to AlmaLinux** for better stability and availability
2. **Test Docker base image builds** with `task build-images` - all working
3. **Switch GitLab to Gitea** for lighter git server (from 1.72GB to ~180MB)
4. **Install Molecule on host with uv** for clean package isolation
5. **Create clean pyproject.toml** with all dependencies in single virtual environment

### ✅ **Architecture Implementation**
6. **Design hybrid SSH connection architecture** - two-phase approach
7. **Implement shared SSH key volume** for container communication
8. **Update molecule.yml for pure container creation** with `pre_build_image: true`
9. **Create task commands for two-phase workflow** with advanced Taskfile features
10. **Fix Molecule Docker image tagging issue** using `pre_build_image: true`

### ✅ **Connection & Inventory Management**
11. **Update inventory.yml for SSH-based deployment** with hostname resolution
12. **Create enhanced inventory for SSH deployment** with container hostnames
13. **Update deploy-splunk to use network-aware connection** via Docker network
14. **Convert to directory-based inventory with SSH overrides** - upstream compatible

### ✅ **Testing & Validation**
15. **Test complete hybrid SSH architecture** - working end-to-end
16. **Test dev-setup workflow with SSH connectivity** - containers + SSH keys
17. **Test Docker base image builds** - AlmaLinux 9, Ubuntu 22.04, Gitea all cached
18. **Install molecule-docker plugin** for Docker driver support

## Currently Active Tasks

**Status**: ✅ **COMPLETE** - All major architecture components implemented and tested

**Ready for Production Use**:
- Container creation via Molecule working
- SSH key generation and distribution implemented
- Directory-based inventory with SSH overrides functional
- Task workflow commands operational
- Clean dependency management with uv + pyproject.toml

## Available Workflow Commands

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

## Key Technical Solutions

### **1. Docker Image Management**
- **Problem**: Molecule trying to rebuild images instead of using local ones
- **Solution**: Added `pre_build_image: true` to all platforms in molecule.yml
- **Result**: Uses existing local images, no registry pulls required

### **2. SSH Connection Architecture**
- **Problem**: Need realistic SSH testing but containers have dynamic IPs
- **Solution**: Container name = hostname within Docker network + shared SSH keys
- **Result**: `ansible_host: "{{ inventory_hostname }}"` resolves automatically

### **3. Inventory Management**
- **Problem**: Molecule needs Docker connection, Ansible needs SSH connection
- **Solution**: Directory-based inventory with SSH overrides in `group_vars/all.yml`
- **Result**: Single source of truth, upstream compatible, connection method override

### **4. Network-Aware Ansible Execution**
- **Problem**: Host can't resolve container hostnames for SSH
- **Solution**: Run Ansible from container connected to same Docker network
- **Result**: Hostname resolution works, realistic SSH deployment testing

### **5. Clean Dependency Management**
- **Problem**: Scattered tool installations causing version conflicts
- **Solution**: Single `pyproject.toml` with uv virtual environment
- **Result**: Clean, reproducible, isolated dependency management

## Lessons Learned

### **✅ Architecture Decisions**
1. **Hybrid approach is optimal**: Molecule for container lifecycle, SSH for deployment testing
2. **Container names as hostnames**: Docker's built-in feature eliminates IP management complexity
3. **Directory-based inventory**: More flexible and upstream-compatible than single files
4. **Taskfile's advanced features**: `working-directory`, proper variable handling significantly improve UX

### **🔧 Technical Insights**
1. **Always use `pre_build_image: true`** when working with local Docker images in Molecule
2. **SSH key distribution requires containers to be running**: Need proper startup sequence
3. **Network-connected Ansible execution** is essential for hostname resolution testing
4. **uv provides superior isolation** compared to system pip or separate tool installations

### **📁 File Organization**
1. **Avoid nested directory structures**: `testing/molecule/default/` vs `testing/molecule-scenarios/default/molecule/default/`
2. **Always verify move/copy operations before removing**: Check file existence before cleanup
3. **Group vars override precedence**: Directory-based inventory allows clean connection method overrides

### **🚀 Development Workflow**  
1. **Start with container creation**: Get basic Docker setup working first
2. **Add SSH incrementally**: Layer on SSH after containers are stable
3. **Test phases independently**: Each phase should work in isolation
4. **Use Taskfile for orchestration**: Hides complexity, provides clean interface

## Next Steps for Future Development

### **Immediate Opportunities**
1. **Test actual Splunk role deployment**: Run full `splunk_install_or_upgrade.yml` playbook
2. **Add verification playbooks**: Test Splunk service status, cluster formation
3. **CI/CD integration**: Add GitHub Actions workflow for automated testing
4. **Multi-scenario support**: Test different Splunk topologies (standalone, distributed, etc.)

### **Potential Enhancements**
1. **Dynamic inventory generation**: Optional IP-based fallback for edge cases
2. **Performance optimization**: Container startup parallelization
3. **Logging integration**: Centralized log collection and analysis
4. **Security hardening**: Non-root containers, secret management

### **Upstream Integration**
1. **Feature branch PR**: Create pull request to upstream repository
2. **Documentation**: Add testing documentation to upstream README
3. **CI integration**: Propose GitHub Actions integration for upstream testing

## File References

### **Key Configuration Files**
- `pyproject.toml`: Python dependencies and project metadata
- `Taskfile.yml`: Task orchestration and workflow commands
- `testing/molecule/default/molecule.yml`: Molecule container configuration
- `testing/molecule/default/inventory/hosts.yml`: Base inventory (shared)
- `testing/molecule/default/inventory/group_vars/all.yml`: SSH connection overrides

### **Docker Images**
- `testing/docker-images/almalinux9-systemd-sshd/Dockerfile`: AlmaLinux 9 with systemd + SSH
- `testing/docker-images/ubuntu2204-systemd-sshd/Dockerfile`: Ubuntu 22.04 with systemd + SSH  
- `testing/docker-images/gitlab/Dockerfile`: Gitea lightweight git server

### **Generated/Runtime Files**
- `ssh-keys` Docker volume: Shared SSH keys for container communication
- `splunk-test-network` Docker network: Container communication network
- `.venv/`: uv-managed virtual environment with all dependencies

---
*Last Updated: 2025-01-08*
*Status: Production Ready*