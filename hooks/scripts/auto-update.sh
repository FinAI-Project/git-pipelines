#!/usr/bin/env bash

LAST_CHECK_FILE="/tmp/githooks-auto-update-check"
LAST_CHECK_TIME=0
if [ -f "$LAST_CHECK_FILE" ]; then
    LAST_CHECK_TIME=$(cat "$LAST_CHECK_FILE")
fi

CURRENT_TIME=$(date +%s)
PASSED_TIME=$((CURRENT_TIME - LAST_CHECK_TIME))
COLDDOWN_TIME=$((60 * 60))
if [ $PASSED_TIME -gt $COLDDOWN_TIME ]; then
    curl -fsSL https://github.com/FinAI-Project/git-pipelines/raw/main/install.sh | bash
fi
echo -n "$CURRENT_TIME" > "$LAST_CHECK_FILE"