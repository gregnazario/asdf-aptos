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

if [ -n "${GITHUB_API_TOKEN:-}" ]; then
	curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

# Returns OS and arch matching Aptos release asset names.
# macOS uname -m reports "arm64", Linux reports "aarch64" — both match asset names exactly.
get_platform() {
	local os arch
	os=$(uname -s)
	arch=$(uname -m)

	case "$os" in
	Darwin) os="macOS" ;;
	Linux) os="Linux" ;;
	*) fail "Unsupported OS: $os" ;;
	esac

	printf "%s %s" "$os" "$arch"
}

list_github_tags() {
	git ls-remote --tags --refs "$GH_REPO" |
		grep -o 'refs/tags/.*' | cut -d/ -f3- |
		grep '^aptos-cli-v' | sed 's/^aptos-cli-v//'
}

list_all_versions() {
	list_github_tags
}

download_release() {
	local version filename os arch
	version="$1"
	filename="$2"

	read -r os arch <<<"$(get_platform)"

	local download_url="https://github.com/aptos-labs/aptos-core/releases/download/aptos-cli-v${version}/aptos-cli-${version}-${os}-${arch}.zip"

	printf "* Downloading %s release %s for %s %s...\n" "$TOOL_NAME" "$version" "$os" "$arch"
	printf "* URL: %s\n" "$download_url"

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

		local download_file
		download_file=$(find "$ASDF_DOWNLOAD_PATH" -maxdepth 1 -name "*.zip" | head -1)
		[ -n "$download_file" ] || fail "Could not find downloaded file in $ASDF_DOWNLOAD_PATH"

		unzip -q "$download_file" -d "$ASDF_DOWNLOAD_PATH" || fail "Could not extract $download_file"
		rm -f "$download_file"

		local aptos_bin
		aptos_bin=$(find "$ASDF_DOWNLOAD_PATH" -type f -name aptos | head -1)
		[ -n "$aptos_bin" ] || fail "Could not find aptos binary after extraction"

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
	list_all_versions | sort_versions | tail -n1
}
