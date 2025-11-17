# Periphery MCP Server

A [Model Context Protocol (MCP)](https://modelcontextprotocol.io) server that wraps the [Periphery](https://github.com/peripheryapp/periphery) tool, enabling AI assistants to perform Swift code audits and detect unused code in iOS/macOS projects.

## Features

- **7 MCP Tools** for comprehensive code analysis
- **CLI Integration** - Uses Periphery CLI for stability and version flexibility
- **JSON Output** - Structured, parseable results perfect for AI interpretation
- **Flexible Scanning** - Support for Xcode projects and Swift Packages
- **Advanced Options** - Full control over Periphery scan configurations

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

### Option 1: Build from Source

```bash
git clone https://github.com/zyntx-lab/periphery-mcp-server.git
cd periphery-mcp-server
swift build -c release
```

The executable will be at `.build/release/periphery-mcp-server`.

### Option 2: Install Binary

Download the latest binary from [Releases](https://github.com/zyntx-lab/periphery-mcp-server/releases) and place it in your PATH.

## Configuration

### Claude Desktop

Add to `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "periphery": {
      "command": "/path/to/periphery-mcp-server"
    }
  }
}
```

### VS Code

Add to `.vscode/mcp.json`:

```json
{
  "mcpServers": {
    "periphery": {
      "type": "stdio",
      "command": "/path/to/periphery-mcp-server"
    }
  }
}
```

### Cursor

Add to `.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "periphery": {
      "type": "stdio",
      "command": "/path/to/periphery-mcp-server"
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

```
You: "Check if I have any unused code in my iOS project"

Claude: [Uses check_periphery_installed, then scan_project]
"I found 15 unused declarations in your project:
- 5 unused classes
- 8 unused functions
- 2 unused imports

Here are the details..."
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

### Periphery Not Found

If you get "Periphery is not installed":

1. Install Periphery: `brew install peripheryapp/periphery/periphery`
2. Verify installation: `which periphery`
3. Restart Claude Desktop/VS Code/Cursor

### Scan Timeout

Default timeout is 5 minutes. For large projects:

1. Use `scan_with_config` with a focused configuration
2. Scan specific targets instead of the entire project
3. Use `--index-store-path` to reuse build artifacts

### No Results

Periphery requires a compiled project with an index store:

1. Build your project first in Xcode
2. Ensure schemes are shared (Xcode → Product → Scheme → Manage Schemes → Shared)
3. Check that the project path is correct

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
