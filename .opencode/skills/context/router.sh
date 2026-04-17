#!/usr/bin/env bash
#############################################################################
# Context Manager Skill Router
# Routes to context management operations with proper path resolution
#############################################################################

set -e

# SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Show help
show_help() {
  cat << 'HELP'
📚 Context Manager Skill
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Usage: router.sh [OPERATION] [OPTIONS]

OPERATIONS:
  discover [target]             Find context files by topic or path
  fetch [libraries] [topics]    Fetch external documentation
  harvest [source]              Extract context from summary files
  extract [file] [what]         Extract specific information from context
  compress [target] [size]      Compress large context files
  organize [target]             Reorganize context by concern
  cleanup [target] [days]       Remove stale or temporary files
  process [goal] [scope]        Guided workflow for context processing
  help                          Show this help message

EXAMPLES:
  ./router.sh discover authentication
  ./router.sh fetch "Drizzle ORM" "modular schemas"
  ./router.sh harvest ANALYSIS.md
  ./router.sh extract code-quality.md "naming conventions"
  ./router.sh compress .opencode/context/ 100KB
  ./router.sh organize .opencode/context/
  ./router.sh cleanup .tmp/ 7
  ./router.sh process "organize authentication context" .opencode/context/

FEATURES:
  ✓ Discover context files efficiently
  ✓ Fetch external documentation
  ✓ Extract and harvest context
  ✓ Compress large files
  ✓ Organize by concern
  ✓ Clean up stale files
  ✓ Guided workflows

For detailed documentation, see: .opencode/skills/context/SKILL.md
HELP
}

# If no arguments, show help
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

# Handle help
if [ "$1" = "help" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

# Find project root
find_project_root() {
    local dir
    dir="$(pwd)"
    while [ "$dir" != "/" ]; do
        if [ -d "$dir/.git" ] || [ -f "$dir/package.json" ]; then
            echo "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    pwd
    return 1
}

# PROJECT_ROOT="$(find_project_root)"

# Route to appropriate operation
OPERATION="$1"
shift

case "$OPERATION" in
    discover)
        echo "📍 DISCOVER: Finding context files..."
        echo "Target: $*"
        echo "See .opencode/skills/context/SKILL.md for full documentation"
        ;;
    fetch)
        echo "📥 FETCH: Retrieving external documentation..."
        echo "Libraries: $*"
        echo "See .opencode/skills/context/SKILL.md for full documentation"
        ;;
    harvest)
        echo "🌾 HARVEST: Extracting context from summaries..."
        echo "Source: $*"
        echo "See .opencode/skills/context/SKILL.md for full documentation"
        ;;
    extract)
        echo "🔍 EXTRACT: Pulling key information..."
        echo "Target: $*"
        echo "See .opencode/skills/context/SKILL.md for full documentation"
        ;;
    compress)
        echo "🗜️  COMPRESS: Reducing file sizes..."
        echo "Target: $*"
        echo "See .opencode/skills/context/SKILL.md for full documentation"
        ;;
    organize)
        echo "📂 ORGANIZE: Restructuring context..."
        echo "Target: $*"
        echo "See .opencode/skills/context/SKILL.md for full documentation"
        ;;
    cleanup)
        echo "🧹 CLEANUP: Removing stale files..."
        echo "Target: $*"
        echo "See .opencode/skills/context/SKILL.md for full documentation"
        ;;
    process)
        echo "⚙️  PROCESS: Guided workflow..."
        echo "Goal: $*"
        echo "See .opencode/skills/context/SKILL.md for full documentation"
        ;;
    *)
        echo "❌ Unknown operation: $OPERATION"
        echo ""
        show_help
        exit 1
        ;;
esac
