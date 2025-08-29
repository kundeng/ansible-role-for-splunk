# Testing Framework Progress Log

<!-- 
SPRINT ENTRY TEMPLATE:

### YYYY-MM-DD - Sprint Title [Active/✅]
**Goal:** Brief description of sprint goal

**Scope:**
- Item 1
- Item 2

**Tasks Completed:**
- ✅ Task 1 - Brief description
- ✅ Task 2 - Brief description

**Technical Achievements:**
- Achievement 1
- Achievement 2

**Key Files Modified:**
- `path/to/file`: Description of changes

**Verified Working:**
```bash
command example
```

**Next Sprint Ready:** Brief description
-->

## Sprint Summary
<!-- Most recent sprints at the top -->

### 2025-08-29 - Inventory & SSH Stabilization → Ready for Day 0 ✅
**Goal:** Finalize inventory, SSH diagnostics, and artifact sourcing to unblock Day 0.

**Scope:**
- Fix YAML inventory syntax and host vars
- Ensure bind mount to `/workspace` in `ansible-controller`
- Verify SSH via Ansible ping; exclude `git_server`
- Unify artifact source to remote URLs; remove predownload step from setup
- Keep ACL installs skipped in container tests

**Tasks Completed:**
- ✅ `testing/molecule/inventory/hosts.yml`: indentation fixes; host-level vars corrected
- ✅ `testing/Taskfile.yml`: `sys:diag:ssh` targets `full` (excludes `git_server`)
- ✅ `testing/molecule/inventory/group_vars/all.yml`: deduplicate `skip_acl_install`
- ✅ `testing/Taskfile.yml`: remove `sys:download` from `sys:setup` (use remote URLs)
- ✅ `task lab:run`: end-to-end create → prepare → converge succeeded

**Technical Achievements:**
- Single source of truth inventory at `/workspace/testing/molecule/inventory/hosts.yml`
- SSH diagnostics streamlined (Ansible ping covers SSH transport)
- Artifact retrieval standardized via URLs (Splunk 9.1.2)
- Faster container tests with `skip_acl_install: true`

**Key Files Modified:**
- `testing/molecule/inventory/hosts.yml`: YAML corrections
- `testing/Taskfile.yml`: diagnostics scope and setup simplification
- `testing/molecule/inventory/group_vars/all.yml`: duplicate key removed
- `testing/README.md`: Next Phase: Day 0; status updated

**Verified Working:**
```bash
task sys:diag:ssh   # Pings group 'full' successfully
task lab:run        # Full cycle passes (create → prepare → converge)
```

**Next Sprint Ready:** Day 0 provisioning using Taskfile targets


### 2025-08-30 - ttyd Default Implementation ✅
**Goal:** Make ttyd the default web terminal and remove all Wetty-related configurations

**Scope:**
- Remove all Wetty-related configurations and references
- Update all relevant files to make ttyd the default terminal
- Ensure consistent documentation and task naming

**Tasks Completed:**
- ✅ **Rename Dockerfile** - Renamed Dockerfile.ttyd to Dockerfile in ansible-controller
- ✅ **Update Taskfile** - Removed Wetty-specific tasks and renamed ttyd tasks to generic terminal tasks
- ✅ **Update Documentation** - Updated README.md to reflect ttyd as the default terminal
- ✅ **Standardize Task Names** - Changed task names from wetty/ttyd-specific to generic terminal references

**Technical Achievements:**
- Simplified container build process with a single Dockerfile
- Standardized task naming convention for better maintainability
- Removed duplicate health check tasks
- Consolidated documentation to reflect ttyd as the only terminal option

**Key Files Modified:**
- `testing/docker-images/ansible-controller/Dockerfile`: Updated from Dockerfile.ttyd
- `testing/Taskfile.yml`: Removed Wetty tasks, renamed ttyd tasks to terminal tasks
- `testing/README.md`: Updated to reflect ttyd as the default terminal

**Verified Working:**
```bash
task controller:build  # Builds ansible-controller with ttyd
task lab-create       # Creates lab with ttyd terminal
task terminal:health  # Confirms ttyd is working properly
```

**Next Sprint Ready:** Full Splunk deployment testing with standardized web terminal

### 2025-08-29 - Web Terminal Replacement: ttyd Implementation ✅
**Goal:** Replace Wetty with ttyd for a more stable and maintained web terminal solution

