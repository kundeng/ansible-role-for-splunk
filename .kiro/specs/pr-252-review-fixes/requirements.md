# Requirements Document

## Introduction

This spec covers the review-driven updates needed to address the open comments on PR #252. The requirements are organized to map closely to reviewer concerns so the resulting design, tasks, validation, and reviewer responses can be traced directly back to the PR discussion.

## Glossary

- **Testing harness**: The `testing/` subtree that provides Docker images, Taskfile orchestration, and Molecule scenarios.
- **PR branch**: The `pr/testing-harness` branch backing upstream PR #252.
- **Feature branch**: The local development branch where spec work, validation work, and non-PR-only artifacts may be kept before cherry-picking tested fixes.
- **Bootstrap layer**: The host-side workflow that prepares secrets, images, networks, tooling, and artifacts before Molecule execution.
- **Runtime layer**: The containerized Ansible/Molecule execution path.
- **Lab secrets**: Generated files under `testing/.secrets` used only for local or test harness operation.

## Requirements

### Requirement 1: Remove non-project review artifacts from the PR diff

**User Story:** As an upstream reviewer, I want the PR diff to exclude assistant/progress artifacts, so that I only review project code and documentation relevant to the testing harness.

#### Acceptance Criteria

1. WHEN the PR branch is prepared for review, THE testing harness SHALL no longer include `testing/CLAUDE.md` or `testing/PROGRESS.md`.
2. WHEN the testing harness README references removed review artifacts, THE documentation SHALL be updated so no stale references remain.
3. WHEN branch-specific repo metadata is needed for feature-branch workflow support, THE metadata SHALL remain outside the PR branch scope.

### Requirement 2: Replace hardcoded Splunk admin credentials with `.secrets`-compatible inputs

**User Story:** As a reviewer, I want the harness to stop hardcoding test passwords, so that the PR does not normalize committed credentials while preserving local usability.

#### Acceptance Criteria

1. WHEN the harness setup runs, THE bootstrap layer SHALL support generating `testing/.secrets/splunk_admin_password` alongside the existing generated secrets.
2. WHEN environment inventories need `splunk_admin_password`, THE inventories SHALL resolve the value from environment-driven input compatible with the generated `.secrets` workflow instead of a hardcoded literal.
3. IF the required secret file or environment value is absent at runtime, THEN the harness SHALL direct the user back to the setup/bootstrap step or equivalent remediation.

### Requirement 3: Replace hardcoded git-server secret material with `.secrets`-compatible inputs

**User Story:** As a reviewer, I want the git-server secret configuration to avoid committed literals, so that the harness follows the same secret-handling approach as the rest of the local setup.

#### Acceptance Criteria

1. WHEN the harness setup runs, THE bootstrap layer SHALL support generating `testing/.secrets/gitea_secret_key` alongside the existing generated secrets.
2. WHEN the git-server container needs `GITEA__security__SECRET_KEY`, THE value SHALL be injected from environment or generated secret input rather than a committed literal in the image definition.
3. WHEN the git-server secret is supplied at runtime, THE harness SHALL keep the existing local usability model based on generated `.secrets` content or explicit environment overrides.

### Requirement 4: Move lifecycle playbook interpreter overrides to play scope

**User Story:** As a reviewer, I want Docker lifecycle playbooks to use the approved interpreter override pattern, so that the harness avoids fragile `set_fact` usage for play-level configuration.

#### Acceptance Criteria

1. WHEN a touched lifecycle playbook requires `ansible_python_interpreter`, THE playbook SHALL define it at play scope instead of via `set_fact`.
2. WHEN directly analogous low-risk lifecycle playbooks use the same reviewed pattern, THE update SHALL be applied consistently in those files.

### Requirement 5: Use FQCNs for built-in modules in touched playbooks

**User Story:** As a reviewer, I want touched testing playbooks to use fully qualified built-in module names, so that the harness follows upstream Ansible style where the PR is already making edits.

#### Acceptance Criteria

