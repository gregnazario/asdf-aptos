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
		grep 'aptos-cli-v' | sed 's/^aptos-cli-v//' # NOTE: You might want to adapt this sed to remove non-version strings from tags
}

list_all_versions() {
	# Change this function if aptos has other means of determining installable versions.
	list_github_tags
}

download_release() {
	local version filename url
	version="$1"
	filename="$2"

  cli_version="${version/^aptos-cli-v//}"

	os=$(uname -s)
	arch=$(uname -m)
	legible_os=os

	if [[ "$os" == "Darwin" ]]; then
		os="macOS"
		legible_os="macOS"
	elif [[ "$os" == "Linux" ]]; then
		os="Ubuntu-22.04"
	fi

	# Pre-built
	pre_built_url="https://github.com/aptos-labs/aptos-core/releases/download/aptos-cli-v${version}/aptos-cli-${version}-${os}-${arch}.zip"
	source_url="https://github.com/aptos-labs/aptos-core/archive/refs/tags/aptos-cli-v${version}.zip"

  url=$source_url
  echo $pre_built_url
  echo $source_url

	# Attempt to download prebuilt, then the source, otherwise fail
	(echo "* Downloading $TOOL_NAME release $version for ${legible_os} ${arch}..." && curl "${curl_opts[@]}" -o "$filename" -C - "$pre_built_url") ||
		(echo "* Downloading $TOOL_NAME release $version source code..." && curl "${curl_opts[@]}" -o "$filename" -C - "$source_url") ||
		curl fail "Could not download prebuilt $pre_built_url or source $source_url"
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
		cp -r "$ASDF_DOWNLOAD_PATH"/* "$install_path"

		# TODO: Assert aptos executable exists.
		local tool_cmd
		tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
		test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."

		echo "$TOOL_NAME $version installation was successful!"
	) || (
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version."
	)
}