**Scope:**
- Implement ttyd as a replacement for Wetty in the ansible-controller container
- Configure nginx for ttyd access at the same endpoint
- Create systemd service for ttyd management
- Ensure compatibility with existing infrastructure
- Fix security and interactivity issues

**Tasks Completed:**
- ✅ **Research Alternatives** - Evaluated multiple web terminal options (ttyd, Shell In A Box, GateOne)
- ✅ **Maintenance Verification** - Confirmed ttyd is actively maintained (latest release March 2024)
- ✅ **Dockerfile Creation** - Created new Dockerfile.ttyd with ttyd implementation
- ✅ **Service Configuration** - Created systemd service file for ttyd
- ✅ **Nginx Configuration** - Created nginx configuration for ttyd access
- ✅ **Security Hardening** - Fixed direct access to ttyd by binding to localhost only
- ✅ **Terminal Interactivity** - Added --writable flag to enable input in ttyd terminal
- ✅ **External Access** - Updated nginx configuration to accept connections from all interfaces
- ✅ **Authentication Security** - Configured ttyd to use SSH for proper authentication

**Technical Achievements:**
- Selected ttyd for its active maintenance, C-based implementation, and xterm.js frontend
- Eliminated JavaScript dependency issues by using a compiled C application
- Maintained compatibility with existing nginx configuration and port mapping
- Configured ttyd with appropriate terminal settings (font size, theme)
- Simplified deployment by using direct compilation from source
- Fixed port conflict between ttyd and nginx (ttyd on 7681, nginx on 3000)
- Secured ttyd by binding only to localhost and using nginx as a reverse proxy
- Enabled terminal interactivity with the --writable flag
- Implemented SSH authentication for ttyd to require password login

**Key Files Modified:**
- `testing/docker-images/ansible-controller/Dockerfile.ttyd`: New Dockerfile for ttyd implementation
- `testing/docker-images/ansible-controller/ttyd.service`: Updated service to bind to localhost and enable writable mode
- `testing/docker-images/ansible-controller/ttyd.nginx.conf`: Updated nginx configuration to proxy to ttyd on port 7681

**Verified Working:**
```bash
# Build the new container with ttyd
docker build -t ansible-controller:ttyd -f Dockerfile.ttyd .

# Access ttyd at http://localhost:3000/ttyd after container deployment
# Terminal is fully interactive and secure
```

**Next Sprint Ready:** Full Splunk deployment testing with secure and interactive web terminal

### 2025-08-28 - Wetty JavaScript Errors Fix ✅
**Goal:** Fix Wetty web terminal JavaScript errors and ensure full functionality

**Scope:**
- Resolve JavaScript errors in Wetty web terminal
- Ensure terminal prompt appears correctly
- Maintain compatibility with nginx configuration

**Tasks Completed:**
- ✅ **Root Cause Analysis** - Identified JavaScript errors in Wetty 2.6.0
- ✅ **Version Testing** - Tested older versions of Wetty for compatibility
- ✅ **Configuration Fix** - Downgraded Wetty to version 2.4.0 which resolves the errors
- ✅ **Documentation** - Updated Dockerfile with the working version

**Technical Achievements:**
- Resolved JavaScript errors related to undefined properties
- Fixed terminal functionality while maintaining nginx configuration
- Identified stable version of Wetty for the container environment
- Tested newer versions (2.7.0) but found FontAwesome module errors (`Uncaught TypeError: Failed to resolve module specifier "@fortawesome/fontawesome-svg-core"`)
- Confirmed 2.4.0 as the most stable version for our environment

**Key Files Modified:**
- `testing/docker-images/ansible-controller/Dockerfile`: Updated Wetty version from 2.6.0 to 2.4.0

**Verified Working:**
```bash
task wetty:health  # Confirms HTTP 200 response from Wetty endpoint
# Wetty accessible at http://localhost:3000/wetty with working terminal prompt
```

**Next Sprint Ready:** Full Splunk deployment testing with fully functional web terminal

---

### 2025-08-28 - Wetty Nginx Hostname Fix ✅
**Goal:** Fix Wetty web terminal hostname resolution issue in nginx configuration

**Scope:**
- Wetty web terminal accessibility at http://localhost:3000/wetty
- Nginx configuration for proper hostname resolution
- IPv4/IPv6 compatibility

**Tasks Completed:**
- ✅ **Root Cause Analysis** - Identified nginx listening only on IPv6 interface
- ✅ **Configuration Fix** - Updated nginx to listen on both IPv4 and IPv6 interfaces
- ✅ **Directory Structure Fix** - Added task to ensure nginx sites directories exist
- ✅ **Documentation** - Added comments to clarify hostname handling

