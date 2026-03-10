# Tasks: pr-252-review-fixes

## Overview

Implement the review-driven harness changes in small, low-risk phases: bootstrap the spec metadata, clean the PR surface, replace hardcoded secrets with `.secrets`-compatible inputs, apply reviewed Ansible conventions, parameterize artifact metadata, then validate and prepare reviewer responses.

## Tasks

- [x] 1. Bootstrap spec and repo metadata
  - [x] 1.1 Add root `AGENTS.md` and create the spec artifacts
    - Add the Windloop snippet to `AGENTS.md` and create `requirements.md`, `design.md`, `tasks.md`, and `progress.txt` for this work.
    - **Depends**: —
    - **Requirements**: 1.3
    - **Properties**: 4

- [ ] 2. Clean the PR surface and docs
  - [ ] 2.1 Remove `testing/CLAUDE.md` and `testing/PROGRESS.md` from the PR branch scope
    - Delete the review artifacts from the PR branch and keep the cleanup focused on the testing harness.
    - **Depends**: 1.1
    - **Requirements**: 1.1
    - **Properties**: 4

  - [ ] 2.2 Update `testing/README.md` to remove stale artifact references and keep bootstrap guidance aligned with the harness architecture
    - Remove links/references to deleted files and keep the docs aligned with the cross-platform Taskfile bootstrap.
    - **Depends**: 2.1
    - **Requirements**: 1.2, 5.2, 5.3
    - **Properties**: 4

- [ ] 3. Replace hardcoded secrets with `.secrets`-aligned inputs
  - [ ] 3.1 Extend `testing/Taskfile.yml` setup to generate required harness secret files under `testing/.secrets`
    - Add idempotent generation for the Splunk admin password and git-server secret input alongside existing SSH and terminal secrets.
    - **Depends**: 1.1
    - **Requirements**: 2.1, 2.4
    - **Properties**: 1

  - [ ] 3.2 Update inventories and runtime configuration to consume generated secret-driven inputs
    - Replace inline `splunk_admin_password` literals in environment group vars and resolve the git-server secret through env/file-driven configuration compatible with the generated secret files.
    - **Depends**: 3.1
    - **Requirements**: 2.2, 2.3, 2.4
    - **Properties**: 1

  - [ ] 3.3 Write property-style validation for secret generation and references
    - Validate that the touched files consistently reference the generated secret inputs and fail clearly when the files are absent.
    - **Depends**: 3.1, 3.2
    - **Properties**: 1

- [ ] 4. Apply reviewed Ansible lifecycle conventions
  - [ ] 4.1 Move `ansible_python_interpreter` to play scope in the touched lifecycle playbooks
    - Update the directly reviewed lifecycle playbooks and analogous low-risk files.
    - **Depends**: 1.1
    - **Requirements**: 3.1, 3.3
    - **Properties**: 2

  - [ ] 4.2 Convert built-in module usage to FQCN in touched playbooks
    - Make mechanical `ansible.builtin.*` updates in the reviewed/touched testing playbooks.
    - **Depends**: 4.1
    - **Requirements**: 3.2, 3.3
    - **Properties**: 2

  - [ ] 4.3 Run lint-style validation for the touched Ansible files
    - Use the repo’s lint tooling on the touched harness playbooks and fix any issues.
    - **Depends**: 4.1, 4.2
    - **Properties**: 2

- [ ] 5. Parameterize Splunk artifact metadata
  - [ ] 5.1 Introduce shared Splunk version/build parameters in the harness bootstrap/configuration layer
    - Centralize current test artifact metadata in a shared location that downstream files can consume.
    - **Depends**: 1.1
    - **Requirements**: 4.1, 4.3
    - **Properties**: 3

  - [ ] 5.2 Update touched scenario and inventory files to derive filenames/URLs from the shared parameters
    - Remove repeated literal version/build references in the reviewed paths while preserving current behavior.
    - **Depends**: 5.1
    - **Requirements**: 4.1, 4.2, 4.3
    - **Properties**: 3

  - [ ] 5.3 Write validation for shared artifact metadata consistency
    - Validate that the touched references remain internally consistent after parameterization.
    - **Depends**: 5.1, 5.2
    - **Properties**: 3

- [ ] 6. Validation and reviewer follow-up
  - [ ] 6.1 Run targeted validation commands for the edited harness paths
    - Run YAML/lint checks and at least one representative harness command if feasible.
    - **Depends**: 2.2, 3.3, 4.3, 5.3
    - **Requirements**: NF 1, NF 2, NF 3
    - **Properties**: 1, 2, 3, 4

  - [ ] 6.2 Draft concise reviewer-facing responses for the addressed comments
    - Prepare short replies explaining the direct fixes and the bootstrap/taskfile rationale where needed.
    - **Depends**: 6.1
    - **Requirements**: 5.2, 5.3
    - **Properties**: 4

## Notes

- The `task`/bootstrap reviewer comment should be answered by clarifying that `Taskfile.yml` is the cross-platform bootstrap/orchestration layer and cannot be moved entirely into `molecule-runner` because it bootstraps the runner itself.
- Platform-native wrappers are a possible follow-up, not part of this PR unless review feedback makes them mandatory.
