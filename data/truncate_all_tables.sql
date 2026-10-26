-- ============================================================================
-- SKRIP PENGOSONGAN DATABASE REALTIME SUPABASE (CLEAN SLATE / RESET)
-- StuntingGuard AI - Deteksi Stunting Anak berbasis YOLO & WHO LMS
-- ============================================================================
-- Jalankan skrip ini di SQL Editor Dashboard Supabase Anda untuk menghapus
-- seluruh data tersimpan (Detections, Notifications, Children, & Akun Orang Tua).
-- ============================================================================

-- 1. Matikan sementara trigger jika diperlukan
SET session_replication_role = 'replica';

-- 2. Kosongkan tabel riwayat pemeriksaan stunting YOLO
TRUNCATE TABLE public.stunting_detections CASCADE;

-- 3. Kosongkan tabel notifikasi realtime
TRUNCATE TABLE public.notifications CASCADE;

-- 4. Kosongkan data pendaftaran balita
TRUNCATE TABLE public.children CASCADE;

-- 5. Hapus akun orang tua non-sistem (Mempertahankan Akun Dokter & Admin Utama)
DELETE FROM public.registered_users WHERE role = 'parent';

-- 6. Nyalakan kembali trigger
SET session_replication_role = 'DEFAULT';

-- Konfirmasi status
SELECT 
    (SELECT COUNT(*) FROM public.children) AS sisa_balita,
    (SELECT COUNT(*) FROM public.stunting_detections) AS sisa_deteksi,
    (SELECT COUNT(*) FROM public.notifications) AS sisa_notifikasi,
    (SELECT COUNT(*) FROM public.registered_users) AS sisa_akun_sistem;