**Technical Achievements:**
- Fixed nginx configuration to support both IPv4 and IPv6 connections
- Ensured nginx sites directories exist before configuration
- Ensured hostname resolution works properly in container environment
- Maintained compatibility with existing Docker networking setup

**Key Files Modified:**
- `testing/molecule/lab/prepare.yml`: Updated nginx configuration template and added directory creation task

**Verified Working:**
```bash
task lab-create     # Creates containers with fixed nginx config
task wetty:health  # Confirms HTTP 200 response from Wetty endpoint
# Wetty accessible at http://localhost:3000/wetty
```

**Next Sprint Ready:** Full Splunk deployment testing with working web terminal

---

### 2025-08-27 - Critical Fixes Sprint: Stabilize Sudo/PAM and Day0 (Active)
**Goal:** Freeze architecture; fix critical blockers preventing full Day0 deployment.

**Scope:**
- SSH keys: Source of truth is molecule-runner (named volume `/shared/ssh_keys`)
- Key distribution: Public key to hosts' `authorized_keys`; private key not distributed
- Controller convenience: Keys copied to `/workspace/.ssh/` on `ansible-controller`
- Ansible config: `ansible_ssh_private_key_file: /shared/ssh_keys/id_rsa`
- User management: `ansible` user SSH + passwordless sudo; `splunk` user runs Splunk
- PAM policy: Use distro defaults; only adjust if validation shows breakage

**PAM Configuration Solution:**
- **Problem Identified:** SSH key authentication failing in AlmaLinux containers with `fatal: Access denied for user ansible by PAM account configuration [preauth]`
- **Root Cause:** Default PAM account validation modules fail in container environments due to missing system services
- **Solution:** Created simplified PAM configuration that uses `pam_permit.so` for account phase to bypass complex validation
- **Implementation:** Modified Dockerfile to create minimal PAM configs for sshd, password-auth, and system-auth
- **Key Changes:**
  - Replace complex account validation with `pam_permit.so`
  - Remove `nullok` parameter from `pam_unix.so` for better security
  - Make session modules optional to avoid failures
  - Configure SSH server for key authentication with `UsePAM yes` and `PubkeyAuthentication yes`
  - Enable systemd-user-sessions service to allow unprivileged user login

**Planned Validation (no code changes):**
1. task lab-destroy → clean reset
2. task lab-create → SSH keys generated on runner and propagated
3. Verify wetty at http://localhost:3000/wetty
4. From controller: SSH to all nodes; check `sudo -n true`
5. task day0-deploy → capture failures for `roles/splunk/tasks/prereqs.yml`

**Exit Criteria:**
- Ansible SSH works end-to-end with key-based auth
- `ansible` user can sudo without password on AlmaLinux and Ubuntu
- Day0 playbook reaches Splunk role tasks; remaining failures documented

---

### 2025-08-23 - Sprint 2: Project Cleanup and Organization ✅
**Tasks:**
- ✅ Remove unused .act* files and GitHub workflows
- ✅ Move Taskfile.yml and .env* files into testing framework
- ✅ Remove pyproject.toml (using containerized molecule)
- ✅ Update documentation to remove 'just' references
- ✅ Reorganize project structure for better clarity

**Progress:**
- Cleaned up root directory structure
- Consolidated testing framework files
- Updated documentation to reflect current architecture

**Decisions:**
- All testing-related files should live in testing/ directory
- Use containerized approach for all dependencies
- Remote.it integration is optional

---

### 2025-08-15 - Docker Infrastructure Implementation ✅
**Tasks:**
- ✅ Complete Docker-based testing framework with 12-container infrastructure
- ✅ Fix container creation via Molecule
- ✅ Implement SSH key distribution system
- ✅ Test hybrid SSH connection architecture

**Progress:**
- All Docker images build successfully
- 11/11 containers created via Molecule
- SSH key generation and distribution working
- Network connectivity between containers established

**Decisions:**
- Use hybrid approach: Molecule for container lifecycle, SSH for deployment testing
- Container names as hostnames eliminates IP management complexity
- Directory-based inventory for upstream compatibility

---

