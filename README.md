# 👶 StuntingGuard AI - Deteksi Stunting Anak (YOLO & WHO LMS)

Aplikasi deteksi dini risiko stunting pada balita berbasis kecerdasan buatan (Computer Vision / YOLO) dan standar antropometri pertumbuhan anak **World Health Organization (WHO Child Growth Standards)**.

---

## 🌟 Fitur Utama

1. **AI Vision & Pengukuran Antropometri (YOLO):**
   - Estimasi panjang/tinggi badan balita secara instan melalui kamera ponsel / webcam.
   - Bounding box deteksi tubuh & kalkulasi visual presisi.

2. **Kalkulator Z-Score WHO LMS:**
   - Evaluasi indeks *Length/Height-for-Age (TB/U)* otomatis.
   - Klasifikasi status gizi: *Tinggi*, *Normal*, *Severely Stunted*, atau *Stunted*.

3. **Multi-Role Portal:**
   - 👨‍👩‍👧 **Portal Orang Tua:** Deteksi mandiri, riwayat tumbuh kembang, grafik z-score, rekomendasi menu gizi harian, dan konsultasi dokter.
   - 👨‍⚕️ **Portal Dokter Spesialis Anak (Pakar):** Antrean validasi kasus realtime, pemeriksaan klinis, diagnosis, dan rekomendasi intervensi medis.
   - 🏛️ **Portal Administrator Dinas Kesehatan:** Dashboard sebaran kasus wilayah, pemantauan status posyandu, broadcast notifikasi massal, dan manajemen data tenaga pakar/dokter ahli.

4. **Database Realtime & Supabase:**
   - Sinkronisasi instan antar perangkat.
   - Autentikasi dan validasi kredensial pengguna terdaftar.

---

## 🚀 Memulai (Getting Started)

### Prasyarat:
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (versi 3.19 ke atas)
- [Dart SDK](https://dart.dev/get-dart)
- Web Browser (Chrome / Edge / Safari) atau Android / iOS Device

### Instalasi & Menjalankan:

1. **Clone repositori:**
   ```bash
   git clone https://github.com/Farididham/Stunting_Anak.git
   cd Stunting_Anak
   ```

2. **Unduh dependensi Flutter:**
   ```bash
   flutter pub get
   ```

3. **Jalankan aplikasi (Development):**
   - Menjalankan di Web:
     ```bash
     flutter run -d chrome
     ```
   - Menjalankan di Emulator/Device:
     ```bash
     flutter run
     ```

4. **Build Aplikasi Web:**
   ```bash
   flutter build web --release
   ```

---

## 📂 Struktur Direktori Proyek

```
Stunting_Anak/
├── assets/                  # Dataset WHO, model YOLO, dan gambar statis
├── data/                    # WHO Growth Reference CSV tables
├── lib/
│   ├── core/                # Tema warna (app_colors), konstanta
│   ├── models/              # Data model (Child, User, Expert, Notification)
│   ├── screens/             # UI layar (Auth, Parent, Expert, Admin)
│   ├── services/            # Antropometri WHO, Supabase & Realtime DB, Auth
│   └── main.dart            # Entry point aplikasi Flutter
├── web/                     # Web assets & runner
└── web_app/                 # Standalone web app portal interface
```

---

## 📄 Lisensi
Hak Cipta © 2026 **Farididham**. Dikembangkan untuk mitigasi dan percepatan penurunan stunting nasional.
