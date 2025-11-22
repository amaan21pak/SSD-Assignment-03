#!/usr/bin/env bash
while true; do
sleep "$POLL_INTERVAL"
current_checksum="$(compute_checksum "$MONITOR_PATH")"


if [[ "$current_checksum" != "$last_checksum" ]]; then
log "Change detected in $MONITOR_PATH"


# Stage changes
if git add --all -- "$MONITOR_PATH"; then
log "Staged changes for $MONITOR_PATH"
else
log "Error: git add failed"
last_checksum="$current_checksum"
continue
fi


# Only commit if there are staged changes
if git diff --cached --quiet; then
log "No actual staged changes to commit."
else
commit_msg="Auto-commit: Changes detected in ${MONITOR_PATH} at $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
if git commit -m "$commit_msg"; then
log "Committed: $commit_msg"
else
log "Error: git commit failed"
last_checksum="$current_checksum"
continue
fi
fi


# Push changes
if git push "$GIT_REMOTE" "$GIT_BRANCH"; then
log "Pushed to ${GIT_REMOTE}/${GIT_BRANCH}"
email_subject="Repository Update Notification"
email_body="Changes were detected and pushed to ${GIT_REMOTE}/${GIT_BRANCH} for path: ${MONITOR_PATH}\n\nCommit message: ${commit_msg}\nTimestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"


if send_email "$email_subject" "$email_body"; then
log "Notification email sent to recipients: $RECIPIENTS"
else
log "Warning: Failed to send notification email."
fi


else
log "Error: git push failed"
# Attempt to capture push output for debugging
git_status_output=$(git status --porcelain --branch 2>&1 || true)
log "git status output: $git_status_output"
# Optionally try to pull and retry push (careful in collaborative settings)
if [[ "$AUTO_PULL_ON_PUSH_FAIL" == "true" ]]; then
log "AUTO_PULL_ON_PUSH_FAIL is true — attempting git pull --rebase and retry push"
if git pull --rebase "$GIT_REMOTE" "$GIT_BRANCH" && git push "$GIT_REMOTE" "$GIT_BRANCH"; then
log "Push succeeded after pull --rebase"
else
log "Push still failed after pull attempt"
fi
fi
fi


# Update last checksum
last_checksum="$current_checksum"
fi


done


# End: popd is intentionally not reached because loop is infinite. Add handling if you want to exit gracefully.
