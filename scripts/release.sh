#!/usr/bin/env bash
set -e

COMMAND="${1:-}"

case "$COMMAND" in
  changelog)
    # Read version
    if [[ ! -f VERSION ]]; then
      echo "Error: VERSION file not found" >&2
      exit 1
    fi
    VERSION=$(cat VERSION | tr -d ' \t\n\r')
    DATE=$(date +%Y-%m-%d)

    # Validate CHANGELOG has [Unreleased]
    if ! grep -q "^## \[Unreleased\]" CHANGELOG.md; then
      echo "Error: No [Unreleased] section found in CHANGELOG.md" >&2
      exit 1
    fi

    # Validate tag doesn't exist
    if git rev-parse "v${VERSION}" >/dev/null 2>&1; then
      echo "Error: Tag v${VERSION} already exists" >&2
      exit 1
    fi

    # Replace [Unreleased] with version
    sed -i "s/^## \[Unreleased\]/## [v${VERSION}] - ${DATE}/" CHANGELOG.md

    # Update VERSION committed
    git add VERSION CHANGELOG.md
    git commit -m "Release v${VERSION}"

    # Create git tag
    git tag "v${VERSION}"
    echo "Release v${VERSION} prepared and tagged"
    ;;
  *)
    echo "Usage: $0 changelog"
    echo ""
    echo "Commands:"
    echo "  changelog   Generate changelog entry and create release tag"
    exit 1
    ;;
esac