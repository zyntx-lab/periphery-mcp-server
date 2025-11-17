#!/bin/bash
set -e

echo "Building Periphery MCP Server..."

# Build for release
swift build -c release

echo "Build complete!"
echo "Executable location: .build/release/periphery-mcp-server"

# Create universal binary for distribution
if [[ "$(uname)" == "Darwin" ]]; then
    echo ""
    echo "Creating universal binary (arm64 + x86_64)..."

    # Build for both architectures
    swift build -c release --arch arm64
    swift build -c release --arch x86_64

    # Create universal binary
    lipo -create \
        .build/arm64-apple-macosx/release/periphery-mcp-server \
        .build/x86_64-apple-macosx/release/periphery-mcp-server \
        -output .build/periphery-mcp-server-universal

    echo "Universal binary created: .build/periphery-mcp-server-universal"

    # Show file info
    file .build/periphery-mcp-server-universal
fi

echo ""
echo "Installation:"
echo "  sudo cp .build/release/periphery-mcp-server /usr/local/bin/"
echo "  # or for universal:"
echo "  sudo cp .build/periphery-mcp-server-universal /usr/local/bin/periphery-mcp-server"
