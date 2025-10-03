# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

This is an asdf plugin for managing Aptos CLI versions. It downloads pre-built binaries from the official aptos-labs/aptos-core GitHub releases instead of compiling from source.

## Key Architecture

### Entry Points (bin/ directory)
- **download**: Downloads the ZIP file from GitHub releases for the specified version/platform
- **install**: Extracts the downloaded ZIP and installs the aptos binary to the install path
- **list-all**: Lists all versions that have available pre-built binaries for the current platform
- **latest-stable**: Returns the latest stable version from the filtered list
- **uninstall**: Removes an installed version

### Core Logic (lib/utils.bash)
All scripts source `lib/utils.bash` which contains:
- **Platform detection**: Maps `uname` output to Aptos release naming (Darwin→macOS, arm64/aarch64→arm64)
- **Artifact filtering**: `list_all_versions()` only shows versions where the binary artifact exists for your platform (uses HEAD requests to GitHub)
- **Download logic**: Constructs URLs like `https://github.com/aptos-labs/aptos-core/releases/download/aptos-cli-v{VERSION}/aptos-cli-{VERSION}-{OS}-{ARCH}.zip`
- **Version handling**: Uses git ls-remote to fetch tags matching `aptos-cli-v*` pattern

### Important Implementation Details
- Downloads are saved with `.tar.gz` extension to prevent asdf from auto-extracting, even though they're ZIP files
- The `install` script uses `unzip` to extract, not `tar`
- Binary is extracted from the ZIP and copied to `$ASDF_INSTALL_PATH/bin/aptos`

## Development Commands

### Linting
```bash
# Run shellcheck and shfmt on all shell scripts
scripts/lint.bash
```

### Formatting
```bash
# Auto-format shell scripts with shfmt
scripts/format.bash
```

### Testing
```bash
# Test the plugin locally (replace URL with your fork if testing changes)
asdf plugin test aptos https://github.com/asdf-vm/asdf-aptos.git "aptos --version"
```

## Environment Variables

- **GITHUB_API_TOKEN**: Optional - set to avoid rate limiting when listing versions
- **ASDF_CONCURRENCY**: Optional - for compilation (not used since we download binaries)

## Dependencies

- **shfmt 3.6.0**: Specified in .tool-versions for shell script formatting
- **shellcheck**: Used for linting bash scripts
- **asdf**: The plugin is tested with asdf v0.15.0

## Supported Platforms

- macOS: x86_64, arm64
- Linux: x86_64, aarch64 (mapped to arm64 in release URLs)
