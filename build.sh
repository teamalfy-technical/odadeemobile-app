#!/bin/bash
set -e

echo "Starting Odadee production build v1.2.0..."

# Clean Flutter pub cache to prevent corrupted dependencies
echo "Cleaning Flutter pub cache..."
flutter pub cache clean --force

# Clean previous build artifacts
echo "Cleaning build artifacts..."
flutter clean

# Get fresh dependencies
echo "Installing dependencies..."
flutter pub get

# Build for web production
echo "Building for web (release mode)..."
flutter build web --release

# Verify build output
if [ -d "build/web" ]; then
  echo "✓ Build completed successfully!"
  echo "✓ Output directory: build/web"
  echo "✓ Ready for deployment"
else
  echo "✗ Build failed - output directory not found"
  exit 1
fi
