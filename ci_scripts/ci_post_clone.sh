#!/bin/sh

# ci_post_clone.sh
# Runs automatically after Xcode Cloud clones the repo.
# Generates Config.plist from environment variables set in Xcode Cloud.
#
# Set these in Xcode Cloud → Workflow → Environment → Secret Variables:
#   ANTHROPIC_API_KEY
#   SUPABASE_URL
#   SUPABASE_ANON_KEY

set -e

echo "▶ Generating Config.plist from environment variables..."

PLIST_PATH="$CI_WORKSPACE/Twin Flame Union/Config.plist"

/usr/libexec/PlistBuddy -c "Add :ANTHROPIC_API_KEY string ${ANTHROPIC_API_KEY}" "$PLIST_PATH" 2>/dev/null || \
/usr/libexec/PlistBuddy -c "Set :ANTHROPIC_API_KEY ${ANTHROPIC_API_KEY}" "$PLIST_PATH"

/usr/libexec/PlistBuddy -c "Add :SUPABASE_URL string ${SUPABASE_URL}" "$PLIST_PATH" 2>/dev/null || \
/usr/libexec/PlistBuddy -c "Set :SUPABASE_URL ${SUPABASE_URL}" "$PLIST_PATH"

/usr/libexec/PlistBuddy -c "Add :SUPABASE_ANON_KEY string ${SUPABASE_ANON_KEY}" "$PLIST_PATH" 2>/dev/null || \
/usr/libexec/PlistBuddy -c "Set :SUPABASE_ANON_KEY ${SUPABASE_ANON_KEY}" "$PLIST_PATH"

echo "✓ Config.plist written successfully."
