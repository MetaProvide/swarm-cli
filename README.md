# Swarm CLI Standalone

Standalone executable distribution of the [Ethersphere Swarm CLI](https://github.com/ethersphere/swarm-cli).

Run swarm-cli on any server without installing Node.js or Docker - just download and execute a single binary.

## Features

- ✅ **Zero dependencies** - No Node.js or Docker required
- ✅ **Single executable** - One file, ~50-80MB
- ✅ **Cross-platform** - Linux, macOS, Windows
- ✅ **Version tracking** - Know exactly which swarm-cli version is bundled
- ✅ **Auto-updates** - Renovate bot monitors for new swarm-cli releases

## Quick Start

### Download

Get the latest binary from the [releases page](https://github.com/metaprovide/swarm-cli/releases):

```bash
# Linux x64
wget -O swarm-cli https://github.com/metaprovide/swarm-cli/releases/latest/download/swarm-cli-linux
chmod +x swarm-cli

# macOS (Apple Silicon)
curl -L -o swarm-cli https://github.com/metaprovide/swarm-cli/releases/latest/download/swarm-cli-macos-arm
chmod +x swarm-cli

# Windows
# Download swarm-cli-windows.exe from releases page and rename to swarm-cli.exe
```

### Install (Optional)

```bash
# Linux/macOS - Install system-wide
sudo mv swarm-cli /usr/local/bin/swarm-cli

# Now run from anywhere
swarm-cli --help
```

### Available Binaries

| Platform | Binary Name             | Architecture          |
| -------- | ----------------------- | --------------------- |
| Linux    | `swarm-cli-linux`       | x64                   |
| Linux    | `swarm-cli-linux-arm`   | ARM64                 |
| macOS    | `swarm-cli-macos`       | Intel (x64)           |
| macOS    | `swarm-cli-macos-arm`   | Apple Silicon (ARM64) |
| Windows  | `swarm-cli-windows.exe` | x64                   |

## Usage

The binary works exactly like the native swarm-cli. All commands and options are fully supported.

```bash
# Check bundled version
./swarm-cli --bundled-version

# Use it like regular swarm-cli
./swarm-cli --help
./swarm-cli status
```

For complete swarm-cli documentation and all available commands, see the [official swarm-cli repository](https://github.com/ethersphere/swarm-cli).

## Building from Source

Want to build the binaries yourself? See [BUILD.md](BUILD.md) for:

- Build requirements
- Build commands
- CI/CD pipeline details
- Version management
- Release process

Quick build:

```bash
pnpm install
make build-all
```

## How It Works

This project uses [@yao-pkg/pkg](https://github.com/yao-pkg/pkg) to bundle:

- Node.js runtime (v22)
- @ethersphere/swarm-cli package
- All dependencies

Into a single executable file. The result is a ~50-80MB binary that runs anywhere without requiring Node.js or Docker.

## Automatic Updates

This repository uses [Renovate Bot](https://github.com/renovatebot/renovate) for fully automated updates:

1. **Renovate detects** new swarm-cli version (checks every weekend)
2. **Creates PR** with version update
3. **Auto-merges** after 3 days (safety period)
4. **Auto-creates release tag** (triggers binary build)
5. **GitHub Actions builds** and publishes binaries

New binaries are typically available within 3-4 days of upstream release.

## License

This project packages the Ethersphere Swarm CLI. Please refer to the [original project](https://github.com/ethersphere/swarm-cli) for licensing information.
