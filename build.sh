#!/bin/bash
set -e

echo "🚀 Starting Flutter web build process..."

# Create .env file from environment variables for Flutter
echo "🔧 Setting up environment variables..."
cat > .env << EOF
OPENAI_API_KEY=${OPENAI_API_KEY}
OPENAI_MODEL=${OPENAI_MODEL:-gpt-3.5-turbo}
GOOGLE_WEB_CLIENT_ID=${GOOGLE_WEB_CLIENT_ID}
EOF

echo "✅ Environment variables configured"

# Download and install Flutter SDK
FLUTTER_DIR="/tmp/flutter"
echo "📦 Downloading Flutter SDK..."

if [ ! -d "$FLUTTER_DIR" ]; then
    curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.19.6-stable.tar.xz | tar xJ -C /tmp
    echo "✅ Flutter SDK downloaded and extracted"
else
    echo "✅ Flutter SDK already exists"
fi

# Add Flutter to PATH
export PATH="$PATH:$FLUTTER_DIR/bin"

# Fix Git ownership issues in CI environment
echo "🔧 Fixing Git ownership for Flutter SDK..."
git config --global --add safe.directory /tmp/flutter
git config --global --add safe.directory '*'

# Verify Flutter installation
echo "🔍 Verifying Flutter installation..."
flutter --version

# Configure Flutter for web-only build
echo "🌐 Configuring Flutter for web..."
flutter config --no-analytics
flutter config --enable-web

# Get dependencies
echo "📚 Getting Flutter dependencies..."
flutter pub get

# Clean any previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Build web app
echo "🏗️  Building Flutter web app..."
flutter build web --release --web-renderer canvaskit

echo "✅ Build completed successfully!"
echo "📁 Build output is in: build/web/" 