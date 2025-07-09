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

# Create temporary directory for Flutter
FLUTTER_DIR="/tmp/flutter"
echo "📦 Installing Flutter SDK..."

# Download and extract Flutter
curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.19.6-stable.tar.xz | tar xJ -C /tmp

# Add Flutter to PATH
export PATH="$PATH:$FLUTTER_DIR/bin"

# Verify Flutter installation
echo "🔍 Verifying Flutter installation..."
flutter --version

# Disable analytics and reporting
flutter config --no-analytics

# Accept licenses
echo "📋 Accepting Flutter licenses..."
yes | flutter doctor --android-licenses || true

# Run Flutter doctor
echo "🩺 Running Flutter doctor..."
flutter doctor

# Get dependencies
echo "📚 Getting Flutter dependencies..."
flutter pub get

# Clean any previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Build web app
echo "🏗️  Building Flutter web app..."
flutter build web --release --web-renderer html

echo "✅ Build completed successfully!"
echo "📁 Build output is in: build/web/" 