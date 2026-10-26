-- =========================================================================
-- STUNTINGGUARD AI - SUPABASE POSTGRESQL REALTIME SCHEMA & POLICIES
-- Platform: Supabase (PostgreSQL 15+)
-- Deskripsi: Skema Tabel Realtime untuk Deteksi Stunting Anak (YOLO & WHO LMS)
-- =========================================================================

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =========================================================================
-- TABEL 1: registered_users (Pengguna Terdaftar: Orang Tua, Dokter, Admin)
-- =========================================================================
CREATE TABLE IF NOT EXISTS public.registered_users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(150) NOT NULL,
    email VARCHAR(150),
    role VARCHAR(20) NOT NULL CHECK (role IN ('parent', 'expert', 'admin')),
    sip_number VARCHAR(100), -- Khusus Dokter Ahli
    specialization VARCHAR(150), -- Khusus Dokter Spesialis
    assigned_region VARCHAR(150), -- Khusus Admin Dinas Kesehatan
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =========================================================================
-- TABEL 2: posyandu_centers (Daftar Posyandu & Faskes Wilayah)
-- =========================================================================
CREATE TABLE IF NOT EXISTS public.posyandu_centers (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    village VARCHAR(100) NOT NULL,
    subdistrict VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    schedule VARCHAR(100) DEFAULT 'Setiap Rabu ke-2 & ke-4',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =========================================================================
-- TABEL 3: children (Data Balita & Identitas Terintegrasi)
-- =========================================================================
CREATE TABLE IF NOT EXISTS public.children (
    id VARCHAR(100) PRIMARY KEY,
    parent_id VARCHAR(100) NOT NULL, -- Nomor HP atau User ID Orang Tua
    parent_name VARCHAR(150) NOT NULL,
    child_name VARCHAR(150) NOT NULL,
    nik VARCHAR(20) UNIQUE NOT NULL,
    gender CHAR(1) NOT NULL CHECK (gender IN ('L', 'P')),
    date_of_birth DATE NOT NULL,
    birth_weight_kg NUMERIC(4, 2) NOT NULL DEFAULT 3.10,
    birth_height_cm NUMERIC(4, 1) NOT NULL DEFAULT 49.0,
    address TEXT NOT NULL,
    posyandu_name VARCHAR(150) NOT NULL DEFAULT 'Posyandu Mawar Sejahtera',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexing untuk pencarian cepat NIK dan Parent
CREATE INDEX IF NOT EXISTS idx_children_nik ON public.children (nik);
CREATE INDEX IF NOT EXISTS idx_children_parent ON public.children (parent_id);

-- =========================================================================
-- TABEL 4: stunting_detections (Hasil Pemindaian YOLO & Z-Score WHO)
-- =========================================================================
CREATE TABLE IF NOT EXISTS public.stunting_detections (
    id VARCHAR(100) PRIMARY KEY,
    child_id VARCHAR(100) NOT NULL REFERENCES public.children(id) ON DELETE CASCADE,
    child_name VARCHAR(150) NOT NULL,
    age_months INT NOT NULL,
    gender CHAR(1) NOT NULL,
    measured_height_cm NUMERIC(5, 2) NOT NULL,
    measured_weight_kg NUMERIC(5, 2) NOT NULL,
    haz_score NUMERIC(5, 2) NOT NULL, -- TB/U Height-for-Age Z-Score
    waz_score NUMERIC(5, 2) NOT NULL, -- BB/U Weight-for-Age Z-Score
    status VARCHAR(30) NOT NULL CHECK (status IN ('normal', 'stunted', 'severelyStunted', 'tall')),
    yolo_confidence NUMERIC(4, 3) NOT NULL DEFAULT 0.950,
    validation_status VARCHAR(30) NOT NULL DEFAULT 'pending' CHECK (validation_status IN ('pending', 'approved', 'revisionRequired')),
    doctor_id VARCHAR(50),
    doctor_name VARCHAR(150),
    doctor_notes TEXT,
    nutritional_recommendations JSONB DEFAULT '[]'::JSONB,
    image_url TEXT,
    timestamp TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_detections_child ON public.stunting_detections (child_id);
CREATE INDEX IF NOT EXISTS idx_detections_status ON public.stunting_detections (status);
CREATE INDEX IF NOT EXISTS idx_detections_validation ON public.stunting_detections (validation_status);

-- =========================================================================
-- TABEL 5: notifications (Notifikasi Realtime Multiplatform)
-- =========================================================================
CREATE TABLE IF NOT EXISTS public.notifications (
    id VARCHAR(100) PRIMARY KEY,
    recipient_id VARCHAR(100) NOT NULL, -- Nomor HP, 'ALL_PARENTS', atau 'EXPERT'
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    related_child_id VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notif_recipient ON public.notifications (recipient_id);

-- =========================================================================
-- REALTIME SUBSCRIPTIONS (POSTGRES REPLICATION)
-- Mengaktifkan Supabase Realtime Listener untuk semua tabel
-- =========================================================================
ALTER PUBLICATION supabase_realtime ADD TABLE public.children;
ALTER PUBLICATION supabase_realtime ADD TABLE public.stunting_detections;
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
ALTER PUBLICATION supabase_realtime ADD TABLE public.registered_users;

-- =========================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =========================================================================
ALTER TABLE public.registered_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.children ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stunting_detections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Policy: Publik / Anonim dapat membaca dan menulis data (Full Access untuk demo Posyandu/Klinik)
CREATE POLICY "Public Read Access children" ON public.children FOR SELECT USING (true);
CREATE POLICY "Public Insert Access children" ON public.children FOR INSERT WITH CHECK (true);
CREATE POLICY "Public Update Access children" ON public.children FOR UPDATE USING (true);
CREATE POLICY "Public Delete Access children" ON public.children FOR DELETE USING (true);

CREATE POLICY "Public Read Access detections" ON public.stunting_detections FOR SELECT USING (true);
CREATE POLICY "Public Insert Access detections" ON public.stunting_detections FOR INSERT WITH CHECK (true);
CREATE POLICY "Public Update Access detections" ON public.stunting_detections FOR UPDATE USING (true);
CREATE POLICY "Public Delete Access detections" ON public.stunting_detections FOR DELETE USING (true);

CREATE POLICY "Public Read Access notifications" ON public.notifications FOR SELECT USING (true);
CREATE POLICY "Public Insert Access notifications" ON public.notifications FOR INSERT WITH CHECK (true);
CREATE POLICY "Public Update Access notifications" ON public.notifications FOR UPDATE USING (true);

CREATE POLICY "Public Read Access users" ON public.registered_users FOR SELECT USING (true);
CREATE POLICY "Public Insert Access users" ON public.registered_users FOR INSERT WITH CHECK (true);

-- =========================================================================
-- SEED DATA AWAL (INITIAL DEMO DATA)
-- =========================================================================
INSERT INTO public.posyandu_centers (id, name, village, subdistrict, city, schedule)
VALUES ('POSYANDU-001', 'Posyandu Mawar Sejahtera', 'Kelurahan Melati Indah', 'Kecamatan Sejahtera', 'Kota Bandung', 'Setiap Rabu ke-2 & ke-4')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.registered_users (phone, name, email, role, sip_number, specialization, assigned_region)
VALUES 
('081234567890', 'Siti Rahmawati', 'siti.rahmawati@gmail.com', 'parent', NULL, NULL, NULL),
('081198765432', 'dr. Farhan Malik, Sp.A (K)', 'dr.farhan@rumahsakit.id', 'expert', 'SIP.440/129/DINKES/2024', 'Dokter Spesialis Anak - Konsultan Nutrisi & Metabolik', NULL),
('081388776655', 'Administrator Dinas Kesehatan', 'admin@dinkes.go.id', 'admin', NULL, NULL, 'Pusat Pengendalian Stunting Terpadu Nasional')
ON CONFLICT (phone) DO NOTHING;

INSERT INTO public.children (id, parent_id, parent_name, child_name, nik, gender, date_of_birth, birth_weight_kg, birth_height_cm, address, posyandu_name)
VALUES 
('CHILD-001', '081234567890', 'Siti Rahmawati', 'Muhammad Rayyan', '3201289100010002', 'L', '2025-04-26', 3.10, 49.5, 'Jl. Melati No. 14, RT 03/RW 02', 'Posyandu Mawar Sejahtera'),
('CHILD-002', '081234567890', 'Siti Rahmawati', 'Aisyah Putri', '3201289100010003', 'P', '2024-10-26', 2.90, 48.0, 'Jl. Melati No. 14, RT 03/RW 02', 'Posyandu Mawar Sejahtera')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.stunting_detections (id, child_id, child_name, age_months, gender, measured_height_cm, measured_weight_kg, haz_score, waz_score, status, yolo_confidence, validation_status, doctor_id, doctor_name, doctor_notes, nutritional_recommendations)
VALUES 
('SCAN-DEMO-01', 'CHILD-001', 'Muhammad Rayyan', 18, 'L', 76.50, 9.20, -2.12, -1.35, 'stunted', 0.974, 'approved', 'DOC-01', 'dr. Farhan Malik, Sp.A (K)', 'Diagnosis terverifikasi. Tingkatkan asupan telur 2 butir/hari & jadwalkan timbang ulang 14 hari.', '["Tingkatkan konsumsi protein hewani tinggi (telur 2 butir/hari, ikan kembung)", "Suplementasi Zinc 20 mg/hari selama 14 hari", "Jadwalkan pemantauan berkala tinggi badan tiap 2 minggu"]'::JSONB),
('SCAN-DEMO-02', 'CHILD-002', 'Aisyah Putri', 24, 'P', 87.00, 11.50, 0.18, 0.22, 'normal', 0.981, 'approved', 'DOC-01', 'dr. Farhan Malik, Sp.A (K)', 'Pertumbuhan sangat ideal sesuai kurva KMS WHO 2006.', '["Pertahankan menu gizi seimbang Isi Piringku", "Lanjutkan konsumsi susu pertumbuhan & vitamin"]'::JSONB)
ON CONFLICT (id) DO NOTHING;
