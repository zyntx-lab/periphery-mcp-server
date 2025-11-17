#!/usr/bin/env node

const { spawn } = require('child_process');
const path = require('path');

const serverPath = path.join(__dirname, '.build/release/periphery-mcp-server');

console.log('Testing Periphery MCP Server via stdio...');
console.log('Server path:', serverPath);
console.log('');

const server = spawn(serverPath, [], {
  stdio: ['pipe', 'pipe', 'pipe']
});

let output = '';
let errorOutput = '';

server.stdout.on('data', (data) => {
  output += data.toString();
  console.log('STDOUT:', data.toString());
});

server.stderr.on('data', (data) => {
  errorOutput += data.toString();
  console.error('STDERR:', data.toString());
});

server.on('error', (err) => {
  console.error('Failed to start server:', err);
  process.exit(1);
});

server.on('close', (code) => {
  console.log('');
  console.log('Server exited with code:', code);
  console.log('Output:', output);
  console.log('Errors:', errorOutput);
});

// Send initialize request
setTimeout(() => {
  const initRequest = {
    jsonrpc: '2.0',
    id: 1,
    method: 'initialize',
    params: {
      protocolVersion: '2024-11-05',
      capabilities: {},
      clientInfo: {
        name: 'test-client',
        version: '1.0.0'
      }
    }
  };

  console.log('Sending initialize request:');
  console.log(JSON.stringify(initRequest, null, 2));
  console.log('');

  server.stdin.write(JSON.stringify(initRequest) + '\n');

  // Wait for response
  setTimeout(() => {
    // Send tools/list request
    const toolsRequest = {
      jsonrpc: '2.0',
      id: 2,
      method: 'tools/list',
      params: {}
    };

    console.log('Sending tools/list request:');
    console.log(JSON.stringify(toolsRequest, null, 2));
    console.log('');

    server.stdin.write(JSON.stringify(toolsRequest) + '\n');

    // Wait and then exit
    setTimeout(() => {
      server.kill();
    }, 2000);
  }, 1000);
}, 500);
