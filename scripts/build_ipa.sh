#!/bin/bash
# ========================================================
# Script Build IPA iOS (StuntingGuard AI)
# ========================================================
set -e

echo "🚀 [1/5] Memeriksa Flutter SDK..."
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter SDK belum ditemukan di PATH."
    echo "💡 Silakan pasang Flutter SDK atau jalankan: ./scripts/install_flutter_mac.sh"
    exit 1
fi

echo "📦 [2/5] Mengunduh dependensi (flutter pub get)..."
flutter pub get

echo "🍏 [3/5] Menginstal CocoaPods iOS (pod install)..."
cd ios
pod install --repo-update || pod install
cd ..

echo "🔨 [4/5] Mengompilasi iOS Archive / IPA..."
# Opsi 1: Kompilasi IPA (Unsigned / Ad-hoc / Development)
flutter build ipa --no-codesign --release

echo "📦 [5/5] Membungkus payload menjadi .ipa..."
mkdir -p build/ios/ipa/Payload
cp -r build/ios/archive/Runner.xcarchive/Products/Applications/Runner.app build/ios/ipa/Payload/
cd build/ios/ipa
zip -r StuntingGuard_AI.ipa Payload
rm -rf Payload
cd ../../..

echo "=========================================================="
echo "✅ BERHASIL! Berkas IPA iOS telah dibuat di:"
echo "📂 build/ios/ipa/StuntingGuard_AI.ipa"
echo "=========================================================="
