#!/bin/bash

# Script to update backend URLs from Heroku to local development server
# Replaces https://alibaba-backend.herokuapp.com with http://localhost:5000

echo "Updating backend URLs from Heroku to local development server..."
echo "This will replace https://alibaba-backend.herokuapp.com with http://localhost:5000"

# Files to update
FILES_TO_UPDATE=(
    "index.html"
    "signin.html"
    "signUp.html"
    "shoppingcart.html"
    "openproduct.html"
    "electronics.html"
    "electronics-subcategory.html"
    "script/electronics.js"
)

# Backup directory
BACKUP_DIR="backend-url-backup-$(date +%Y%m%d-%H%M%s)"
mkdir -p "$BACKUP_DIR"

echo "Creating backup in $BACKUP_DIR/"

# Process each file
for file in "${FILES_TO_UPDATE[@]}"; do
    if [[ -f "$file" ]]; then
        echo "Processing $file..."

        # Create backup
        cp "$file" "$BACKUP_DIR/"

        # Replace the URL
        sed -i '' 's|https://alibaba-backend.herokuapp.com|http://localhost:5000|g' "$file"

        echo "  ✓ Updated $file"
    else
        echo "  ⚠ Warning: $file not found"
    fi
done

echo ""
echo "Update complete! Backups are stored in: $BACKUP_DIR"
echo ""
echo "To revert changes, copy files from the backup directory:"
echo "  cp $BACKUP_DIR/* ."
echo ""
echo "Next steps:"
echo "1. Start your local backend: cd backend && npm run dev"
echo "2. Start the frontend server: python -m http.server 8080"
echo "3. Visit http://localhost:8080 in your browser"