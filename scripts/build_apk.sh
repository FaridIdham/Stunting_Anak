#!/bin/bash
# ========================================================
# Script Build APK Android (StuntingGuard AI)
# ========================================================
set -e

echo "🚀 [1/4] Memeriksa Flutter SDK..."
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter SDK belum ditemukan di PATH."
    echo "💡 Silakan pasang Flutter SDK atau jalankan: ./scripts/install_flutter_mac.sh"
    exit 1
fi

echo "📦 [2/4] Mengunduh dependensi (flutter pub get)..."
flutter pub get

echo "🧹 [3/4] Membersihkan build cache sebelumnya..."
flutter clean
flutter pub get

echo "🔨 [4/4] Mengompilasi Android APK (Release Mode)..."
flutter build apk --release --split-per-abi=false

echo "=========================================================="
echo "✅ BERHASIL! Berkas APK telah dibuat di:"
echo "📂 build/app/outputs/flutter-apk/app-release.apk"
echo "=========================================================="
