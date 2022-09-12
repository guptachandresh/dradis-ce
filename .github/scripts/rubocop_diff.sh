#!/bin/bash

set -e

ALLOWED_WARNINGS=0
warning_count=`git diff-tree -r --no-commit-id --name-only head origin/develop | xargs rubocop --format simple | grep "offenses detected\|offense detected" | cut -d " " -f4`
files_inspected=`git diff-tree -r --no-commit-id --name-only head origin/develop | xargs rubocop --format simple | grep "files inspected" | cut -d " " -f1`
# warning_count=`git ls-files -m | xargs ls -1 2>/dev/null | grep '\.rb$' | xargs rubocop --format simple | grep "offenses detected\|offense detected" | cut -d " " -f4`
# files_inspected=`git ls-files -m | xargs ls -1 2>/dev/null | grep '\.rb$' | xargs rubocop --format simple | grep "files inspected\|file inspected" | cut -d " " -f1`

if [ $warning_count -gt $ALLOWED_WARNINGS ]
then
  echo -e "❌ $files_inspected file(s) inspected"
  echo -e "❌ $warning_count outstanding rubocop warning(s)"
  echo -e "❓Try running 'git diff-tree -r --no-commit-id --name-only head origin/develop | xargs rubocop -a' to autocorrect any auto-correctable errors"
  exit 1
else
  echo "✅Clean code! No outstanding rubocop warnings introduced in changed files"
  echo "✅Great job ಠ.ಠ"
  exit 0
fi