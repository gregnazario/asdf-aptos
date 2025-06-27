# asdf-aptos

[![GitHub Actions Status](https://github.com/asdf-vm/asdf-aptos/workflows/Main%20workflow/badge.svg?branch=main)](https://github.com/asdf-vm/asdf-aptos/actions)
[![GitHub license](https://img.shields.io/github/license/asdf-vm/asdf-aptos.svg)](https://github.com/asdf-vm/asdf-aptos/blob/main/LICENSE)

[Aptos CLI](https://aptos.dev/en/build/cli) plugin for [asdf](https://github.com/asdf-vm/asdf) version manager.

## Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Why?](#why)
- [Contributing](#contributing)
- [License](#license)

## Dependencies

- **macOS**: No additional dependencies required
- **Linux**: No additional dependencies required
- **Windows**: Not supported (use WSL2)

The plugin downloads pre-built binaries, so no compilation or Rust toolchain is required.

## Install

Plugin:

```bash
asdf plugin add aptos https://github.com/asdf-vm/asdf-aptos.git
```

Aptos CLI:

```bash
# Show all installable versions
asdf list all aptos

# Install latest version
asdf install aptos latest

# Install specific version
asdf install aptos 7.6.0

# Set a version globally (on your ~/.tool-versions file)
asdf global aptos 7.6.0

# Now aptos commands are available
aptos --version
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to install & manage versions.

## Features

- **Platform Detection**: Automatically detects your OS (macOS/Linux) and architecture (x86_64/arm64)
- **Artifact Filtering**: Only shows versions that have downloadable binaries for your platform
- **Pre-built Binaries**: Downloads official pre-built binaries (no compilation required)
- **Latest Version Detection**: Automatically finds the latest stable version
- **POSIX Compliant**: Follows asdf's banned commands policy for maximum compatibility

## Supported Platforms

- **macOS**: Intel (x86_64) and Apple Silicon (arm64)
- **Linux**: x86_64 and aarch64
- **Windows**: Not supported (use WSL2)

## Environment Variables

### GITHUB_API_TOKEN (Optional)
If you experience rate limiting when listing versions, you can set a GitHub API token:
```bash
export GITHUB_API_TOKEN=your_token_here
```

### ASDF_CONCURRENCY (Optional)
For compilation from source (if needed):
```bash
export ASDF_CONCURRENCY=4
```

## Configuration

Aptos CLI uses configuration files in the following locations:
- `~/.aptos/config.yaml` - Global configuration
- `./.aptos/config.yaml` - Project-specific configuration

Configure networks using `aptos init` or by editing the config files.

## asdf Extension Commands

This plugin provides the following asdf extension commands:

- `asdf help aptos` - Show plugin overview and dependencies
- `asdf aptos help` - Show detailed help information

## Why?

The Aptos CLI is the official command line interface for the Aptos blockchain, allowing you to:
- Create and manage Aptos accounts
- Deploy and interact with smart contracts
- Submit transactions to the Aptos blockchain
- Manage local development networks
- View blockchain data and account information

This plugin makes it easy to manage multiple versions of the Aptos CLI using asdf.

## Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Guidelines for contributing](https://github.com/asdf-vm/asdf/blob/master/CONTRIBUTING.md)

## License

See [LICENSE](LICENSE) file.
