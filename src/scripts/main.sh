#!/bin/sh

# Hi! Based off the slack-orb-go main.sh. If you plan to have osx & windows
# support go look at that file and bring it back in.

# Determine the http client to use
# Returns 1 if no HTTP client is found
determine_http_client() {
    if command -v curl >/dev/null 2>&1; then
        HTTP_CLIENT=curl
    elif command -v wget >/dev/null 2>&1; then
        HTTP_CLIENT=wget
    else
        return 1
    fi
}

# Download a binary file
# $1: The path to save the file to
# $2: The URL to download the file from
# $3: The HTTP client to use (curl or wget)
download_binary() {
    if [ "$3" = "curl" ]; then
        set -x
        curl --fail --retry 3 -L -o "$1" "$2"
        set +x
    elif [ "$3" = "wget" ]; then
        set -x
        wget --tries=3 --timeout=10 --quiet -O "$1" "$2"
        set +x
    else
        return 1
    fi
}

detect_os() {
    detected_platform="$(uname -s | tr '[:upper:]' '[:lower:]')"
    case "$detected_platform" in
    linux*) PLATFORM=linux ;;
    # darwin*) PLATFORM=darwin ;;
    # msys* | cygwin*) PLATFORM=windows ;;
    *) return 1 ;;
    esac
}

detect_arch() {
    detected_arch="$(uname -m)"
    case "$detected_arch" in
    x86_64 | amd64) ARCH=amd64 ;;
    i386 | i486 | i586 | i686) ARCH=386 ;;
    arm64 | aarch64) ARCH=arm64 ;;
    arm*) ARCH=arm ;;
    *) return 1 ;;
    esac
}

# Confirm we have unzip available
# Returns 1 if unzip not found
detect_unzip() {
    if command -v unzip >/dev/null 2>&1; then
        return 0
    fi
    return 1
}

# Print a warning message
# $1: The warning message to print
print_warn() {
    yellow="\033[1;33m"
    normal="\033[0m"
    printf "${yellow}%s${normal}\n" "$1"
}

# Print a success message
# $1: The success message to print
print_success() {
    green="\033[0;32m"
    normal="\033[0m"
    printf "${green}%s${normal}\n" "$1"
}

# Print an error message
# $1: The error message to print
print_error() {
    red="\033[0;31m"
    normal="\033[0m"
    printf "${red}%s${normal}\n" "$1"
}

print_warn "This is an experimental version of the Sagemaker Orb."
print_warn "Thank you for trying it out and please provide feedback to us at https://github.com/CircleCI-Public/sagemaker-orb-go/issues"

if ! detect_os; then
    print_error "Unsupported operating system: $(uname -s)."
    exit 1
fi
printf '%s\n' "Operating system: $PLATFORM."

if ! detect_arch; then
    print_error "Unsupported architecture: $(uname -m)."
    exit 1
fi
printf '%s\n' "Architecture: $ARCH."

if ! detect_unzip; then
    print_error "Unzip is required to download the Sagemaker Orb binary."
    exit 1
fi

base_dir="$(printf "%s" "$CIRCLE_WORKING_DIRECTORY" | sed "s|~|$HOME|")"
orb_bin_dir="${base_dir}/.circleci/orbs/circleci/sagemaker/${PLATFORM}/${ARCH}"
org="circleci"
repo_name="cci-sagemaker"
# binary="${orb_bin_dir}/${repo_name}"
# TODO: Make the version configurable via parameter
# Don't forget the v!
binary_version="v0.0.13"
basic_name="cci-sagemaker"
binary_name="${basic_name}-${binary_version}-${PLATFORM}-${ARCH}"
binary_zip="${orb_bin_dir}/${binary_name}.zip"
# Where to move the binary
path_destination="/home/circleci/bin"
# Slack orb seems to put this outside the script as a parameter
# https://github.com/CircleCI-Public/slack-orb-go/blob/8c4e86c9a787c240138244610aada066059b5b46/src/commands/notify.yml#L80
# TODO: keep support for this? Or will people not bother? They would have to do to the packagecloud URL and find it
# when we parametize the version, we should support this as well
input_sha256=""

if [ ! -f "$binary_zip" ]; then
    mkdir -p "$orb_bin_dir"
    if ! determine_http_client; then
        printf '%s\n' "cURL or wget is required to download the Sagemaker Orb binary."
        printf '%s\n' "Please install cURL or wget and try again."
        exit 1
    fi
    printf '%s\n' "HTTP client: $HTTP_CLIENT."
    binary_url="https://packagecloud.io/${org}/${repo_name}/packages/anyfile/${binary_name}.zip/download?distro_version_id=230"
    printf '%s\n' "Release URL: $binary_url."

    if ! download_binary "$binary_zip" "$binary_url" "$HTTP_CLIENT"; then
        printf '%s\n' "Failed to download $repo_name binary from Packagecloud."
        exit 1
    fi

    printf '%s\n' "Downloaded $repo_name zip to $orb_bin_dir"
else
    printf '%s\n' "Skipping zip download since it already exists at $binary_zip."
fi

# Validate binary
## This validates, even if the binary already existed before.
## This can help with cache integrity but was also a convenience for testing where the binary will never be downloaded.
if [ -n "$input_sha256" ]; then
    actual_sha256=""
    actual_sha256=$(sha256sum "$binary_zip" | cut -d' ' -f1)

    if [ "$actual_sha256" != "$input_sha256" ]; then
        print_error "SHA256 checksum does not match. Expected $input_sha256 but got $actual_sha256"
        exit 1
    else
        print_success "SHA256 checksum matches. Binary is valid."
    fi
else
    print_warn "SHA256 checksum not provided. Skipping validation."
fi

# Unzip binary
# Please someone explain this to me - only works if I UNZIP to the $orb_bin_dir
# Can't unzip to any other dest. then it fails. bad. wtf. If you can explain it, please let me know! Really.
printf '%s\n' "Unzip ${binary_zip}..."
if ! unzip -q "${binary_zip}" -d "$orb_bin_dir"; then
    print_error "Failed to unzip $binary_zip."
    exit 1
fi

printf '%s\n' "Making ${orb_bin_dir}/${binary_name} binary executable..."
if ! chmod +x "${orb_bin_dir}/${binary_name}"; then
    print_error "Failed to make ${orb_bin_dir}/${binary_name} binary executable."
    exit 1
fi

printf '%s\n' "Moving $binary_name to PATH and renaming to ${basic_name}..."
mkdir -p "$path_destination"
if ! mv "$orb_bin_dir/$binary_name" "${path_destination}/${basic_name}"; then
    print_error "Failed to move $orb_bin_dir/$binary_name binary executable."
    exit 1
fi

print_success "Successfully installed $basic_name."
exit 0
