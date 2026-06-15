#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 2 || $# -gt 3 ]]; then
  echo "Usage: $0 <feature-branch> <commit-subject> [base-branch]"
  exit 1
fi

FEATURE_BRANCH="$1"
COMMIT_SUBJECT="$2"
BASE_BRANCH="${3:-main}"
TAG_NAME="merged/${FEATURE_BRANCH}"
FEATURE_TIP="$(git rev-parse "$FEATURE_BRANCH")"

git status --short

if [[ -n "$(git status --short)" ]]; then
  echo "Worktree must be clean before squash merge"
  exit 1
fi

git checkout "$BASE_BRANCH"
git merge --squash "$FEATURE_BRANCH"
git commit -m "$COMMIT_SUBJECT" -m "Squash-Merged-From: $FEATURE_BRANCH"
git tag -a "$TAG_NAME" "$FEATURE_TIP" -m "Preserve merged feature branch tip"
git branch -D "$FEATURE_BRANCH"
git status --short --branch
git log --oneline --decorate -6