1. WHEN touched testing playbooks use built-in Ansible modules, THE playbooks SHALL use `ansible.builtin.*` FQCN forms in those edited locations.
2. WHEN FQCN conversion would require unrelated broad churn, THEN the PR SHALL limit the update to the touched files and reviewed mechanical equivalents.

### Requirement 6: Parameterize Splunk test artifact version and build metadata

**User Story:** As a reviewer, I want repeated hardcoded Splunk artifact metadata removed, so that the harness derives filenames and URLs from shared values instead of scattered literals.

#### Acceptance Criteria

1. WHEN the harness downloads or references Splunk artifacts, THE version and build metadata SHALL come from shared parameters rather than repeated literals across tasks and scenario files.
2. WHEN touched files derive filenames, paths, or URLs from the shared parameters, THE derived values SHALL remain internally consistent across Taskfile, inventories, and scenarios.
3. WHEN parameterization is introduced, THE documented harness flow SHALL remain usable without requiring users to edit multiple files by hand.

### Requirement 7: Pin the ttyd source checkout for reproducible controller image builds

**User Story:** As a reviewer, I want the ttyd build source pinned to an explicit version, so that the controller image build is reproducible and not tied to an unpinned repository default.

#### Acceptance Criteria

1. WHEN the ansible-controller image clones the ttyd source repository, THE build SHALL target an explicit version or tag rather than an unpinned default branch checkout.
2. WHEN the ttyd source version is defined, THE Dockerfile SHALL make the selected version visible and easy to update intentionally.

### Requirement 8: Preserve the Taskfile bootstrap architecture while clarifying runtime container responsibilities

**User Story:** As a maintainer responding to review, I want to clarify why bootstrap remains host-side while runtime execution stays containerized, so that the framework remains cross-platform and avoids circular bootstrapping.

#### Acceptance Criteria

1. WHILE the harness bootstrap is responsible for building `molecule-runner`, THE implementation SHALL preserve a host-side cross-platform orchestration layer rather than moving all bootstrap steps into the runner container.
2. WHEN reviewer-facing documentation or responses are prepared, THE explanation SHALL distinguish the bootstrap/orchestration layer from the containerized runtime/test execution layer.
3. IF future platform-specific wrappers are considered, THEN they SHALL remain out of scope for this PR unless a current blocking review comment requires them.

### Requirement 9: Define the validation tooling and rerun expectations needed to verify review fixes

**User Story:** As a maintainer, I want the spec to explicitly call out the tooling and rerun prerequisites needed for validation, so that implementation work does not stop short of rebuild, lint, or representative rerun due to missing local setup assumptions.

#### Acceptance Criteria

1. WHEN the spec describes validation for this PR, THE design and tasks SHALL name the expected linting and rerun commands for the touched harness paths.
2. WHEN the harness validation path runs through `Taskfile.yml` and `molecule-runner`, THE spec SHALL treat host prerequisites as the tools needed to launch that containerized flow rather than assuming host-side Ansible or lint tooling.
3. WHEN linting or additional checks require tools not currently present in the containerized validation path, THEN the tasks SHALL treat that as container/tool-image setup or documentation work rather than defaulting to host-side installation.
4. WHEN validation cannot be completed because containerized tooling is missing, THEN the spec SHALL treat the tooling/setup gap as work to address or document rather than silently treating the implementation as fully verified.

## Non-Functional

**NF 1**: Review-driven changes SHALL remain minimal, scoped to the review comments, and avoid unrelated refactors.

**NF 2**: The harness SHALL remain usable on macOS, Linux, and Windows hosts to the extent already implied by the Taskfile-based bootstrap approach.

**NF 3**: Updated docs, validation notes, and failure messages SHALL direct users to the existing Taskfile/bootstrap flow or clearly documented containerized tool setup rather than undocumented manual steps.

## Out of Scope

- Adding the future `day2_apps` Molecule scenario.
- Reworking the entire bootstrap model into platform-specific wrappers in this PR.
- Broad non-review refactors outside the touched `testing/` harness files.
- Keeping feature-branch-only spec artifacts in the PR branch.
