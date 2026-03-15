# Tasks: pr-252-review-fixes

## Overview

Implement the review-driven harness changes in small, reviewer-traceable phases: clean the PR surface, address each concrete reviewer concern in the touched harness files, validate the results with explicit tooling/rerun steps on the feature branch, then prepare reviewer responses before cherry-picking tested fixes to the PR branch.

## Tasks

- [x] 1. Bootstrap spec and repo metadata
  - [x] 1.1 Add root `AGENTS.md` and create the spec artifacts
    - Add the Windloop snippet to `AGENTS.md` and create `requirements.md`, `design.md`, `tasks.md`, and `progress.txt` for this work.
    - **Depends**: —
    - **Requirements**: 1
    - **Properties**: 1

- [ ] 2. Clean the PR surface and docs
  - [ ] 2.1 Remove `testing/CLAUDE.md` and `testing/PROGRESS.md` from the PR branch scope
    - Delete the review artifacts from the PR branch and keep the cleanup focused on the testing harness.
    - **Depends**: 1.1
    - **Requirements**: 1
    - **Properties**: 1

  - [ ] 2.2 Update `testing/README.md` to remove stale artifact references and keep bootstrap guidance aligned with the harness architecture
    - Remove links/references to deleted files and keep the docs aligned with the cross-platform Taskfile bootstrap.
    - **Depends**: 2.1
    - **Requirements**: 1, 8
    - **Properties**: 1, 7

- [ ] 3. Replace hardcoded secret material with `.secrets`-aligned inputs
  - [ ] 3.1 Extend `testing/Taskfile.yml` setup to generate required harness secret files under `testing/.secrets`
    - Add idempotent generation for `splunk_admin_password` and `gitea_secret_key` alongside existing SSH and terminal secrets.
    - **Depends**: 1.1
    - **Requirements**: 2, 3
    - **Properties**: 2, 3

  - [ ] 3.2 Update inventories to consume generated Splunk admin secret inputs
    - Replace inline `splunk_admin_password` literals in environment group vars with env/file-driven resolution compatible with the generated secret files.
    - **Depends**: 3.1
    - **Requirements**: 2
    - **Properties**: 2

  - [ ] 3.3 Update git-server image/runtime configuration to consume generated secret inputs
    - Remove committed git-server secret literals from the image definition and inject the secret through env/file-driven runtime configuration.
    - **Depends**: 3.1
    - **Requirements**: 3
    - **Properties**: 3

- [ ] 4. Apply reviewed Ansible lifecycle conventions
  - [ ] 4.1 Move `ansible_python_interpreter` to play scope in the touched lifecycle playbooks
    - Update the directly reviewed lifecycle playbooks and analogous low-risk files.
    - **Depends**: 1.1
    - **Requirements**: 4
    - **Properties**: 4

  - [ ] 4.2 Convert built-in module usage to FQCN in touched playbooks
    - Make mechanical `ansible.builtin.*` updates in the reviewed/touched testing playbooks.
    - **Depends**: 4.1
    - **Requirements**: 5
    - **Properties**: 4

- [ ] 5. Parameterize Splunk artifact metadata
  - [ ] 5.1 Introduce shared Splunk version/build parameters in the harness bootstrap/configuration layer
    - Centralize current test artifact metadata in a shared location that downstream files can consume.
    - **Depends**: 1.1
    - **Requirements**: 6
    - **Properties**: 5

  - [ ] 5.2 Update touched scenario and inventory files to derive filenames/URLs from the shared parameters
    - Remove repeated literal version/build references in the reviewed paths while preserving current behavior.
    - **Depends**: 5.1
    - **Requirements**: 6
    - **Properties**: 5

  - [ ] 5.3 Pin the ttyd source checkout in the ansible-controller image build
    - Expose an explicit ttyd version and use it in the Dockerfile clone path for reproducible builds.
    - **Depends**: 1.1
    - **Requirements**: 7
    - **Properties**: 6

- [ ] 6. Preserve and explain the bootstrap architecture
  - [ ] 6.1 Keep Taskfile bootstrap host-side while updating docs/reviewer notes
    - Ensure the touched docs and reviewer-facing rationale distinguish host bootstrap from containerized runtime execution.
    - **Depends**: 2.2, 3.1, 3.3, 5.1, 5.3
    - **Requirements**: 8
    - **Properties**: 7

  - [ ] 6.2 Draft concise reviewer-facing responses for the addressed comments
    - Prepare short replies explaining each direct fix and the bootstrap/taskfile rationale where needed.
    - **Depends**: 6.1
    - **Requirements**: 8
    - **Properties**: 7

- [ ] 7. Prepare tooling and validation on the feature branch
  - [ ] 7.1 Check whether the containerized validation path already contains the required tools
    - Verify which linting and execution tools are already available through `molecule-runner` and identify any gaps in the current containerized validation path.
    - **Depends**: 2.2, 3.2, 3.3, 4.2, 5.2, 5.3
    - **Requirements**: 9, NF 3
    - **Properties**: 8

  - [ ] 7.2 Add or document container/image setup needed for missing validation tools
    - Capture the image, container, or documented workflow changes needed to make linting, rebuilds, and reruns possible on the feature branch before cherry-picking, without introducing a new `validate:*` task family or default host installs.
    - **Depends**: 7.1
    - **Requirements**: 9, NF 3
    - **Properties**: 8

  - [ ] 7.3 Run lint, rebuild, and representative rerun validation through the existing harness flow
    - Execute the available containerized lint commands, rebuild any touched image paths that require it, and run at least one representative harness rerun such as `task setup` or `task infra:test`.
    - **Depends**: 7.1, 7.2
    - **Requirements**: 9, NF 1, NF 2, NF 3
    - **Properties**: 2, 3, 4, 5, 6, 8

## Notes

- The `task`/bootstrap reviewer comment should be answered by clarifying that `Taskfile.yml` is the cross-platform bootstrap/orchestration layer and cannot be moved entirely into `molecule-runner` because it bootstraps the runner itself.
- Tooling/setup work is part of this spec because validation claims for the review fixes should be backed by runnable containerized lint/rebuild/rerun steps on the feature branch.
- Platform-native wrappers are a possible follow-up, not part of this PR unless review feedback makes them mandatory.
