#!/usr/bin/env bash
# shellcheck disable=SC2034  # Shared fixtures are used by the .bats files that load this helper.

PROJECT_ROOT="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." && pwd)"
FIXTURES_DIR="$PROJECT_ROOT/tests/fixtures"
SEP=$'\x1f'
GLYPH_VIM=$'\ue62b'
GLYPH_SHELL=$'\uf489'
GLYPH_DOCKER=$'\uf308'
GLYPH_NODE=$'\ue718'

bats_require_minimum_version 1.5.0

load_modules() {
  local module
  for module in constants logging strings mappings_parser format_escape format_builder; do
    # shellcheck source=/dev/null
    source "$PROJECT_ROOT/scripts/${module}.sh"
  done
}
