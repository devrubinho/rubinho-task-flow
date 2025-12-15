#!/bin/bash

# Rubinho Task Flow - Git Cleanup
# Remove tracked files that should be in .gitignore

echo "🧹 Removing Rubinho Task Flow files from git tracking..."
echo ""

git rm --cached -r .claude/ 2>/dev/null
git rm --cached -r .cursor/rules/ 2>/dev/null
git rm --cached -r .task-flow/ 2>/dev/null
git rm --cached rubinho-task-flow.sh 2>/dev/null
git rm --cached CLAUDE.md 2>/dev/null

echo ""
echo "✅ Files removed from git tracking!"
echo ""
echo "Next steps:"
echo "1. Check: git status"
echo "2. Commit: git commit -m 'chore: remove AI tooling files from tracking'"
echo ""