### 2025-08-08 - Foundation and Architecture Design ✅
**Tasks:**
- ✅ Switch from CentOS to AlmaLinux 9 for better stability
- ✅ Switch from GitLab to Gitea for lighter git server (1.72GB → 180MB)
- ✅ Design hybrid SSH connection architecture
- ✅ Implement shared SSH key volume for container communication

**Progress:**
- Base Docker images working (AlmaLinux 9, Ubuntu 22.04)
- Clean dependency management with uv + pyproject.toml
- Molecule Docker integration functional

**Decisions:**
- Two-phase approach: container creation + SSH deployment
- Ephemeral molecule-runner for cross-platform compatibility
- Minimal modification to upstream repository (additive approach)

---

### 2025-01-08 - Sprint 3: SSH Architecture Fixed ✅
**Goal:** Fix SSH key architecture and establish working end-to-end connectivity

**Tasks Completed:**
- ✅ **SSH Key Architecture Fixed** - Generate keys in molecule-runner instead of ansible-controller
- ✅ **Shared Inventory Implementation** - Single source inventory drives all scenarios  
- ✅ **SSH Connectivity Verified** - All 12 containers reachable via SSH
- ✅ **Day0 Architecture Working** - Ansible can reach Splunk hosts for deployment
- ✅ **Task Organization** - Clean lab → day0 → day1 workflow
- ✅ **Zero Host Dependencies** - Everything runs in Docker containers

**Technical Achievements:**
- SSH keys: `delegate_to: localhost` (molecule-runner) instead of ansible-controller
- Key distribution: Ansible copy from localhost to containers via shared volume
- Connectivity: SSH working from molecule-runner to all Splunk infrastructure  
- Network: Docker hostname resolution enabling realistic SSH testing
- Inventory: Shared `molecule/inventory/` specification drives all scenarios

**Key Files Modified:**
- `molecule/lab/prepare.yml`: SSH key generation fixed
- `molecule/inventory/group_vars/all.yml`: SSH key path corrected  
- `Taskfile.yml`: SSH volume mounting added
- All scenarios: Inventory references unified

**Verified Working:**
```bash
task lab-create     # Creates 12 containers + SSH setup
task day0-deploy    # SSH connectivity verified to all hosts
task status         # All containers running properly
```

**Next Sprint Ready:** Splunk role integration (prerequisites, deployment, operations)

---

## Current Status

### ✅ Working Components
- **Infrastructure**: 12-container Splunk cluster (9 Splunk + 3 management)
- **Container Creation**: Molecule successfully creates all containers
- **SSH Infrastructure**: Key generation and distribution implemented
- **Networking**: Docker network and volume sharing functional
- **Documentation**: Comprehensive testing framework documentation
- **Web Terminal**: Access at http://localhost:3000/wetty
- **PAM Configuration**: Simplified PAM stack for container environments

### 🚧 Areas for Enhancement
- **Permission Issues**: Webtop container needs PUID/PGID configuration
- **Optional Components**: Make Remote.it integration conditional

### 🎯 Next Steps
1. Test full Splunk deployment workflow
2. Add operational testing scenarios
3. Implement CI/CD integration

---

## Technical Solutions Implemented

### PAM Configuration for Containers
- **Solution**: Simplified PAM stack with `pam_permit.so` for account validation
- **Result**: SSH key authentication works reliably in container environments

### Docker Image Management
- **Solution**: `pre_build_image: true` in molecule.yml uses existing local images
- **Result**: No registry pulls required, faster testing cycles

### SSH Connection Architecture  
- **Solution**: Container name = hostname within Docker network + shared SSH keys
- **Result**: Realistic SSH deployment testing with automatic hostname resolution

### Inventory Management
- **Solution**: Directory-based inventory with SSH overrides in group_vars/all.yml
- **Result**: Single source of truth, upstream compatible, flexible connection methods

### Clean Dependency Management
- **Solution**: Containerized molecule runner with all dependencies
- **Result**: No host dependencies, cross-platform compatibility

---

## Key Achievements

1. **Full Molecule Integration** - 11-container cluster creation working
2. **Multi-OS Docker Images** - AlmaLinux 9 and Ubuntu 22.04 functional
3. **Docker Networking** - Custom network and volume sharing operational
4. **SSH Infrastructure** - Key generation and distribution framework complete
5. **Complex Container Orchestration** - Molecule handles privileged containers, networks, volumes
6. **Documentation Framework** - Comprehensive testing and usage documentation
7. **Container Authentication** - Solved PAM authentication issues in container environments

The framework architecture is fundamentally sound with all critical issues resolved.