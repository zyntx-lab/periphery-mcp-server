#!/bin/bash

echo "Installing Periphery MCP Server locally for testing..."
echo ""

# Install binary
echo "1. Installing binary to /usr/local/bin/..."
sudo cp .build/release/periphery-mcp-server /usr/local/bin/
sudo chmod +x /usr/local/bin/periphery-mcp-server

echo "2. Binary installed!"
echo ""

# Check Claude Desktop config
CLAUDE_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"

echo "3. Configuring Claude Desktop..."
mkdir -p "$HOME/Library/Application Support/Claude"

if [ -f "$CLAUDE_CONFIG" ]; then
    echo "   Backing up existing config to claude_desktop_config.json.backup..."
    cp "$CLAUDE_CONFIG" "$CLAUDE_CONFIG.backup"
fi

# Write config
cat > "$CLAUDE_CONFIG" << 'EOF'
{
  "mcpServers": {
    "periphery": {
      "command": "/usr/local/bin/periphery-mcp-server"
    }
  }
}
EOF

echo "   Claude Desktop config updated!"
echo ""

echo "✅ Installation complete!"
echo ""
echo "Next steps:"
echo "1. Restart Claude Desktop (Cmd+Q then reopen)"
echo "2. In Claude Desktop, try: 'Check if Periphery is installed'"
echo "3. Or try: 'What version of Periphery do I have?'"
echo ""
echo "The server has 7 tools available:"
echo "  - check_periphery_installed"
echo "  - get_periphery_version"
echo "  - scan_project"
echo "  - scan_with_config"
echo "  - analyze_unused_imports"
echo "  - find_redundant_public"
echo "  - scan_with_options"
