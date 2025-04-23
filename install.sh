#!/bin/bash

# Markdown Memory Server Installer
# This script installs the necessary dependencies and sets up the tool

echo "Installing Markdown Memory Server..."
echo "===================================="

# Check if R is installed
if ! command -v R >/dev/null 2>&1; then
  echo "Error: R is not installed. Please install R first."
  exit 1
fi

# Create installation directory
INSTALL_DIR="$HOME/.markdown-memory-server"
mkdir -p "$INSTALL_DIR"

# Copy the main script
cp render_folder.R "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/render_folder.R"

# Install required R packages
echo "Installing required R packages..."
R --quiet -e "if(!require('rmarkdown')) install.packages('rmarkdown', repos='https://cloud.r-project.org/')"
R --quiet -e "if(!require('httpuv')) install.packages('httpuv', repos='https://cloud.r-project.org/')"
R --quiet -e "if(!require('servr')) install.packages('servr', repos='https://cloud.r-project.org/')"

# Create a symlink to the script in /usr/local/bin if possible
if [ -d "/usr/local/bin" ] && [ -w "/usr/local/bin" ]; then
  echo "Creating symlink in /usr/local/bin..."
  sudo ln -sf "$INSTALL_DIR/render_folder.R" /usr/local/bin/markdown-server
  echo "You can now run the tool using: markdown-server /path/to/folder"
else
  echo "Could not create symlink in /usr/local/bin (permission denied)."
  echo "To use the tool, run: $INSTALL_DIR/render_folder.R /path/to/folder"
fi

echo ""
echo "Installation complete!"
echo "======================"
echo ""
echo "Usage:"
if [ -d "/usr/local/bin" ] && [ -w "/usr/local/bin" ]; then
  echo "  markdown-server /path/to/markdown/folder [port]"
else
  echo "  $INSTALL_DIR/render_folder.R /path/to/markdown/folder [port]"
  echo ""
  echo "You can create an alias in your shell configuration:"
  echo "  alias markdown-server='$INSTALL_DIR/render_folder.R'"
fi
echo ""
echo "Once the server is running, visit http://localhost:8000 in your browser."
