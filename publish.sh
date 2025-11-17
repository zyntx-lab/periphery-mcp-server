#!/bin/bash

# Publishing script for Periphery MCP Server
# This creates a GitHub release and prepares for MCP registry submission

set -e

VERSION="1.0.0"
REPO="zyntx-lab/periphery-mcp-server"
BINARY=".build/release/periphery-mcp-server"

echo "🚀 Publishing Periphery MCP Server v${VERSION}"
echo ""

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed."
    echo "Install it with: brew install gh"
    exit 1
fi

# Check if binary exists
if [ ! -f "$BINARY" ]; then
    echo "❌ Binary not found. Building release version..."
    swift build -c release
fi

# Calculate SHA-256
echo "📋 Calculating SHA-256 hash..."
SHA256=$(openssl dgst -sha256 "$BINARY" | awk '{print $2}')
echo "   SHA-256: $SHA256"
echo ""

# Create or update server.json with correct hash
echo "📝 Updating server.json with hash..."
cat > server.json << EOF
{
  "\$schema": "https://registry.modelcontextprotocol.io/schema/v1/server.schema.json",
  "name": "io.github.zyntx-lab/periphery-mcp-server",
  "displayName": "Periphery Code Audit",
  "description": "Swift code analysis with Periphery - detect unused code and improve code quality",
  "homepage": "https://github.com/zyntx-lab/periphery-mcp-server",
  "license": "MIT",
  "vendor": {
    "name": "Zyntx Lab",
    "url": "https://github.com/zyntx-lab"
  },
  "sourceRepository": {
    "type": "git",
    "url": "https://github.com/zyntx-lab/periphery-mcp-server.git"
  },
  "categories": [
    "code-analysis",
    "development-tools"
  ],
  "capabilities": {
    "tools": [
      {
        "name": "check_periphery_installed",
        "description": "Verify Periphery CLI is installed and accessible"
      },
      {
        "name": "get_periphery_version",
        "description": "Get the installed version of Periphery"
      },
      {
        "name": "scan_project",
        "description": "Run a basic Periphery scan on a project"
      },
      {
        "name": "scan_with_config",
        "description": "Run Periphery scan using a YAML configuration file"
      },
      {
        "name": "analyze_unused_imports",
        "description": "Focus specifically on detecting unused imports"
      },
      {
        "name": "find_redundant_public",
        "description": "Identify public declarations that could be internal"
      },
      {
        "name": "scan_with_options",
        "description": "Advanced scanning with custom Periphery flags"
      }
    ]
  },
  "runtime": {
    "type": "binary",
    "platform": "macos",
    "architecture": "arm64"
  },
  "distributions": [
    {
      "type": "github-release",
      "identifier": "https://github.com/${REPO}/releases/download/v${VERSION}/periphery-mcp-server",
      "sha256": "${SHA256}",
      "platform": "darwin-arm64"
    }
  ]
}
EOF

echo "✅ server.json updated"
echo ""

# Create GitHub release
echo "🏷️  Creating GitHub release v${VERSION}..."
gh release create "v${VERSION}" \
    "$BINARY#periphery-mcp-server" \
    --repo "$REPO" \
    --title "v${VERSION} - Periphery MCP Server" \
    --notes "## Periphery MCP Server v${VERSION}

A Model Context Protocol server that wraps the Periphery tool for Swift code analysis.

### Features
- ✅ 7 MCP tools for comprehensive code analysis
- ✅ CLI integration for stability
- ✅ JSON output for AI interpretation
- ✅ Support for Xcode projects and Swift Packages

### Installation

\`\`\`bash
# Download and install
curl -L https://github.com/${REPO}/releases/download/v${VERSION}/periphery-mcp-server \\
  -o /usr/local/bin/periphery-mcp-server
chmod +x /usr/local/bin/periphery-mcp-server
\`\`\`

### Configuration

Add to \`~/Library/Application Support/Claude/claude_desktop_config.json\`:

\`\`\`json
{
  \"mcpServers\": {
    \"periphery\": {
      \"command\": \"/usr/local/bin/periphery-mcp-server\"
    }
  }
}
\`\`\`

Then restart Claude Desktop.

### SHA-256
\`${SHA256}\`

See README for full documentation and usage examples."

echo ""
echo "✅ GitHub release created successfully!"
echo ""
echo "📦 Next steps to publish to MCP Registry:"
echo ""
echo "1. Install mcp-publisher:"
echo "   brew install mcp-publisher"
echo ""
echo "2. Publish to registry:"
echo "   mcp-publisher publish"
echo ""
echo "3. You'll be prompted to authenticate with GitHub"
echo ""
echo "4. Verify your server appears at:"
echo "   https://registry.modelcontextprotocol.io"
echo ""
