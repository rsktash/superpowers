#!/bin/bash
# Sync version from package.json to .claude-plugin/marketplace.json

VERSION=$(node -p "require('./package.json').version")
MARKETPLACE=".claude-plugin/marketplace.json"

if [ -f "$MARKETPLACE" ]; then
  # Update version in marketplace.json using node for reliable JSON manipulation
  node -e "
    const fs = require('fs');
    const m = JSON.parse(fs.readFileSync('$MARKETPLACE', 'utf8'));
    m.plugins[0].version = '$VERSION';
    fs.writeFileSync('$MARKETPLACE', JSON.stringify(m, null, 2) + '\n');
  "
  git add "$MARKETPLACE"
fi
