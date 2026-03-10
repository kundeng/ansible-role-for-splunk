# Requirements Document

## Introduction

This spec covers the review-driven updates needed for PR #252 so the testing harness remains acceptable to upstream reviewers while preserving the cross-platform bootstrap approach and the existing `testing/.secrets` workflow.

## Glossary

- **Testing harness**: The `testing/` subtree that provides Docker images, Taskfile orchestration, and Molecule scenarios.
- **PR branch**: The `pr/testing-harness` branch backing upstream PR #252.
- **Current branch**: The local development branch outside the PR branch where root `AGENTS.md` should exist.
- **Bootstrap layer**: The host-side workflow that prepares secrets, images, networks, and artifacts before Molecule execution.
- **Runtime layer**: The containerized Ansible/Molecule execution path.
- **Lab secrets**: Generated files under `testing/.secrets` used only for local or test harness operation.

## Requirements

### Requirement 1: Remove non-PR artifacts from the testing harness

**User Story:** As an upstream reviewer, I want the PR diff to exclude AI-assistant and progress-tracking artifacts, so that the testing harness PR stays focused on reviewable project code and docs.

#### Acceptance Criteria

1. WHEN the PR branch is updated, THE testing harness SHALL no longer include `testing/CLAUDE.md` or `testing/PROGRESS.md`.
2. WHEN the testing harness README references removed artifacts, THE documentation SHALL be updated so no stale links remain.
3. WHEN the current non-PR branch is updated, THE repository root SHALL contain an `AGENTS.md` file with the Windloop guidance snippet.

### Requirement 2: Replace hardcoded harness credentials with `.secrets`-aligned inputs

**User Story:** As a harness maintainer, I want test-only credentials and secret values to come from generated or injected inputs, so that the PR avoids hardcoded credentials while preserving local usability.

#### Acceptance Criteria

1. WHEN the harness setup runs, THE bootstrap layer SHALL support generating any required test secret files under `testing/.secrets` alongside existing generated secrets.
2. WHEN environment inventories need `splunk_admin_password`, THE inventories SHALL resolve the value from environment-driven input compatible with the generated `.secrets` workflow instead of a hardcoded literal.
3. WHEN the git-server image needs a secret key, THE image or its runtime configuration SHALL resolve the value from environment-driven input compatible with the generated `.secrets` workflow instead of a hardcoded literal.
4. IF the required generated secret files are missing, THEN the harness SHALL fail with actionable guidance that points users back to the setup/bootstrap step.

### Requirement 3: Fix reviewed Ansible lifecycle patterns

**User Story:** As a reviewer, I want the testing playbooks to use the approved Ansible conventions, so that the harness follows upstream style and avoids fragile task behavior.

#### Acceptance Criteria

1. WHEN Docker lifecycle playbooks require `ansible_python_interpreter`, THE playbooks SHALL define it at play scope instead of via `set_fact`.
2. WHEN testing playbooks use built-in Ansible modules, THE playbooks SHALL use `ansible.builtin.*` FQCN forms in touched files.
3. WHEN a reviewed convention occurs in directly analogous lifecycle playbooks, THE update SHALL be applied consistently where low-risk and mechanical.

### Requirement 4: Parameterize Splunk test artifact metadata

**User Story:** As a harness maintainer, I want Splunk version and build identifiers centralized, so that reviewers do not see repeated hardcoded test artifact metadata and future updates require fewer edits.

#### Acceptance Criteria

1. WHEN the harness downloads or references Splunk artifacts, THE version and build metadata SHALL be parameterized from a shared source rather than repeated literals across tasks and scenario files.
2. WHEN scenario files need artifact filenames or URLs, THE values SHALL remain internally consistent with the shared version/build parameters.
3. WHEN the parameterization is introduced, THE existing documented harness flow SHALL remain usable without requiring users to edit multiple files.

### Requirement 5: Keep bootstrap cross-platform while containerizing runtime execution

**User Story:** As a maintainer, I want to respond to the review about workstation dependencies without introducing a shell-only bootstrap, so that the framework stays cross-platform and avoids circular dependence on the runner image it builds.

#### Acceptance Criteria

1. WHILE the harness bootstrap is responsible for building `molecule-runner`, THE implementation SHALL preserve a host-side cross-platform orchestration layer rather than moving all bootstrap steps into the runner container.
2. WHEN reviewer-facing documentation or responses are prepared, THE explanation SHALL distinguish the cross-platform bootstrap/orchestration layer from the containerized runtime/test execution layer.
3. IF future platform-specific wrappers are considered, THEN they SHALL remain out of scope for this PR unless required to resolve a current blocking review.

## Non-Functional

**NF 1**: Review-driven changes SHALL be minimal, scoped to the review comments, and avoid unrelated refactors.

**NF 2**: The harness SHALL remain usable on macOS, Linux, and Windows hosts to the extent already implied by the Taskfile-based bootstrap approach.

**NF 3**: Updated docs and failure messages SHALL direct users to existing setup/bootstrap commands rather than introducing undocumented manual steps.

## Out of Scope

- Adding the future `day2_apps` Molecule scenario.
- Reworking the entire bootstrap model into platform-specific wrappers in this PR.
- Broad non-review refactors outside the touched `testing/` harness files and the required root `AGENTS.md` on the current branch.
