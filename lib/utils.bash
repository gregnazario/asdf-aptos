#!/usr/bin/env bash

set -euo pipefail

GH_REPO="https://github.com/aptos-labs/aptos-core"
TOOL_NAME="aptos"
TOOL_TEST="aptos --version"

fail() {
	printf "asdf-%s: %s\n" "$TOOL_NAME" "$*"
	exit 1
}

curl_opts=(-fsSL)

# NOTE: You might want to remove this if aptos is not hosted on GitHub releases.
if [ -n "${GITHUB_API_TOKEN:-}" ]; then
	curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
	git ls-remote --tags --refs "$GH_REPO" |
		grep -o 'refs/tags/.*' | cut -d/ -f3- |
		grep '^aptos-cli-v' | sed 's/^aptos-cli-v//'
}

list_all_versions() {
	# Get current platform info
	os=$(uname -s)
	arch=$(uname -m)

	# Map OS and architecture to Aptos CLI release format
	if [[ "$os" == "Darwin" ]]; then
		os="macOS"
	elif [[ "$os" == "Linux" ]]; then
		os="Linux"
	fi

	if [[ "$arch" == "x86_64" ]]; then
		arch="x86_64"
	elif [[ "$arch" == "arm64" ]] || [[ "$arch" == "aarch64" ]]; then
		arch="arm64"
	fi

	# Get all versions and filter by available artifacts
	# Use a temporary file to store filtered versions
	temp_file=$(mktemp)

	list_github_tags | while read -r version; do
		# Check if the artifact exists for this platform
		artifact_url="https://github.com/aptos-labs/aptos-core/releases/download/aptos-cli-v${version}/aptos-cli-${version}-${os}-${arch}.zip"

		# Use curl to check if the artifact exists (HEAD request)
		if curl -fsI "$artifact_url" >/dev/null 2>&1; then
			printf "%s\n" "$version" >>"$temp_file"
		fi
	done

	# Output the filtered versions
	if [[ -f "$temp_file" ]]; then
		cat "$temp_file"
		rm -f "$temp_file"
	fi
}

download_release() {
	local version filename
	version="$1"
	filename="$2"

	os=$(uname -s)
	arch=$(uname -m)

	# Map OS and architecture to Aptos CLI release format
	if [[ "$os" == "Darwin" ]]; then
		os="macOS"
	elif [[ "$os" == "Linux" ]]; then
		os="Linux"
	fi

	if [[ "$arch" == "x86_64" ]]; then
		arch="x86_64"
	elif [[ "$arch" == "arm64" ]] || [[ "$arch" == "aarch64" ]]; then
		arch="arm64"
	fi

	# Construct the download URL for the pre-built binary
	download_url="https://github.com/aptos-labs/aptos-core/releases/download/aptos-cli-v${version}/aptos-cli-${version}-${os}-${arch}.zip"

	printf "* Downloading %s release %s for %s %s...\n" "$TOOL_NAME" "$version" "${os}" "${arch}"
	printf "* URL: %s\n" "$download_url"

	# Download the pre-built binary (remove existing file first to avoid prompts)
	rm -f "$filename"
	curl "${curl_opts[@]}" -o "$filename" "$download_url" || fail "Could not download $download_url"
}

install_version() {
	local install_type="$1"
	local version="$2"
	local install_path="${3%/bin}/bin"

	if [ "$install_type" != "version" ]; then
		fail "asdf-$TOOL_NAME supports release installs only"
	fi

	(
		mkdir -p "$install_path"

		# Find the downloaded file (it's a ZIP file with .tar.gz extension)
		download_file=$(find "$ASDF_DOWNLOAD_PATH" -maxdepth 1 -name "*.tar.gz" | head -1)
		[ -n "$download_file" ] || fail "Could not find downloaded file in $ASDF_DOWNLOAD_PATH"

		# Extract the ZIP file (even though it has .tar.gz extension)
		unzip -q "$download_file" -d "$ASDF_DOWNLOAD_PATH" || fail "Could not extract $download_file"
		rm -f "$download_file"

		# Find the aptos binary in the extracted files
		aptos_bin=$(find "$ASDF_DOWNLOAD_PATH" -type f -name aptos | head -1)
		[ -n "$aptos_bin" ] || fail "Could not find aptos binary after extraction"

		# Copy the aptos executable to the install path
		cp "$aptos_bin" "$install_path/" || fail "Could not copy aptos executable"
		chmod +x "$install_path/aptos"

		local tool_cmd
		tool_cmd="$(printf "%s" "$TOOL_TEST" | cut -d' ' -f1)"
		test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."
		printf "%s %s installation was successful!\n" "$TOOL_NAME" "$version"
	) || (
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version."
	)
}

list_latest_stable() {
	# Get the latest version from the filtered list of available versions
	list_all_versions | sort_versions | tail -n1
}
