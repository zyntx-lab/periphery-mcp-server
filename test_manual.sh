#!/bin/bash

echo "Testing Periphery MCP Server manually..."
echo ""

# Create a named pipe for communication
PIPE=$(mktemp -u)
mkfifo "$PIPE"

# Start the server in background, redirecting to pipe
.build/release/periphery-mcp-server > "$PIPE" 2>&1 &
SERVER_PID=$!

echo "Server started with PID: $SERVER_PID"
echo ""

# Give server time to start
sleep 1

# Send initialize request
echo "Sending initialize request..."
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test-client","version":"1.0.0"}}}' | .build/release/periphery-mcp-server &

# Wait a bit
sleep 2

# Clean up
kill $SERVER_PID 2>/dev/null
rm -f "$PIPE"

echo ""
echo "Test complete. For proper testing, use Claude Desktop or MCP Inspector."
