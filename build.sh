#!/bin/bash
set -e

echo "Starting production build process..."

# Clean Flutter pub cache to prevent corrupted dependencies
echo "Cleaning Flutter pub cache..."
echo y | flutter pub cache clean

# Clean previous build artifacts
echo "Cleaning build artifacts..."
flutter clean

# Get fresh dependencies
echo "Installing dependencies..."
flutter pub get

# Build for web production
echo "Building for web (release mode)..."
flutter build web --release

echo "Build completed successfully!"
