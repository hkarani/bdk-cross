#!/bin/bash

BASE_PATH="$(pwd)"
library=$1
VERSION=${2:-"latest"}

cd src/*/rust || { echo "Failed to change directory"; exit 1; }
export IPHONEOS_DEPLOYMENT_TARGET=10.0

package_name_line=$(grep -m 1 -E '^name = .*' Cargo.toml)

if [ ! -z "$package_name_line" ]; then
    package_name=$(echo "$package_name_line" | cut -d '=' -f2 | tr -d '[:space:]' | sed 's/^"//' | sed 's/"$//')
else
    echo "Error: Could not find 'name' in [package] section"
    exit 1
fi

cargo install cargo-lipo
rustup target add aarch64-apple-ios-sim
cargo build --release --target aarch64-apple-ios-sim


file=$(ls $BASE_PATH/src/*/rust/target/aarch64-apple-ios-sim/release/*.a | head -n 1)  # Get the first `.a` file
mkdir -p "$BASE_PATH/release/$library/$VERSION/ios/aarch64-apple-ios-sim"
mv "$file" "$BASE_PATH/release/$library/$VERSION/ios/aarch64-apple-ios-sim/aarch64-apple-ios-sim_lib$package_name.a"
echo "Build completed"