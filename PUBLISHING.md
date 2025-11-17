# Publishing Guide

This guide explains how to publish the Periphery MCP Server to the official MCP Registry.

## Prerequisites

1. **GitHub CLI** - Required for creating releases
   ```bash
   brew install gh
   gh auth login
   ```

2. **MCP Publisher CLI** - Required for registry submission
   ```bash
   brew install mcp-publisher
   ```

3. **Write access** to the `zyntx-lab/periphery-mcp-server` repository

## Publishing Methods

### Recommended: GitHub Actions (For Organization Namespace)

Since `io.github.zyntx-lab` is an organization namespace, the best way to publish is via GitHub Actions. We've created an automated workflow:

1. **Push a version tag** to trigger the workflow:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. **Or trigger manually** from GitHub:
   - Go to Actions → "Publish to MCP Registry" → "Run workflow"

The workflow will:
- Build the release binary
- Calculate SHA-256 hash
- Update `server.json`
- Create GitHub release
- Publish to MCP Registry (with organization permissions)

### Alternative: Manual Script (For Personal Testing)

For local testing or personal namespace, use the publish script:

```bash
./publish.sh
```

This script will:
1. Build the release binary (if needed)
2. Calculate the SHA-256 hash
3. Update `server.json` with the correct hash
4. Create a GitHub release with the binary
5. Provide next steps for MCP registry submission

**Note:** Manual publishing to organization namespaces requires GitHub Action context.

## Manual Publishing Steps

If you prefer to publish manually or need to troubleshoot:

### 1. Build the Binary

```bash
swift build -c release
```

### 2. Calculate SHA-256 Hash

```bash
openssl dgst -sha256 .build/release/periphery-mcp-server
```

Save this hash - you'll need it for `server.json`.

### 3. Update server.json

Edit `server.json` and update the SHA-256 hash in the `distributions` section:

```json
{
  "distributions": [
    {
      "type": "github-release",
      "identifier": "https://github.com/zyntx-lab/periphery-mcp-server/releases/download/v1.0.0/periphery-mcp-server",
      "sha256": "YOUR_HASH_HERE",
      "platform": "darwin-arm64"
    }
  ]
}
```

### 4. Create GitHub Release

```bash
gh release create v1.0.0 \
  .build/release/periphery-mcp-server#periphery-mcp-server \
  --repo zyntx-lab/periphery-mcp-server \
  --title "v1.0.0 - Periphery MCP Server" \
  --notes-file RELEASE_NOTES.md
```

### 5. Verify the Release

Check that the binary is downloadable:

```bash
curl -L https://github.com/zyntx-lab/periphery-mcp-server/releases/download/v1.0.0/periphery-mcp-server \
  -o /tmp/periphery-mcp-server-test
chmod +x /tmp/periphery-mcp-server-test
/tmp/periphery-mcp-server-test --version
```

### 6. Submit to MCP Registry

```bash
# Publish to the registry
mcp-publisher publish

# You'll be prompted to:
# 1. Authenticate with GitHub (for io.github.zyntx-lab namespace)
# 2. Confirm the server details
# 3. Submit to the registry
```

### 7. Verify Registry Listing

After submission, your server should appear at:
- **Registry Search**: https://registry.modelcontextprotocol.io
- **Direct Link**: https://registry.modelcontextprotocol.io/servers/io.github.zyntx-lab/periphery-mcp-server

## Registry Configuration

The `server.json` file defines how your server appears in the registry:

```json
{
  "name": "io.github.zyntx-lab/periphery-mcp-server",
  "displayName": "Periphery Code Audit",
  "description": "...",
  "homepage": "https://github.com/zyntx-lab/periphery-mcp-server",
  "license": "MIT",
  "vendor": {
    "name": "Zyntx Lab",
    "url": "https://github.com/zyntx-lab"
  },
  "categories": [
    "code-analysis",
    "development-tools"
  ],
  "capabilities": {
    "tools": [...]
  },
  "runtime": {
    "type": "binary",
    "platform": "macos",
    "architecture": "arm64"
  },
  "distributions": [...]
}
```

### Key Fields:

- **name**: `io.github.zyntx-lab/periphery-mcp-server` - Uses GitHub namespace
- **displayName**: How it appears in the registry
- **categories**: Helps users discover your server
- **capabilities**: Lists all 7 tools your server provides
- **runtime**: Specifies it's a native macOS ARM64 binary
- **distributions**: Points to the GitHub release URL with SHA-256 hash

## Namespace Authentication

The `io.github.zyntx-lab` namespace requires special handling:

### Why GitHub Actions?

The MCP registry's `io.github.*` namespace authentication is tied to GitHub **user accounts**, not organizations. Even if you're an admin of the zyntx-lab organization:

- Local `mcp-publisher login github` grants permission for `io.github.{your-username}/*`
- It does NOT grant permission for `io.github.zyntx-lab/*`

**Solution:** GitHub Actions running in the zyntx-lab repository have the organization context and can publish to `io.github.zyntx-lab/*`.

### Manual Publishing Limitation

If you try to publish manually, you'll get:
```
Error 403: You do not have permission to publish this server.
You have permission to publish: io.github.{your-username}/*
```

This is expected behavior for organization namespaces.

## Updating an Existing Release

To publish a new version:

1. Update the version number in:
   - `publish.sh` (VERSION variable)
   - `server.json` (distributions.identifier URL)

2. Build and create new release:
   ```bash
   swift build -c release
   ./publish.sh
   ```

3. Publish update to registry:
   ```bash
   mcp-publisher publish
   ```

## Troubleshooting

### "Binary hash mismatch"
The SHA-256 in `server.json` doesn't match the actual binary. Recalculate:
```bash
openssl dgst -sha256 .build/release/periphery-mcp-server
```

### "Release not found"
The GitHub release URL in `server.json` must be accessible. Verify:
```bash
curl -I https://github.com/zyntx-lab/periphery-mcp-server/releases/download/v1.0.0/periphery-mcp-server
```

### "Authentication failed"
Ensure you're logged into GitHub CLI with proper permissions:
```bash
gh auth status
gh auth refresh -s write:packages
```

### "Namespace verification failed"
Make sure you're a member of the `zyntx-lab` GitHub organization or use a different namespace.

## Alternative Distribution Methods

While we currently use GitHub releases, you could also distribute via:

1. **Homebrew Tap**
   - Create a formula in a tap repository
   - Users install with `brew install zyntx-lab/tap/periphery-mcp-server`

2. **Docker/OCI Container**
   - Build a container image
   - Push to Docker Hub or GitHub Container Registry
   - Add OCI distribution to `server.json`

3. **Direct Download**
   - Host binary on your own infrastructure
   - Update `server.json` with your URL

## Resources

- **MCP Registry**: https://registry.modelcontextprotocol.io
- **Registry GitHub**: https://github.com/modelcontextprotocol/registry
- **Publishing Docs**: https://github.com/modelcontextprotocol/registry/blob/main/docs/guides/publishing/publish-server.md
- **Publisher CLI**: https://github.com/modelcontextprotocol/registry/releases
