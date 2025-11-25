#!/bin/bash
set -euo pipefail

# Only run this in Claude Code web environment
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

cd "$CLAUDE_PROJECT_DIR"

echo "🔧 Setting up Ruby environment for Claude Code web..."

# Temporarily switch to Ruby 3.3.6 (available in container)
echo "3.3.6" > .ruby-version

# Set Ruby version via rbenv
export PATH="/opt/rbenv/bin:/opt/rbenv/shims:$PATH"
eval "$(rbenv init -)"
rbenv local 3.3.6

# Verify Ruby version
echo "✓ Using Ruby $(ruby --version)"

# Install bundler if not present
if ! command -v bundle &> /dev/null; then
  gem install bundler --no-document
fi

# Install dependencies
echo "📦 Installing gems..."
bundle check || bundle install

# Prepare database
echo "🗄️  Preparing database..."
bin/rails db:prepare

# Mark .ruby-version as skip-worktree so local changes don't show in git status
echo "🔒 Marking .ruby-version as skip-worktree..."
git update-index --skip-worktree .ruby-version || true

echo "✅ Setup complete! Ruby 3.3.6 is active (3.4.4 preserved in repo)"
