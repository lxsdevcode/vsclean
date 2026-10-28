#!/usr/bin/env bash
set -euo pipefail

BASE="$HOME/.vscode-server/bin"
DRY_RUN=0

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTION]

Clean up obsolete VS Code Server installations.

Options:
  --dry-run    Preview deletions without removing any files.
  --help, -h   Display this help message.

Examples:
  $(basename "$0") --dry-run
  $(basename "$0")
EOF
}

case "${1:-}" in
    --dry-run)
        DRY_RUN=1
        ;;
    --help|-h)
        usage
        exit 0
        ;;
    "")
        ;;
    *)
        echo "Error: Unknown option: $1" >&2
        usage >&2
        exit 2
        ;;
esac

if [[ ! -d "$BASE" ]]; then
    echo "Error: VS Code Server directory not found: $BASE" >&2
    exit 1
fi

# Identify version directories referenced by running processes.
ACTIVE_VERSIONS=$(
    ps -u "$(id -u)" -o args= |
        grep -oE "$BASE/[a-f0-9]{40}" |
        sort -u || true
)

FOUND=0

for DIR in "$BASE"/*; do
    [[ -d "$DIR" ]] || continue
    VERSION="${DIR##*/}"

    # Only process directories with a recognized version identifier.
    if [[ ! "$VERSION" =~ ^[a-f0-9]{40}$ ]]; then
        echo "Skipped (unrecognized directory): $VERSION"
        continue
    fi

    FOUND=1

    # Preserve versions referenced by running processes.
    if printf '%s\n' "$ACTIVE_VERSIONS" |
        grep -Fqx -- "$DIR"; then
        echo "Preserved (active): $VERSION"
        continue
    fi

    if [[ "$DRY_RUN" -eq 1 ]]; then
        echo "[DRY RUN] Would remove: $VERSION"
    else
        echo "Removing obsolete version: $VERSION"
        rm -rf -- "$DIR"
    fi
done

if [[ "$FOUND" -eq 0 ]]; then
    echo "No recognized VS Code Server versions found."
elif [[ "$DRY_RUN" -eq 1 ]]; then
    echo "Dry run completed. No files were deleted."
else
    echo "Cleanup completed."
fi
