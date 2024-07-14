#!/bin/bash

SEARCH_STRING="revert"

# search commit messages
if git log --grep="$SEARCH_STRING" -q; then
    echo "Found '$SEARCH_STRING' in commit messages"
    exit 1
fi

# search file contents in each commit
for commit in $(git rev-list --all); do
    if git grep -q "$SEARCH_STRING" "$commit"; then
        echo "Found '$SEARCH_STRING' in commit $commit"
        exit 1
    fi
done

echo "No sensitive information found in commit history."
