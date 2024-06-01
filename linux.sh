#!/bin/sh

set -e  # Exit on failure

# Check if docker is installed

if [ ! -x "$(command -v docker)" ]; then
    echo "docker is not installed"
    echo "installation instructions might be here: https://docs.docker.com/engine/install/"
    exit 0
fi

# Function to extract the package version from Cargo.toml
  # Use grep to find the line containing 'version' in Cargo.toml
cd src/bdk-flutter/rust
ls
version_line=$(grep -E '^version = .*' Cargo.toml)

# Extract the version string after the  '='
if [ ! -z "$version_line" ]; then
    version=$(echo "$version_line" | cut -d '=' -f2 | tr -d '[:space:]')
    package_version=$(echo "$version" | sed 's/^"//' | sed 's/"$//')
else
    echo "Error: Could not find 'version' in Cargo.toml"
fi

cd ../../../


# Print the version or handle errors
if [ ! -z "$package_version" ]; then
  echo "Package version: $package_version"
else
  echo "An error occurred while reading the version."
  exit 1  
fi



# Define target architectures

echo "Starting  $target build..."
docker build -t build-$target -f Dockerfile.$target .
echo "Build completed!"
echo "Running build-$target docker"
container_id=$(docker run -d build-$target) || fail "Failed to run container"
current_dir=$(pwd)
folder_name="lib/$target"

if [ -d "$folder_name" ]; then
    rm -rf "$folder_name"
fi
mkdir "$folder_name"

architecture="x86_64-unknown-linux-gnu"



full_path="/$current_dir/$folder_name"
docker cp -a $container_id:"/app/target/$architecture/release/libbdk_flutter.so" "$full_path/libbdk_flutter-$package_version.so"
echo "File copied"
docker kill $container_id
echo "build-$target container stoppped"

echo "Build completed! Libraries are in lib/linux * folders."
