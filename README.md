# Swarm CLI Docker

A containerized version of the [Ethersphere Swarm CLI](https://github.com/ethersphere/swarm-cli) for easy, portable usage without local installation.

## Installation

### Option 1: Debian/Ubuntu Package (Recommended)

Download and install the `.deb` package from the [releases page](https://github.com/metaprovide/swarm-cli/releases).

**Two package variants are available:**

**Lightweight (recommended)** - Downloads Docker image on first use:
```bash
# Download the lightweight package (~10KB)
wget https://github.com/metaprovide/swarm-cli/releases/latest/download/swarm-cli_1.0.0_all.deb

# Install with dependencies
sudo apt install ./swarm-cli_1.0.0_all.deb
```

**Self-contained** - Includes bundled Docker image (no internet required):
```bash
# Download the self-contained package (~50-100MB)
wget https://github.com/metaprovide/swarm-cli/releases/latest/download/swarm-cli_1.0.0_all-with-image.deb

# Install with dependencies
sudo apt install ./swarm-cli_1.0.0_all-with-image.deb
```

After installation, use `swarm-cli` directly:

```bash
swarm-cli --help
swarm-cli status
```

**Update the Docker image:**
```bash
swarm-cli --update
```

### Option 2: Direct Docker Usage

Run Swarm CLI commands directly using Docker:

```bash
docker run --rm -it ghcr.io/metaprovide/swarm-cli:latest --help
```

## Usage

### With Debian Package

If you installed the `.deb` package, simply use `swarm-cli`:

```bash
# Display help
swarm-cli --help

# Upload a file
swarm-cli upload myfile.txt

# Download content
swarm-cli download <hash> output.txt

# Check status
swarm-cli status
```

The package automatically:
- Mounts your current directory as `/data` in the container
- Handles TTY detection for interactive/non-interactive modes
- Uses `--network=host` for local Swarm node access

### With Direct Docker

#### Basic Commands

Display help:
```bash
docker run --rm -it ghcr.io/metaprovide/swarm-cli:latest --help
```

### Interactive Mode

For interactive commands that require TTY:
```bash
docker run --rm -it --network=host ghcr.io/metaprovide/swarm-cli:latest [command] [options]
```

### Non-Interactive Mode

For scripting or piping output:
```bash
docker run --rm --network=host ghcr.io/metaprovide/swarm-cli:latest [command] [options]
```

### Common Examples

**Upload a file:**
```bash
docker run --rm -it \
  --network=host \
  -v "$(pwd):/data" \
  ghcr.io/metaprovide/swarm-cli:latest upload /data/myfile.txt
```

**Download content:**
```bash
docker run --rm -it \
  --network=host \
  -v "$(pwd):/data" \
  ghcr.io/metaprovide/swarm-cli:latest download <hash> /data/output.txt
```

**Check status:**
```bash
docker run --rm -it \
  --network=host \
  ghcr.io/metaprovide/swarm-cli:latest status
```

## Volume Mounting

To access local files, mount your working directory:

```bash
docker run --rm -it \
  -v "$(pwd):/data" \
  --network=host \
  ghcr.io/metaprovide/swarm-cli:latest upload /data/yourfile.txt
```

## Network Mode

The `--network=host` flag is used to allow the container to access your local Swarm node. If your Swarm node is running on a different network or you need custom networking, adjust accordingly.

## Creating an Alias

For convenience, create a shell alias:

**Bash/Zsh:**
```bash
echo 'alias swarm-cli="docker run --rm -it --network=host ghcr.io/metaprovide/swarm-cli:latest"' >> ~/.bashrc
source ~/.bashrc
```

Then use it like a native command:
```bash
swarm-cli --help
swarm-cli status
```

## Available Tags

- `latest` - Latest build from the main branch
- `v*` - Semantic version tags (e.g., `v1.0.0`)
- `main` - Latest commit on main branch

## Building Locally

### Build the Docker Image

To build the image yourself:

```bash
docker build -t swarm-cli:latest .
```

Then run with:
```bash
docker run --rm -it --network=host swarm-cli:latest --help
```

### Build the Debian Package

**Option 1: Build without bundled Docker image (smaller package):**

```bash
make build
```

This creates a lightweight package that pulls the Docker image from GHCR on first use.

**Option 2: Build with bundled Docker image (larger package, no internet required):**

```bash
make build-with-image
```

This bundles the Docker image inside the `.deb` package (~50-100MB larger), so users don't need internet access to install. The bundled image is automatically loaded during installation and then removed to save disk space.

**Install the package:**

```bash
make install
```

Or manually:
```bash
sudo apt install ./swarm-cli_1.0.0_all.deb
```

**Other available make targets:**
```bash
make help              # Show all available commands
make build             # Build package without Docker image
make build-with-image  # Build package with bundled Docker image
make clean             # Clean build artifacts
make uninstall         # Remove the package
```

## GitHub Container Registry

Images are automatically built and published to GitHub Container Registry (GHCR) on every push to the main branch and on version tags.

Pull the latest image:
```bash
docker pull ghcr.io/metaprovide/swarm-cli:latest
```

## Requirements

- Docker installed and running
- Access to a Swarm node (local or remote)

## License

This project packages the Ethersphere Swarm CLI. Please refer to the [original project](https://github.com/ethersphere/swarm-cli) for licensing information.
