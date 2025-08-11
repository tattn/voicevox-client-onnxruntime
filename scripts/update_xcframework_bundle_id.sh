#!/bin/bash

set -e

# Check arguments
if [ $# -eq 0 ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 1.17.3"
    exit 1
fi

# Version from argument
ONNXRUNTIME_VERSION="$1"

# URLs and file names based on version
DOWNLOAD_URL="https://github.com/VOICEVOX/onnxruntime-builder/releases/download/voicevox_onnxruntime-${ONNXRUNTIME_VERSION}/voicevox_onnxruntime-ios-xcframework-${ONNXRUNTIME_VERSION}.zip"
ORIGINAL_ZIP="voicevox_onnxruntime-ios-xcframework-${ONNXRUNTIME_VERSION}.zip"
NEW_BUNDLE_ID="com.github.tattn.voicevox-client.onnxruntime"
OUTPUT_ZIP="voicevox_onnxruntime-ios-xcframework-${ONNXRUNTIME_VERSION}-modified.zip"
TEMP_DIR="temp_xcframework"

echo "📦 Processing ONNX Runtime version: ${ONNXRUNTIME_VERSION}"

echo "🔄 Downloading xcframework..."
curl -L -o "$ORIGINAL_ZIP" "$DOWNLOAD_URL"

echo "📦 Extracting zip file..."
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"
unzip -q "$ORIGINAL_ZIP" -d "$TEMP_DIR"

echo "🔍 Finding and updating bundle IDs in Info.plist files..."
# Find all Info.plist files in the xcframework
find "$TEMP_DIR" -name "Info.plist" -type f | while read -r plist; do
    echo "  Updating: $plist"
    # Check if CFBundleIdentifier exists and update it
    if /usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$plist" >/dev/null 2>&1; then
        /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $NEW_BUNDLE_ID" "$plist"
        echo "  ✅ Updated bundle ID to: $NEW_BUNDLE_ID"
    fi
done

echo "🗜️ Creating new zip file..."
cd "$TEMP_DIR"
zip -q -r "../$OUTPUT_ZIP" .
cd ..

echo "🧹 Cleaning up..."
rm -rf "$TEMP_DIR"
rm -f "$ORIGINAL_ZIP"

echo "✅ Done! New xcframework with updated bundle ID saved as: $OUTPUT_ZIP"
echo "   Bundle ID changed to: $NEW_BUNDLE_ID"