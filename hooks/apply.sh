#!/bin/bash
HOOK_NAMES="post-commit"
for HOOK in $HOOK_NAMES; do
    ln -s -f ../../hooks/$HOOK .git/hooks/$HOOK
done
