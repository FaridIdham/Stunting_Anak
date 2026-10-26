#!/bin/bash
# ========================================================
# Script Otomatis Pemasangan Flutter SDK di macOS
# ========================================================
set -e

echo "🔍 Memeriksa arsitektur Mac..."
ARCH=$(uname -m)
INSTALL_DIR="$HOME/development"

if [ "$ARCH" = "arm64" ]; then
    echo "🍏 Terdeteksi: Apple Silicon (M1/M2/M3/M4)"
    FLUTTER_ZIP="flutter_macos_arm64_3.19.6-stable.zip"
else
    echo "💻 Terdeteksi: Intel x86_64"
    FLUTTER_ZIP="flutter_macos_3.19.6-stable.zip"
fi

mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

if [ ! -d "flutter" ]; then
    echo "⬇️ Mengunduh Flutter SDK ($FLUTTER_ZIP)..."
    curl -O "https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/$FLUTTER_ZIP"
    
    echo "📦 Mengekstrak berkas SDK..."
    unzip -q "$FLUTTER_ZIP"
    rm "$FLUTTER_ZIP"
    echo "✅ Flutter SDK berhasil diekstrak di $INSTALL_DIR/flutter"
else
    echo "✅ Flutter SDK sudah ada di $INSTALL_DIR/flutter"
fi

# Mendaftarkan ke ~/.zshrc
if ! grep -q 'flutter/bin' "$HOME/.zshrc" 2>/dev/null; then
    echo "📝 Mendaftarkan Flutter ke ~/.zshrc..."
    echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> "$HOME/.zshrc"
    echo "✅ PATH berhasil diperbarui!"
fi

export PATH="$PATH:$HOME/development/flutter/bin"

echo "=========================================================="
echo "🎉 Pemasangan Selesai! Menjalankan verifikasi flutter doctor..."
echo "=========================================================="
flutter doctor -v
