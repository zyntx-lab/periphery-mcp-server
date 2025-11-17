#!/bin/bash

# Simple test script for the MCP server
# This sends a tools/list request to the server

echo "Testing Periphery MCP Server..."
echo ""

# Start the server in the background
.build/release/periphery-mcp-server &
SERVER_PID=$!

# Give it a moment to start
sleep 1

# Send initialize request
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test-client","version":"1.0.0"}}}' | nc localhost 3000 2>/dev/null || echo "Server is stdio-based, not network-based"

# Kill the server
kill $SERVER_PID 2>/dev/null

echo ""
echo "For proper testing, use the MCP Inspector:"
echo "  npx @modelcontextprotocol/inspector .build/release/periphery-mcp-server"
