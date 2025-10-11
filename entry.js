#!/usr/bin/env node

// Entry point for swarm-cli executable
// This file is bundled by pkg into the standalone binary

// Handle --bundled-version flag to show build information
if (process.argv.includes('--bundled-version') || process.argv.includes('--build-info')) {
  const pkg = require('./package.json');
  const swarmCliVersion = pkg.dependencies['@ethersphere/swarm-cli'];
  
  console.log('Swarm CLI binary');
  console.log('Bundled swarm-cli version:', swarmCliVersion);
  console.log('Node.js version:', process.version);
  process.exit(0);
}

// Execute the swarm-cli
// The path is resolved at build time by pkg
require('@ethersphere/swarm-cli/./dist/src/index.js');
