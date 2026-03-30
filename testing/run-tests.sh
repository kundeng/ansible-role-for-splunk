#!/usr/bin/env bash
# Thin wrapper around Taskfile. Prefer running 'task' directly from testing/.
# Kept for backward compatibility.
#
# Usage:
#   ./testing/run-tests.sh setup         # same as: cd testing && task setup
#   ./testing/run-tests.sh infra:test    # same as: cd testing && task infra:test
#   MOLECULE_ENV=prod ./testing/run-tests.sh workflow:full
set -euo pipefail

cd "$(dirname "$0")"
exec task "$@"
