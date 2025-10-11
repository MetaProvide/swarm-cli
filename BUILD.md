# Build Instructions & Pipeline

This document covers the complete build process, CI/CD pipeline, and version management for standalone swarm-cli binaries.

## Table of Contents

- [Overview](#overview)
- [Build System](#build-system)
- [CI/CD Pipeline](#cicd-pipeline)
- [Version Management](#version-management)
- [Build Instructions](#build-instructions)
- [Release Process](#release-process)

## Overview

The standalone build system creates single executable files that bundle:

- Node.js runtime (v22)
- @ethersphere/swarm-cli package (pinned version)
- All dependencies

**Result:** A single executable file (~50-80MB) that runs anywhere without Node.js or Docker.

## Build System

### Technology Stack

- **Bundler**: [@yao-pkg/pkg](https://github.com/yao-pkg/pkg) (maintained fork of Vercel's pkg)
- **Package Manager**: pnpm v9.0.0
- **Node.js**: v22 (bundled in binary)
- **Compression**: GZip
- **Build Tool**: Make + Node.js script

### Build Script

The build process is orchestrated by `build.js`:

1. **Dependency Check**: Ensures pnpm and @yao-pkg/pkg are installed
2. **Version Detection**: Reads swarm-cli version from node_modules
3. **Binary Compilation**: Runs @yao-pkg/pkg for each target platform
4. **Version Files**: Creates VERSION.txt and VERSION.json

### Supported Platforms

| Target      | Node Version | Platform | Architecture |
| ----------- | ------------ | -------- | ------------ |
| `linux`     | node22       | Linux    | x64          |
| `linux-arm` | node22       | Linux    | ARM64        |
| `macos`     | node22       | macOS    | x64          |
| `macos-arm` | node22       | macOS    | ARM64        |
| `windows`   | node22       | Windows  | x64          |

## CI/CD Pipeline

### GitHub Actions Workflow

Location: `.github/workflows/build-standalone.yml`

**Triggers:**

- Git tags matching `v*` (e.g., `v1.0.0`)
- Manual workflow dispatch

**Steps:**

1. Checkout code
2. Setup pnpm
3. Setup Node.js with pnpm cache
4. Install dependencies (`pnpm install --frozen-lockfile`)
5. Build all platform binaries (`npm run build:all`)
6. Upload artifacts for each platform
7. Create GitHub release with:
   - All binaries
   - VERSION.txt and VERSION.json
   - Auto-generated release notes

**Artifacts:**

- `swarm-cli-linux`
- `swarm-cli-linux-arm`
- `swarm-cli-macos`
- `swarm-cli-macos-arm`
- `swarm-cli-windows.exe`
- `VERSION.txt`
- `VERSION.json`

### Build Time

- **First build**: ~2-5 minutes (downloads Node.js binaries)
- **Subsequent builds**: ~30-60 seconds (uses cached binaries)
- **CI/CD**: ~3-4 minutes (includes setup and upload)

## Version Management

### Version Pinning

Dependencies are pinned to exact versions in `package.json`:

```json
{
  "dependencies": {
    "@ethersphere/swarm-cli": "2.36.0" // No ^ or ~
  }
}
```

**Why?** Ensures reproducible builds - same code always produces same binary.

### Version Tracking

Each binary includes embedded version information:

**1. In the binary itself:**

```bash
./swarm-cli-linux --bundled-version
# Output:
# Standalone swarm-cli binary
# Bundled swarm-cli version: 2.36.0
# Build date: 2024-10-11T18:33:00.000Z
# Node.js version: v18.20.4
```

**2. In VERSION.txt:**

```
Standalone Swarm CLI Binary
============================
Bundled swarm-cli version: 2.36.0
Build date: 2024-10-11T18:33:00.000Z
Node.js version: v18.20.4
Built on: darwin-arm64
```

**3. In VERSION.json:**

```json
{
  "swarmCliVersion": "2.36.0",
  "buildDate": "2024-10-11T18:33:00.000Z",
  "nodeVersion": "v18.20.4",
  "platform": "darwin",
  "arch": "arm64"
}
```

### Updating swarm-cli Version

**Manual update:**

```bash
pnpm add @ethersphere/swarm-cli@2.37.0
pnpm run version-info  # Verify
make build-standalone-all
```

**Automatic update:**
Renovate Bot monitors for new versions and creates PRs automatically. See [RENOVATE.md](RENOVATE.md).

## Build Instructions

### Build for Linux (Recommended for servers)

```bash
# Install pnpm (if not already installed)
npm install -g pnpm

# Install dependencies (first time only)
pnpm install

# Build Linux binary
make build-standalone
```

The binary will be created at: `build/standalone/swarm-cli-linux`

Version information will be saved to: `build/standalone/VERSION.txt`

### Build for All Platforms

```bash
# Build binaries for Linux, macOS, and Windows
make build-standalone-all
```

Binaries will be created in `build/standalone/`:

- `swarm-cli-linux` (Linux x64)
- `swarm-cli-linux-arm` (Linux ARM64)
- `swarm-cli-macos` (macOS Intel)
- `swarm-cli-macos-arm` (macOS Apple Silicon)
- `swarm-cli-windows.exe` (Windows)

## Testing Your Build

```bash
# Make it executable
chmod +x build/standalone/swarm-cli-linux

# Check bundled version
./build/standalone/swarm-cli-linux --bundled-version

# Test it
./build/standalone/swarm-cli-linux --help

# Should display swarm-cli help without requiring Node.js or Docker!
```

## Deploying to Your Server

### Method 1: Direct Copy

```bash
# Copy to your server
scp build/standalone/swarm-cli-linux user@your-server:/tmp/

# SSH into server
ssh user@your-server

# Install
sudo mv /tmp/swarm-cli-linux /usr/local/bin/swarm-cli
sudo chmod +x /usr/local/bin/swarm-cli

# Test
swarm-cli --help
```

### Method 2: Using wget on Server

```bash
# On your server (after you've created a GitHub release)
wget https://github.com/metaprovide/swarm-cli/releases/latest/download/swarm-cli-linux
chmod +x swarm-cli-linux
sudo mv swarm-cli-linux /usr/local/bin/swarm-cli
```

## Release Process

### Creating a Release

1. **Update swarm-cli version** (if needed):

   ```bash
   pnpm add @ethersphere/swarm-cli@X.Y.Z
   pnpm run version-info
   ```

2. **Test locally**:

   ```bash
   make build-standalone-all
   ./build/standalone/swarm-cli-linux --bundled-version
   ./build/standalone/swarm-cli-linux --help
   ```

3. **Commit changes**:

   ```bash
   git add package.json pnpm-lock.yaml
   git commit -m "chore: update swarm-cli to vX.Y.Z"
   git push
   ```

4. **Create and push tag**:

   ```bash
   git tag v1.X.Y
   git push origin v1.X.Y
   ```

5. **GitHub Actions automatically**:
   - Builds all binaries
   - Creates GitHub release
   - Attaches binaries and version files
   - Generates release notes

### Release Artifacts

Each release includes:

- 5 platform binaries
- VERSION.txt (human-readable)
- VERSION.json (machine-readable)
- Auto-generated release notes with version info

### Binary Size

- Linux x64: ~60-70 MB
- macOS: ~65-75 MB
- Windows: ~65-75 MB

Size includes the entire Node.js runtime and all dependencies.

## Troubleshooting

### "pkg: command not found"

The build script automatically installs pkg via npx. If you see this error:

```bash
npm install -g pkg
```

### Build Fails with Memory Error

Increase Node.js memory:

```bash
NODE_OPTIONS="--max-old-space-size=4096" make build-standalone
```

### Binary Too Large

The binary includes the full Node.js runtime. This is normal and necessary for it to work without Node.js installed.

### Permission Errors During Build

Make sure you have write permissions in the project directory:

```bash
chmod -R u+w .
```

## Advanced Usage

### Build for Specific Platform Only

```bash
# Using npm scripts
npm run build:linux      # Linux x64 only
npm run build:macos      # macOS x64 only
npm run build:windows    # Windows x64 only

# Using the build script directly
node build-standalone.js linux
node build-standalone.js macos
node build-standalone.js windows
```

### Custom Build Configuration

Edit `build-standalone.js` to:

- Change Node.js version (modify `TARGETS` object)
- Add/remove platforms
- Adjust compression settings

### Clean Build

```bash
# Remove all build artifacts
make clean

# Rebuild from scratch
make build-standalone
```

## CI/CD Integration

### GitHub Actions

The repository includes `.github/workflows/build-standalone.yml` which automatically:

- Builds binaries for all platforms on version tags
- Uploads binaries as artifacts
- Creates GitHub releases with binaries attached

To trigger a release:

```bash
git tag v1.0.0
git push origin v1.0.0
```

### Manual Release Process

1. Build binaries: `make build-standalone-all`
2. Test each binary
3. Create GitHub release
4. Upload binaries from `build/standalone/`

## Comparison: Docker vs Standalone

| Aspect                  | Docker Approach             | Standalone Binary        |
| ----------------------- | --------------------------- | ------------------------ |
| **Server Requirements** | Docker daemon               | None                     |
| **Installation**        | Pull image                  | Copy file                |
| **Startup Time**        | ~1-2 seconds                | Instant                  |
| **Memory Usage**        | Higher (container overhead) | Lower (direct execution) |
| **Updates**             | `docker pull`               | Download new binary      |
| **Size on Disk**        | ~150MB (image)              | ~60MB (binary)           |
| **Portability**         | Needs Docker                | Runs anywhere            |

## Next Steps

1. **Build your binary**: `make build-standalone`
2. **Test it locally**: `./build/standalone/swarm-cli-linux --help`
3. **Deploy to server**: Copy the binary to your server
4. **Use it**: Run swarm-cli commands without Node.js or Docker!

## Support

- **Issues**: https://github.com/metaprovide/swarm-cli/issues
- **Upstream**: https://github.com/ethersphere/swarm-cli
- **Documentation**: See STANDALONE.md for usage guide

## License

This build system packages the Ethersphere Swarm CLI. See the original project for licensing information.
