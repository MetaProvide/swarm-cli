#!/usr/bin/env node

/**
 * Build script for creating standalone swarm-cli executables
 * Uses @yao-pkg/pkg to bundle Node.js + swarm-cli into single binaries
 */

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const BUILD_DIR = path.join(__dirname, 'build');
const VERSION_FILE = path.join(BUILD_DIR, 'VERSION.txt');

// Target configurations
const TARGETS = {
  linux: 'node22-linux-x64',
  macos: 'node22-macos-x64',
  windows: 'node22-win-x64',
  'linux-arm': 'node22-linux-arm64',
  'macos-arm': 'node22-macos-arm64'
};

function getSwarmCliVersion() {
  try {
    const swarmCliPkgPath = path.join(__dirname, 'node_modules', '@ethersphere', 'swarm-cli', 'package.json');
    const swarmCliPkg = JSON.parse(fs.readFileSync(swarmCliPkgPath, 'utf8'));
    return swarmCliPkg.version;
  } catch (error) {
    return 'unknown';
  }
}

function checkDependencies() {
  console.log('📦 Checking dependencies...');
  
  if (!fs.existsSync('node_modules')) {
    console.error('❌ Error: node_modules not found');
    console.error('Please install dependencies first: pnpm install\n');
    process.exit(1);
  }
  
  if (!fs.existsSync('node_modules/@ethersphere/swarm-cli')) {
    console.error('❌ Error: @ethersphere/swarm-cli not found');
    console.error('Please install dependencies first: pnpm install\n');
    process.exit(1);
  }
  
  if (!fs.existsSync('node_modules/@yao-pkg')) {
    console.error('❌ Error: @yao-pkg/pkg not found');
    console.error('Please install dependencies first: pnpm install\n');
    process.exit(1);
  }
  
  console.log('✓ All dependencies found\n');
}

function writeVersionInfo(swarmCliVersion, buildDate) {
  const versionInfo = {
    swarmCliVersion,
    buildDate,
    nodeVersion: process.version,
    platform: process.platform,
    arch: process.arch
  };
  
  const versionText = `Swarm CLI Binary
=================
Bundled swarm-cli version: ${swarmCliVersion}
Build date: ${buildDate}
Node.js version: ${process.version}
Built on: ${process.platform}-${process.arch}

To check version in binary, run:
  ./swarm-cli-linux --bundled-version
`;

  fs.writeFileSync(VERSION_FILE, versionText);
  fs.writeFileSync(VERSION_FILE.replace('.txt', '.json'), JSON.stringify(versionInfo, null, 2));
  console.log(`✓ Version info written to ${VERSION_FILE}\n`);
}

function buildTarget(targetName, targetSpec) {
  console.log(`🔨 Building for ${targetName} (${targetSpec})...`);
  
  // Create build directory
  if (!fs.existsSync(BUILD_DIR)) {
    fs.mkdirSync(BUILD_DIR, { recursive: true });
  }

  // For Windows, pkg automatically adds .exe extension
  const isWindows = targetName.includes('win');
  const outputPath = path.join(BUILD_DIR, `swarm-cli-${targetName}`);
  const finalPath = isWindows ? outputPath + '.exe' : outputPath;
  
  try {
    execSync(
      `npx @yao-pkg/pkg entry.js --target ${targetSpec} --output ${outputPath} --compress GZip`,
      { stdio: 'inherit' }
    );
    
    // pkg automatically adds .exe for Windows targets, so no rename needed
    console.log(`✓ Built: ${finalPath}\n`);
    return true;
  } catch (error) {
    console.error(`✗ Failed to build ${targetName}:`, error.message);
    return false;
  }
}

function main() {
  const args = process.argv.slice(2);
  const requestedTarget = args[0] || 'linux';

  console.log('🚀 Swarm CLI Builder\n');
  console.log('================================\n');

  // Check dependencies
  checkDependencies();
  
  // Get version info
  const swarmCliVersion = getSwarmCliVersion();
  const buildDate = new Date().toISOString();
  
  console.log(`📋 Build Information:`);
  console.log(`   Swarm CLI version: ${swarmCliVersion}`);
  console.log(`   Build date: ${buildDate}`);
  console.log(`   Node.js version: ${process.version}\n`);

  // Build
  console.log('🔨 Starting build process...\n');

  if (requestedTarget === 'all') {
    console.log('Building for all platforms...\n');
    let successCount = 0;
    for (const [name, spec] of Object.entries(TARGETS)) {
      if (buildTarget(name, spec)) {
        successCount++;
      }
    }
    console.log(`\n✓ Built ${successCount}/${Object.keys(TARGETS).length} targets successfully`);
  } else if (TARGETS[requestedTarget]) {
    buildTarget(requestedTarget, TARGETS[requestedTarget]);
  } else {
    console.error(`Unknown target: ${requestedTarget}`);
    console.log('\nAvailable targets:');
    console.log('  - all (build all platforms)');
    Object.keys(TARGETS).forEach(name => {
      console.log(`  - ${name}`);
    });
    process.exit(1);
  }

  // Write version info
  writeVersionInfo(swarmCliVersion, buildDate);

  console.log('\n✅ Build complete!');
  console.log(`\nBinaries are in: ${BUILD_DIR}`);
  console.log(`\n📋 Version info: ${VERSION_FILE}`);
  console.log('\nTo test the binary:');
  console.log(`  ${path.join(BUILD_DIR, 'swarm-cli-linux')} --help`);
  console.log(`  ${path.join(BUILD_DIR, 'swarm-cli-linux')} --bundled-version`);
}

main();
