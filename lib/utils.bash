#!/usr/bin/env bash

set -euo pipefail

GH_REPO="https://github.com/aptos-labs/aptos-core"
TOOL_NAME="aptos"
TOOL_TEST="aptos --version"

fail() {
	echo -e "asdf-$TOOL_NAME: $*"
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
	# Change this function if aptos has other means of determining installable versions.
	list_github_tags
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

	echo "* Downloading $TOOL_NAME release $version for ${os} ${arch}..."
	echo "* URL: $download_url"

	# Download the pre-built binary
	curl "${curl_opts[@]}" -o "$filename" -C - "$download_url" || fail "Could not download $download_url"
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
		
		# Extract the ZIP file
		unzip -q "$ASDF_DOWNLOAD_PATH"/*.zip -d "$ASDF_DOWNLOAD_PATH" || fail "Could not extract ZIP file"
		
		# Find the aptos binary in the extracted files
		aptos_bin=$(find "$ASDF_DOWNLOAD_PATH" -type f -name aptos | head -1)
		[ -n "$aptos_bin" ] || fail "Could not find aptos binary after extraction."
		
		# Copy the aptos executable to the install path
		cp "$aptos_bin" "$install_path/" || fail "Could not copy aptos executable"
		
		# Make the executable executable
		chmod +x "$install_path/aptos"

		local tool_cmd
		tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
		test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."
		echo "$TOOL_NAME $version installation was successful!"
	) || (
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version."
	)
}
