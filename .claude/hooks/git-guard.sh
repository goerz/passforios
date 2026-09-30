#!/bin/bash
# PreToolUse hook for Bash: blocks commands that would skip or replace the git hooks in
# .githooks, which keep personal information out of this public repository (CLAUDE.md,
# "Personal information"). Exit code 2 refuses the command and tells Claude why.
input=$(cat)
command=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2> /dev/null) || command=$input
[ -n "$command" ] || command=$input
refuse() {
    echo "Blocked: $1. The git hooks in .githooks keep personal information out of this public repository and must not be bypassed; only the user may do that, by hand (CLAUDE.md, \"Personal information\")." >&2
    exit 2
}
case "$command" in
    *--no-verify*) refuse "--no-verify skips the pre-commit, commit-msg, and pre-push checks" ;;
esac
if printf '%s' "$command" | grep -qE 'core\.hooks[Pp]ath' &&
    ! printf '%s' "$command" | grep -qE '^git config core\.hooksPath \.githooks$'; then
    refuse "changing core.hooksPath would disable the checks"
fi
# Quoted text (a commit message) may mention -n.
unquoted=$(printf '%s' "$command" | sed -E "s/\"[^\"]*\"//g; s/'[^']*'//g")
if printf '%s' "$unquoted" | grep -qE '(^|[;&|[:space:]])git([[:space:]]+-[^[:space:]]+)*[[:space:]]+commit([[:space:]]+[^[:space:]]+)*[[:space:]]+-[A-Za-z]*n[A-Za-z]*([[:space:]]|$)'; then
    refuse "git commit -n skips the pre-commit and commit-msg checks"
fi
exit 0
