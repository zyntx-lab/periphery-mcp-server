# Periphery MCP Server

A [Model Context Protocol (MCP)](https://modelcontextprotocol.io) server that wraps the [Periphery](https://github.com/peripheryapp/periphery) tool, enabling AI assistants to perform Swift code audits and detect unused code in iOS/macOS projects.

## Features

- **7 MCP Tools** for comprehensive code analysis
- **CLI Integration** - Uses Periphery CLI for stability and version flexibility
- **JSON Output** - Structured, parseable results perfect for AI interpretation
- **Flexible Scanning** - Support for Xcode projects and Swift Packages
- **Advanced Options** - Full control over Periphery scan configurations

## Quick Start

```bash
# 1. Install Periphery
brew install peripheryapp/periphery/periphery

# 2. Clone and build this server
git clone https://github.com/YOUR_USERNAME/periphery-mcp-server.git
cd periphery-mcp-server
swift build -c release

# 3. Install to system path
sudo cp .build/release/periphery-mcp-server /usr/local/bin/
sudo chmod +x /usr/local/bin/periphery-mcp-server

# 4. Configure Claude Desktop
# Edit: ~/Library/Application Support/Claude/claude_desktop_config.json
# Add:
#   "periphery": {
#     "command": "/usr/local/bin/periphery-mcp-server"
#   }

# 5. Restart Claude Desktop (Cmd+Q then reopen)

# 6. Test it
# In Claude Desktop: "Check if Periphery is installed"
```

## Prerequisites

- macOS 13.0 or later
- Swift 6.0 or later
- [Periphery](https://github.com/peripheryapp/periphery) installed

### Installing Periphery

```bash
brew install peripheryapp/periphery/periphery
```

Or download from [Periphery releases](https://github.com/peripheryapp/periphery/releases).

## Installation

### Step 1: Build from Source

```bash
# Clone the repository
it clone https://github.com/zyntx-lab/periphery-mcp-server.git
cd periphery-mcp-server

# Build release version
swift build -c release

# The executable will be at .build/release/periphery-mcp-server
```

### Step 2: Install the Binary (Choose One)

#### Option A: Install to /usr/local/bin (Recommended)

```bash
# Copy to system path (requires password)
sudo cp .build/release/periphery-mcp-server /usr/local/bin/
sudo chmod +x /usr/local/bin/periphery-mcp-server

# Verify installation
which periphery-mcp-server
# Should output: /usr/local/bin/periphery-mcp-server
```

#### Option B: Use Direct Path

Skip system installation and use the full path in your configuration (see Configuration section below).

### Alternative: Download Pre-built Binary

Download the latest binary from [Releases](https://github.com/zyntx-lab/periphery-mcp-server/releases) and place it in your PATH and follow option A or B above.

## Configuration

### Claude Desktop

#### Step 1: Locate Your Config File

The config file is at: `~/Library/Application Support/Claude/claude_desktop_config.json`

#### Step 2: Edit the Configuration

**If you installed to /usr/local/bin:**

```json
{
  "mcpServers": {
    "periphery": {
      "command": "/usr/local/bin/periphery-mcp-server"
    }
  }
}
```

**If you're using the build directory directly:**

```json
{
  "mcpServers": {
    "periphery": {
      "command": "/FULL/PATH/TO/periphery-mcp-server/.build/release/periphery-mcp-server"
    }
  }
}
```

**If you already have other MCP servers configured:**

```json
{
  "mcpServers": {
    "xcode": {
      "command": "node",
      "args": ["/path/to/xcode-mcp-server/dist/index.js"]
    },
    "periphery": {
      "command": "/usr/local/bin/periphery-mcp-server"
    }
  }
}
```

#### Step 3: Restart Claude Desktop

**Important:** You must completely quit and restart Claude Desktop for changes to take effect.

1. Quit Claude Desktop: Press `Cmd+Q` or use Claude Desktop → Quit
2. Wait a few seconds
3. Reopen Claude Desktop

#### Step 4: Verify It's Working

Open a new conversation in Claude Desktop and try:

```
"Check if Periphery is installed"
```

If configured correctly, Claude will use the `check_periphery_installed` tool and respond with installation status.

### Testing with MCP Inspector

Before configuring Claude Desktop, you can test the server with the MCP Inspector:

```bash
# Install MCP Inspector (if not already installed)
npm install -g @modelcontextprotocol/inspector

# Test your server
npx @modelcontextprotocol/inspector /usr/local/bin/periphery-mcp-server

# Or if using build directory
npx @modelcontextprotocol/inspector /path/to/periphery-mcp-server/.build/release/periphery-mcp-server
```

The Inspector will open in your browser where you can test all tools interactively.

### Other Editors

#### VS Code

Add to `.vscode/mcp.json`:

```json
{
  "mcpServers": {
    "periphery": {
      "type": "stdio",
      "command": "/usr/local/bin/periphery-mcp-server"
    }
  }
}
```

#### Cursor

Add to `.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "periphery": {
      "type": "stdio",
      "command": "/usr/local/bin/periphery-mcp-server"
    }
  }
}
```

## Available Tools

### 1. `check_periphery_installed`

Verify that Periphery CLI is installed and accessible.

**Parameters:** None

**Example Response:**
```json
{
  "installed": true,
  "path": "/usr/local/bin/periphery",
  "message": "Periphery is installed and ready"
}
```

### 2. `get_periphery_version`

Get the installed version of Periphery.

**Parameters:** None

**Example Response:**
```json
{
  "version": "2.18.0",
  "raw_output": "2.18.0"
}
```

### 3. `scan_project`

Run a basic Periphery scan on a project.

**Parameters:**
- `project_path` (required): Path to .xcodeproj or Package.swift
- `schemes` (optional): Build schemes to scan (Xcode only)
- `targets` (optional): Specific targets to analyze
- `format` (optional): Output format: json, xcode, csv, checkstyle (default: json)

**Example Response:**
```json
{
  "success": true,
  "results": [
    {
      "kind": "class",
      "name": "UnusedClass",
      "modifiers": ["public"],
      "location": "Sources/MyApp/UnusedClass.swift:10:7"
    }
  ],
  "summary": {
    "total_unused": 5,
    "by_kind": {"class": 2, "function": 3}
  }
}
```

### 4. `scan_with_config`

Run Periphery scan using a YAML configuration file.

**Parameters:**
- `config_path` (required): Path to .periphery.yml config file

### 5. `analyze_unused_imports`

Focus specifically on detecting unused imports.

**Parameters:**
- `project_path` (required): Path to .xcodeproj or Package.swift
- `schemes` (optional): Build schemes to scan
- `targets` (optional): Specific targets to analyze

### 6. `find_redundant_public`

Identify public declarations that could be internal.

**Parameters:**
- `project_path` (required): Path to .xcodeproj or Package.swift
- `schemes` (optional): Build schemes to scan
- `targets` (optional): Specific targets to analyze

### 7. `scan_with_options`

Advanced scanning with custom Periphery flags.

**Parameters:**
- `project_path` (required): Path to .xcodeproj or Package.swift
- `schemes` (optional): Build schemes to scan
- `targets` (optional): Specific targets to analyze
- `format` (optional): Output format
- `retain_public` (optional): Retain all public declarations
- `retain_objc_accessible` (optional): Retain @objc declarations
- `disable_unused_import_analysis` (optional): Disable unused import analysis
- `index_store_path` (optional): Custom index store location
- `verbose` (optional): Enable verbose output

## Usage Examples

### With Claude Desktop

Once configured, you can have natural conversations with Claude about your code:

**Check Installation:**
```
You: "Check if Periphery is installed"

Claude: [Uses check_periphery_installed]
"Yes, Periphery is installed at /usr/local/bin/periphery
Version: 2.18.0"
```

**Scan a Project:**
```
You: "Scan my iOS project at ~/Projects/MyApp/MyApp.xcodeproj for unused code"

Claude: [Uses scan_project]
"I found 15 unused declarations in your project:

Classes (5):
- UnusedViewController at MyApp/UnusedViewController.swift:10
- OldDataManager at MyApp/Models/OldDataManager.swift:25
...

Functions (8):
- helperFunction at Utils/Helpers.swift:42
...

Imports (2):
- UIKit in DataModel.swift:1
..."
```

**Find Redundant Public:**
```
You: "Check which public declarations could be made internal in ~/Projects/MyFramework"

Claude: [Uses find_redundant_public]
"Found 12 public declarations that are only used internally and could be made internal:
- public class InternalHelper (only used within the framework)
- public func formatDate() (only called from within the module)
..."
```

**Analyze Unused Imports:**
```
You: "Find unused imports in my Swift package"

Claude: [Uses analyze_unused_imports]
"Found 8 unused imports that can be safely removed:
- Foundation in Models/User.swift (not using any Foundation APIs)
- Combine in ViewModels/ProfileViewModel.swift (Combine is imported but not used)
..."
```

### With Custom Configuration

Create `.periphery.yml` in your project:

```yaml
project: MyApp.xcodeproj
schemes:
  - MyApp
targets:
  - MyApp
  - MyAppKit
format: json
retain_public: false
retain_objc_accessible: true
verbose: false
```

Then use `scan_with_config`:

```
You: "Scan my project using the custom config"
```

## Troubleshooting

### Server Not Appearing in Claude Desktop

**Symptoms:** Claude doesn't recognize Periphery tools after configuration

**Solutions:**

1. **Verify config file syntax:**
   ```bash
   # Check for JSON syntax errors
   cat ~/Library/Application\ Support/Claude/claude_desktop_config.json | python3 -m json.tool
   ```

2. **Check the binary path is correct:**
   ```bash
   # Test that the binary exists and runs
   /usr/local/bin/periphery-mcp-server
   # Or your custom path
   /path/to/.build/release/periphery-mcp-server
   ```

3. **Completely restart Claude Desktop:**
   - Press `Cmd+Q` to quit (not just close the window)
   - Wait 5 seconds
   - Reopen Claude Desktop
   - Start a new conversation (old conversations won't see new servers)

4. **Check Claude Desktop logs:**
   ```bash
   # View logs for errors
   tail -f ~/Library/Logs/Claude/mcp*.log
   ```

### Periphery Not Found

If you get "Periphery is not installed":

1. Install Periphery: `brew install peripheryapp/periphery/periphery`
2. Verify installation: `which periphery`
3. Restart Claude Desktop/VS Code/Cursor
4. Try the `check_periphery_installed` tool again

### MCP Inspector Connection Errors

If the Inspector can't connect to the server:

1. **Verify the server runs:**
   ```bash
   # Server should wait for input, not exit immediately
   /usr/local/bin/periphery-mcp-server
   # Press Ctrl+C to exit
   ```

2. **Check for errors:**
   ```bash
   # Run with verbose output
   /usr/local/bin/periphery-mcp-server 2>&1 | tee server.log
   ```

3. **Use the absolute path:**
   ```bash
   npx @modelcontextprotocol/inspector $(which periphery-mcp-server)
   ```

### Scan Timeout

Default timeout is 5 minutes. For large projects:

1. Use `scan_with_config` with a focused configuration
2. Scan specific targets instead of the entire project
3. Use `--index-store-path` to reuse build artifacts
4. Build your project in Xcode first to generate the index

### No Results or Empty Scan

Periphery requires a compiled project with an index store:

1. **Build your project first in Xcode** (Cmd+B)
2. **Ensure schemes are shared:**
   - Xcode → Product → Scheme → Manage Schemes
   - Check the "Shared" checkbox for your scheme
3. **Verify the project path:**
   ```bash
   # For Xcode projects
   ls /path/to/YourProject.xcodeproj

   # For Swift Packages
   ls /path/to/Package.swift
   ```
4. **Check Periphery can access the project:**
   ```bash
   # Test Periphery directly
   periphery scan --project /path/to/YourProject.xcodeproj --schemes YourScheme
   ```

### Permission Denied

If you get "Permission denied" when running the server:

```bash
# Make the binary executable
chmod +x /usr/local/bin/periphery-mcp-server

# Or for build directory
chmod +x .build/release/periphery-mcp-server
```

## Architecture

This server uses the **CLI approach** rather than importing Periphery as a library for maximum stability:

- ✅ CLI interface is Periphery's public API contract
- ✅ Survives internal Periphery refactorings
- ✅ Users can update Periphery independently
- ✅ Simpler dependency management

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Related Projects

- [Periphery](https://github.com/peripheryapp/periphery) - The underlying code analysis tool
- [Model Context Protocol](https://modelcontextprotocol.io) - The protocol specification
- [MCP Swift SDK](https://github.com/modelcontextprotocol/swift-sdk) - Official Swift SDK for MCP

## Support

- **Issues**: [GitHub Issues](https://github.com/YOUR_USERNAME/periphery-mcp-server/issues)
- **Periphery Docs**: [Periphery Guide](https://github.com/peripheryapp/periphery)
- **MCP Docs**: [MCP Specification](https://spec.modelcontextprotocol.io)
