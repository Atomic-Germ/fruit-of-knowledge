#!/bin/bash
# filepath: /Users/caseyjparker/Repos/fruit-of-knowledge/scripts/update_time.sh

# Get the current date in YYYY-MM-DD format
CURRENT_DATE=$(date +%Y-%m-%d)

# Find all changed Markdown files in the src directory
CHANGED_FILES=$(git diff --name-only -- src/manuscript/**/*.md)

# Loop through each changed file
for FILE in $CHANGED_FILES; do
  if [[ -f "$FILE" ]]; then
    # Check if the file contains an "updated:" field in the front matter
    if grep -q "^updated:" "$FILE"; then
      # Update the "updated:" field with the current date
      sed -i '' "s/^updated: .*/updated: $CURRENT_DATE/" "$FILE"
      echo "Updated 'updated:' field in $FILE"
    else
      # Add the "updated:" field if it doesn't exist
      sed -i '' "1,/^---$/s/^---$/updated: $CURRENT_DATE\n---/" "$FILE"
      echo "Added 'updated:' field to $FILE"
    fi
  fi
done