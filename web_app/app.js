/**
 * STUNTINGGUARD AI - REALTIME APPLICATION ENGINE (v2.0)
 * 
 * Pembaruan Utama:
 * 1. Otentikasi Ketat via Nomor HP / WhatsApp:
 *    Pengguna/pasien WAJIB menggunakan nomor HP yang telah terdaftar.
 *    Jika nomor HP belum terdaftar, sistem secara tegas menolak dan memblokir akses ke menu utama.
 * 2. Universal Camera Engine (Mendukung Kamera HP & Kamera Laptop):
 *    Deteksi multi-kamera, toggle kamera depan (webcam/selfie) & kamera belakang HP,
 *    dropdown pemilih kamera, dan penanganan resolusi adaptif.
 * 3. Desain Ultra-Responsif untuk Semua Perangkat (HP, Tablet, Laptop, Desktop).
 */

// ==================== STATE MANAGEMENT & DATABASE REALTIME ====================
const DB = {
  // Pengguna Terdaftar Berdasarkan Nomor WhatsApp / HP (Hanya Akun Sistem Pakar & Admin)
  registeredUsers: {
    // 1. Akun Dokter Spesialis Anak Terdaftar
    '081198765432': {
      phone: '081198765432',
      name: 'dr. Farhan Malik, Sp.A (K)',
      email: 'dr.farhan@rumahsakit.id',
      role: 'expert',
      specialization: 'Dokter Spesialis Anak - Konsultan Nutrisi & Metabolik',
      sipNumber: 'SIP.440/129/DINKES/2024'
    },
    // 2. Akun Pakar Ahli Tumbuh Kembang Terdaftar
    '081299887766': {
      phone: '081299887766',
      name: 'Dr. dr. Anisa Putri, M.Kes, Sp.A',
      email: 'anisa.putri@fk-univ.ac.id',
      role: 'expert',
      specialization: 'Pakar Ahli Tumbuh Kembang & Deteksi Dini Stunting',
      sipNumber: 'SIP.440/215/DINKES/2023'
    },
    // 3. Akun Admin Satgas Stunting Terdaftar
    '081388776655': {
      phone: '081388776655',
      name: 'Administrator Dinas Kesehatan',
      email: 'admin@dinkes.go.id',
      role: 'admin',
      region: 'Pusat Pengendalian Stunting Terpadu Nasional'
    }
  },

  currentUser: null,

  // Database Balita (Tersedia data siap pakai untuk uji CRUD: Tambah, Edit, Hapus)
  children: [
    {
      id: 'c-101',
      childName: 'Muhammad Rayyan',
      nik: '3201281504240001',
      dob: '2025-04-15',
      gender: 'L',
      parentId: '081234567890',
      parentName: 'Bunda Siti Aminah',
      posyandu: 'Posyandu Mawar Sejahtera'
    },
    {
      id: 'c-102',
      childName: 'Aisyah Azzahra',
      nik: '3201282208240002',
      dob: '2024-08-22',
      gender: 'P',
      parentId: '082198765432',
      parentName: 'Bunda Dewi Lestari',
      posyandu: 'Posyandu Mawar Sejahtera'
    }
  ],

  // Riwayat Deteksi Stunting (Tersedia data siap pakai untuk uji Validasi, Edit, Hapus)
  detections: [
    {
      id: 'det-101',
      childId: 'c-101',
      childName: 'Muhammad Rayyan',
      ageMonths: 18,
      heightCm: 76.5,
      weightKg: 9.8,
      haz: -2.12,
      waz: -1.35,
      status: 'stunted',
      statusText: 'Stunting (Pendek)',
      confidence: 0.94,
      timestamp: '2026-10-26 10:15',
      validation: 'pending',
      doctorNotes: 'Rekomendasikan intervensi protein hewani 2 butir telur/hari & evaluasi 14 hari.'
    },
    {
      id: 'det-102',
      childId: 'c-102',
      childName: 'Aisyah Azzahra',
      ageMonths: 14,
      heightCm: 77.2,
      weightKg: 10.2,
      haz: 0.15,
      waz: 0.22,
      status: 'normal',
      statusText: 'Normal (Gizi Baik)',
      confidence: 0.96,
      timestamp: '2026-10-26 11:30',
      validation: 'approved',
      doctorNotes: 'Tumbuh kembang optimal sesuai kurva WHO. Pertahankan pola asuh gizi seimbang.'
    }
  ],

  // Notifikasi Realtime
  notifications: [
    {
      id: 'notif-1',
      title: 'Hasil Pemeriksaan YOLO Siap',
      message: 'Deteksi stunting Muhammad Rayyan telah dihitung: TB 76.5 cm, Z-Score: -2.12 SD.',
      time: '10:16',
      read: false
    }
  ],

  // Database Pakar Ahli & Dokter Spesialis (Pakar Medis Stunting)
  experts: [
    {
      id: 'doc-01',
      name: 'dr. Farhan Malik, Sp.A (K)',
      titleRole: 'Pakar Ahli Pediatri & Spesialis Anak Konsultan',
      phone: '081198765432',
      email: 'dr.farhan@rumahsakit.id',
      sipNumber: 'SIP.440/129/DINKES/2024',
      nidn: '0012058501',
      institution: 'Fakultas Kedokteran UI / RS Hermina',
      specialization: 'Nutrisi & Penyakit Metabolik Anak',
      status: 'Aktif'
    },
    {
      id: 'doc-02',
      name: 'Dr. dr. Anisa Putri, M.Kes, Sp.A',
      titleRole: 'Pakar Ahli Tumbuh Kembang & Spesialis Anak',
      phone: '081299887766',
      email: 'anisa.putri@fk-univ.ac.id',
      sipNumber: 'SIP.440/215/DINKES/2023',
      nidn: '0028098203',
      institution: 'Fakultas Kedokteran / RSUP Nasional',
      specialization: 'Tumbuh Kembang & Deteksi Dini Stunting',
      status: 'Aktif'
    }
  ]
};

// Fungsi Kosongkan Seluruh Database Realtime
window.clearAllDatabase = function() {
  if (confirm('⚠️ PERINGATAN: Apakah Anda yakin ingin MENGHAPUS SEMUA DATA di database?\\n\\nSemua data balita, riwayat scan deteksi stunting, dan notifikasi akan dikosongkan secara permanen.')) {
    DB.children = [];
    DB.detections = [];
    DB.notifications = [];
    
    // Hapus akun orang tua non-sistem
    const systemPhones = ['081198765432', '081388776655'];
    for (const p in DB.registeredUsers) {
      if (!systemPhones.includes(p)) {
        delete DB.registeredUsers[p];
      }
    }
    
    // Simpan ke storage jika ada
    localStorage.removeItem('stunting_db_cache');
    
    // Re-render UI
    if (typeof renderAdminTable === 'function') renderAdminTable();
    if (typeof renderDoctorRecords === 'function') renderDoctorRecords();
    if (typeof updateAdminKPIs === 'function') updateAdminKPIs();
    if (typeof updateDoctorKPIs === 'function') updateDoctorKPIs();
    if (typeof renderNotifications === 'function') renderNotifications();
    
    alert('✅ Seluruh data database berhasil dikosongkan!');
  }
};

// ==================== ALGORITMA WHO LMS ANTHROPOMETRY ====================
const WHO_TABLE = {
  boys: {
    0:  [1.0, 49.9, 0.0379],
    6:  [1.0, 67.6, 0.0329],
    12: [1.0, 75.7, 0.0334],
    18: [1.0, 82.3, 0.0343],
    24: [1.0, 87.8, 0.0355],
    30: [1.0, 92.4, 0.0366],
    36: [1.0, 96.1, 0.0375],
    48: [1.0, 103.3, 0.0392],
    60: [1.0, 110.0, 0.0406],
  },
  girls: {
    0:  [1.0, 49.1, 0.0378],
    6:  [1.0, 65.7, 0.0328],
    12: [1.0, 74.0, 0.0335],
    18: [1.0, 80.7, 0.0346],
    24: [1.0, 86.4, 0.0359],
    30: [1.0, 91.2, 0.0371],
    36: [1.0, 95.1, 0.0381],
    48: [1.0, 102.7, 0.0398],
    60: [1.0, 109.4, 0.0413],
  }
};

function calculateWHO_HAZ(heightCm, ageMonths, gender) {
  const table = (gender === 'P') ? WHO_TABLE.girls : WHO_TABLE.boys;
  const keys = Object.keys(table).map(Number).sort((a,b) => a - b);
  
  let lower = keys[0];
  let upper = keys[keys.length - 1];
  for (let k of keys) {
    if (k <= ageMonths) lower = k;
    if (k >= ageMonths) { upper = k; break; }
  }

  let l, m, s;
  if (lower === upper) {
    [l, m, s] = table[lower];
  } else {
    const t = (ageMonths - lower) / (upper - lower);
    l = table[lower][0] + t * (table[upper][0] - table[lower][0]);
    m = table[lower][1] + t * (table[upper][1] - table[lower][1]);
    s = table[lower][2] + t * (table[upper][2] - table[lower][2]);
  }

  let z;
  if (Math.abs(l) < 0.01) {
    z = Math.log(heightCm / m) / s;
  } else {
    z = (Math.pow(heightCm / m, l) - 1.0) / (l * s);
  }

  return Number(z.toFixed(2));
}

function classifyStuntingStatus(haz) {
  if (haz < -3.0) {
    return {
      status: 'severe',
      text: 'Severely Stunted (Sangat Pendek / Parah)',
      badgeClass: 'status-severe',
      bannerClass: 'banner-severe',
      icon: '🚨'
    };
  } else if (haz < -2.0) {
    return {
      status: 'stunted',
      text: 'Stunting (Pendek)',
      badgeClass: 'status-stunted',
      bannerClass: 'banner-stunted',
      icon: '⚠️'
    };
  } else if (haz <= 2.0) {
    return {
      status: 'normal',
      text: 'Gizi Baik / Normal',
      badgeClass: 'status-normal',
      bannerClass: 'banner-normal',
      icon: '✅'
    };
  } else {
    return {
      status: 'tall',
      text: 'Tinggi (Di atas Rata-rata)',
      badgeClass: 'status-normal',
      bannerClass: 'banner-normal',
      icon: '🌟'
    };
  }
}

function generateNutritionalGuidance(status, ageMonths) {
  if (status === 'severe') {
    return [
      '🚨 Rujukan Segera: Kunjungi Dokter Spesialis Anak (Sp.A) di RSUD/Puskesmas untuk investigasi infeksi kronis.',
      '🥩 Asupan Protein Hewani Dosis Tinggi: Minimal 2 butir telur/hari, hati ayam, dan ikan kembung/salmon.',
      '🥛 Pemberian Pangan Medis Khusus (PKMK) Formula Padat Energi (F100) sesuai petunjuk dokter.',
      '💊 Suplementasi mikronutrien Zinc dan zat besi teratur.'
    ];
  } else if (status === 'stunted') {
    return [
      '⚠️ Intervensi Gizi 1000 HPK intensif mengejar ketertinggalan pertumbuhan (Catch-up growth).',
      '🍳 Tambahkan 1-2 butir telur per hari dan selingi daging sapi/ayam dalam menu MPASI.',
      '🥑 Tingkatkan densitas kalori MPASI dengan lemak sehat (minyak kelapa, santan matang, keju).',
      '📈 Pantau tinggi badan setiap 2 minggu sekali via aplikasi.'
    ];
  } else {
    return [
      '✅ Pertumbuhan balita optimal sesuai standar baku WHO 2006!',
      '🥗 Pertahankan gizi seimbang: Isi Piringku (1/3 karbohidrat, 1/3 protein hewani/nabati, 1/3 sayur-buah).',
      '🏃‍♂️ Pastikan durasi tidur malam minimal 10-11 jam untuk pelepasan hormon pertumbuhan.',
      '💉 Lengkapi imunisasi dasar di Posyandu terdekat.'
    ];
  }
}

// ==================== ALUR NAVIGASI & DEVICE MODES ====================
function navigateTo(screenId) {
  document.querySelectorAll('.screen').forEach(s => s.classList.remove('active'));
  const target = document.getElementById('screen-' + screenId);
  if (target) {
    target.classList.add('active');
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }

  if (screenId === 'yolo-scan') {
    initUniversalCamera();
  } else {
    stopCameraStream();
  }

  renderParentDashboard();
  renderDoctorDashboard();
  renderAdminDashboard();
}

function setDeviceView(mode) {
  const body = document.body;
  const btnMob = document.getElementById('btn-view-mobile');
  const btnTab = document.getElementById('btn-view-tablet');
  const btnDesk = document.getElementById('btn-view-desktop');

  body.classList.remove('device-mobile', 'device-tablet', 'device-desktop');
  btnMob.classList.remove('active');
  btnTab.classList.remove('active');
  btnDesk.classList.remove('active');

  if (mode === 'mobile') {
    body.classList.add('device-mobile');
    btnMob.classList.add('active');
    showToast('📱 Tampilan diubah ke Mode HP / Mobile (390px)');
  } else if (mode === 'tablet') {
    body.classList.add('device-tablet');
    btnTab.classList.add('active');
    showToast('📟 Tampilan diubah ke Mode Tablet / iPad (768px)');
  } else {
    body.classList.add('device-desktop');
    btnDesk.classList.add('active');
    showToast('💻 Tampilan diubah ke Mode Laptop / Layar Lebar');
  }
}

// ==================== ALUR 1: REGISTRASI ANAK & NOMOR HP ====================
function updateGenderChip(radio) {
  document.querySelectorAll('.gender-chip').forEach(c => c.classList.remove('active'));
  if (radio.value === 'L') {
    document.getElementById('chip-male').classList.add('active');
  } else {
    document.getElementById('chip-female').classList.add('active');
  }
}

function cleanPhoneNumber(phone) {
  return phone.replace(/[^0-9]/g, '').trim();
}

function handleRegistration(e) {
  e.preventDefault();

  const parentName = document.getElementById('reg-parent-name').value.trim();
  const rawPhone = document.getElementById('reg-parent-phone').value.trim();
  const email = document.getElementById('reg-parent-email').value.trim();
  const phone = cleanPhoneNumber(rawPhone);

  const childName = document.getElementById('reg-child-name').value.trim();
  const nik = document.getElementById('reg-child-nik').value.trim();
  const gender = document.querySelector('input[name="reg-gender"]:checked').value;
  const dob = document.getElementById('reg-child-dob').value;
  const weight = parseFloat(document.getElementById('reg-child-birth-weight').value) || 3.1;
  const height = parseFloat(document.getElementById('reg-child-birth-height').value) || 49.5;
  const posyandu = document.getElementById('reg-posyandu').value.trim();
  const address = document.getElementById('reg-address').value.trim();

  const password = document.getElementById('reg-parent-password').value.trim();

  // 1. Simpan Akun Terdaftar Berdasarkan Nomor WhatsApp / HP beserta Kata Sandi
  DB.registeredUsers[phone] = {
    phone: phone,
    password: password,
    name: parentName,
    email: email,
    role: 'parent',
    childId: 'CHILD-' + Date.now()
  };

  // 2. Simpan Data Balita
  const newChild = {
    id: DB.registeredUsers[phone].childId,
    parentId: phone,
    parentName: parentName,
    childName: childName,
    nik: nik,
    gender: gender,
    dateOfBirth: dob || '2025-04-26',
    birthWeight: weight,
    birthHeight: height,
    posyandu: posyandu,
    address: address
  };
  DB.children.unshift(newChild);

  addNotification({
    type: 'system',
    title: '🎉 Registrasi Berhasil!',
    message: `Nomor HP ${phone} dan balita ${childName} telah terdaftar. Silakan login menggunakan nomor HP Anda.`
  });

  showToast(`✅ Pendaftaran Berhasil! Nomor HP ${phone} siap digunakan login.`);

  // Sesuai instruksi: "setelah registrasi masuk ke fitur login"
  setTimeout(() => {
    document.getElementById('login-phone').value = phone;
    document.getElementById('login-error-banner').style.display = 'none';
    switchLoginRole('parent');
    navigateTo('login');
  }, 900);
}

// ==================== ALUR 2: LOGIN VIA NOMOR HP / WHATSAPP DENGAN VALIDASI KETAT ====================
let selectedLoginRole = 'parent';

function switchLoginRole(role) {
  selectedLoginRole = role;
  document.querySelectorAll('.role-tab').forEach(t => t.classList.remove('active'));
  document.getElementById('login-error-banner').style.display = 'none';

  const phoneInput = document.getElementById('login-phone');
  const roleIcon = document.getElementById('login-role-icon');

  if (role === 'parent') {
    document.querySelector('.parent-tab').classList.add('active');
    phoneInput.value = '081234567890';
    roleIcon.textContent = '👨‍👩‍👦';
  } else if (role === 'expert') {
    document.querySelector('.expert-tab').classList.add('active');
    phoneInput.value = '081198765432';
    roleIcon.textContent = '👨‍⚕️';
  } else if (role === 'admin') {
    document.querySelector('.admin-tab').classList.add('active');
    phoneInput.value = '081388776655';
    roleIcon.textContent = '🏛️';
  }
}

function handleLogin(e) {
  e.preventDefault();

  const rawPhone = document.getElementById('login-phone').value.trim();
  const phone = cleanPhoneNumber(rawPhone);
  const password = document.getElementById('login-password').value.trim();
  const errorBanner = document.getElementById('login-error-banner');
  const errorText = document.getElementById('login-error-text');

  // ==================== 1. VALIDASI KETAT NOMOR HP TERDAFTAR ====================
  // "jika nomor hp tidak atau belum teregistrasi maka pengguna atau pasien tidak bisa lanjut atau login ke menu utama"
  if (!DB.registeredUsers[phone]) {
    errorBanner.style.display = 'flex';
    errorText.innerHTML = `Nomor HP / WhatsApp <strong>${rawPhone}</strong> belum terdaftar di sistem! Anda <u>tidak dapat lanjut ke menu utama</u> sebelum melakukan pendaftaran balita.`;
    showToast(`🚫 Akses ditolak: Nomor HP ${rawPhone} belum terdaftar!`);
    return; // DITOLAK MASUK!
  }

  const user = DB.registeredUsers[phone];

  // ==================== 2. VALIDASI KATA SANDI / PASSWORD ====================
  // "jika Nomor WhatsApp / HP Terdaftar dan password tidak sama dengan waktu melakukan registrasi atau data yang tersimpan di database maka tidak bisa login atau ulangi lagi"
  if (user.password && user.password !== password) {
    errorBanner.style.display = 'flex';
    errorText.innerHTML = `Kata sandi yang Anda masukkan salah atau <u>tidak sama</u> dengan data saat registrasi! Silakan periksa kembali dan <strong>ulangi lagi</strong>.`;
    showToast(`🔒 Kata sandi salah! Silakan ulangi lagi.`);
    return; // DITOLAK MASUK!
  }

  // Cek Kesesuaian Peran Hak Akses
  if (user.role !== selectedLoginRole) {
    const roleLabel = selectedLoginRole === 'parent' ? 'Orang Tua' : (selectedLoginRole === 'expert' ? 'Dokter Ahli' : 'Admin');
    errorBanner.style.display = 'flex';
    errorText.innerHTML = `Nomor HP ini terdaftar bukan sebagai hak akses <strong>${roleLabel}</strong>. Silakan pilih tab hak akses yang sesuai.`;
    return;
  }

  // Login Berhasil -> Sembunyikan pesan error
  errorBanner.style.display = 'none';
  DB.currentUser = user;

  const headerPill = document.getElementById('header-role-pill');
  const headerName = document.getElementById('header-user-name');

  // Masuk ke Fitur Utama
  if (selectedLoginRole === 'parent') {
    headerPill.className = 'role-pill pill-parent';
    headerPill.textContent = 'Akses: Orang Tua (Mobile)';
    headerName.textContent = `${user.name} (${user.phone})`;
    setDeviceView('mobile');
    navigateTo('parent');
    showToast(`👋 Selamat datang ${user.name}! Masuk ke Menu Utama Orang Tua.`);
  } else if (selectedLoginRole === 'expert') {
    headerPill.className = 'role-pill pill-expert';
    headerPill.textContent = 'Akses: Dokter Ahli (Web/Mob)';
    headerName.textContent = `${user.name} (${user.phone})`;
    setDeviceView('desktop');
    navigateTo('expert');
    showToast(`🩺 Masuk ke Portal Verifikasi Klinis Dokter.`);
  } else if (selectedLoginRole === 'admin') {
    headerPill.className = 'role-pill pill-admin';
    headerPill.textContent = 'Akses: Admin (Web/Mob)';
    headerName.textContent = `Admin (${user.phone})`;
    setDeviceView('desktop');
    navigateTo('admin');
    showToast(`🏛️ Masuk ke Portal Analitik Prevalensi Stunting.`);
  }
}

// ==================== ALUR 3: FITUR UTAMA ORANG TUA ====================
function renderParentDashboard() {
  const child = DB.children[0];
  if (!child) return;

  document.getElementById('parent-child-name').textContent = child.childName;
  document.getElementById('parent-child-nik').textContent = 'NIK: ' + child.nik.substring(0, 6) + '...';
  document.getElementById('parent-child-meta').textContent = `Usia: 18 Bulan • ${child.posyandu}`;
  document.getElementById('parent-hero-weight').textContent = child.birthWeight + ' kg';
  document.getElementById('parent-hero-height').textContent = child.birthHeight + ' cm';
  document.getElementById('parent-hero-gender').textContent = child.gender === 'L' ? 'Laki-laki' : 'Perempuan';
  document.getElementById('parent-child-avatar').textContent = child.gender === 'L' ? '👦' : '👧';

  const childScans = DB.detections.filter(d => d.childId === child.id);
  const historyContainer = document.getElementById('parent-history-list');
  historyContainer.innerHTML = '';

  if (childScans.length > 0) {
    const latest = childScans[0];
    document.getElementById('parent-stat-height').textContent = latest.heightCm + ' cm';
    document.getElementById('parent-stat-haz').textContent = latest.haz + ' SD';
    document.getElementById('parent-stat-weight').textContent = latest.weightKg + ' kg';

    const pill = document.getElementById('parent-status-pill');
    pill.className = 'status-pill status-' + latest.status;
    pill.textContent = latest.statusText;

    if (latest.doctorNotes) {
      document.getElementById('parent-doc-banner').style.display = 'flex';
      document.getElementById('parent-doc-note').textContent = `"${latest.doctorNotes}" (${latest.doctorName})`;
    }

    childScans.forEach(item => {
      const card = document.createElement('div');
      card.className = 'history-card';
      const isNorm = item.status === 'normal';
      card.innerHTML = `
        <div class="hist-icon" style="background:${isNorm ? '#D1FAE5' : '#FEF3C7'}; color:${isNorm ? '#059669' : '#D97706'}">
          ${isNorm ? '✅' : '⚠️'}
        </div>
        <div class="hist-info">
          <strong>${item.heightCm} cm • ${item.statusText}</strong>
          <p>Z-Score HAZ: ${item.haz} SD • Akurasi YOLO: ${(item.confidence * 100).toFixed(1)}%</p>
        </div>
        <span class="status-pill ${item.validation === 'approved' ? 'status-normal' : 'status-stunted'}" style="font-size:10px;">
          ${item.validation === 'approved' ? 'Terverifikasi' : 'Pending Dokter'}
        </span>
      `;
      historyContainer.appendChild(card);
    });

    document.getElementById('history-count').textContent = childScans.length + ' Data';
  }
}

// ==================== ALUR 4: UNIVERSAL CAMERA ENGINE (HP & LAPTOP) ====================
let currentCameraStream = null;
let currentFacingMode = 'user'; // 'user' (Webcam Laptop / Kamera Depan HP) atau 'environment' (Kamera Belakang HP)
let availableVideoDevices = [];
let selectedCameraDeviceId = null;
let yoloAnimationId = null;
let currentPoseSample = 'stunted';

async function initUniversalCamera() {
  await enumerateCameraDevices();
  await startCameraStream();
  initYoloCanvasVisualizer();
}

async function enumerateCameraDevices() {
  const select = document.getElementById('camera-select-dropdown');
  select.innerHTML = '';

  if (!navigator.mediaDevices || !navigator.mediaDevices.enumerateDevices) {
    select.innerHTML = '<option value="">Kamera Default</option>';
    return;
  }

  try {
    const devices = await navigator.mediaDevices.enumerateDevices();
    availableVideoDevices = devices.filter(d => d.kind === 'videoinput');

    if (availableVideoDevices.length === 0) {
      select.innerHTML = '<option value="">Kamera Virtual / AI Simulator</option>';
      return;
    }

    availableVideoDevices.forEach((dev, idx) => {
      const opt = document.createElement('option');
      opt.value = dev.deviceId;
      opt.textContent = dev.label || `Kamera ${idx + 1} (${idx === 0 ? 'Laptop / Depan' : 'Belakang HP'})`;
      select.appendChild(opt);
    });
  } catch (err) {
    console.warn('Gagal membaca daftar kamera:', err);
  }
}

async function startCameraStream(deviceId = null) {
  stopCameraStream();

  const video = document.getElementById('webcam-video');
  const statusText = document.getElementById('camera-status-text');

  // Konfigurasi Constraints Kompatibel untuk Kamera HP & Kamera Laptop
  let constraints = {
    video: {
      width: { ideal: 1280 },
      height: { ideal: 720 }
    },
    audio: false
  };

  if (deviceId) {
    constraints.video.deviceId = { exact: deviceId };
  } else {
    constraints.video.facingMode = currentFacingMode;
  }

  try {
    currentCameraStream = await navigator.mediaDevices.getUserMedia(constraints);
    video.srcObject = currentCameraStream;
    statusText.textContent = `Kamera Aktif: ${currentFacingMode === 'user' ? 'Kamera Depan / Laptop Webcam' : 'Kamera Belakang HP'}`;
    document.getElementById('camera-label-mode').textContent = currentFacingMode === 'user' ? 'Kamera Depan / Laptop' : 'Kamera Belakang HP';
  } catch (err) {
    console.warn('Mencoba fallback mode fleksibel kamera:', err);
    try {
      // Fallback tanpa constraints ketat
      currentCameraStream = await navigator.mediaDevices.getUserMedia({ video: true, audio: false });
      video.srcObject = currentCameraStream;
      statusText.textContent = 'Kamera Aktif (Mode Universal)';
    } catch (fallbackErr) {
      statusText.textContent = 'Simulasi Pose AI Aktif (Kamera Fisik Tidak Ditemukan)';
      showToast('ℹ️ Menggunakan simulator AI YOLO (Kamera fisik offline/tidak terdeteksi).');
    }
  }
}

function stopCameraStream() {
  if (currentCameraStream) {
    currentCameraStream.getTracks().forEach(track => track.stop());
    currentCameraStream = null;
  }
}

// Beralih antara Kamera Depan (Laptop/Selfie) dan Kamera Belakang (HP)
function switchCameraSource() {
  currentFacingMode = (currentFacingMode === 'user') ? 'environment' : 'user';
  startCameraStream();
  showToast(`🔄 Beralih ke: ${currentFacingMode === 'user' ? 'Kamera Depan / Laptop Webcam' : 'Kamera Belakang HP'}`);
}

function onCameraDeviceSelected(deviceId) {
  selectedCameraDeviceId = deviceId;
  startCameraStream(deviceId);
  showToast('📷 Perangkat kamera diperbarui.');
}

// Visualisasi Rangka Pose YOLO 17 Titik di Canvas
function initYoloCanvasVisualizer() {
  const canvas = document.getElementById('yolo-canvas');
  if (!canvas) return;
  const ctx = canvas.getContext('2d');

  function resize() {
    canvas.width = canvas.parentElement.clientWidth;
    canvas.height = canvas.parentElement.clientHeight;
  }
  resize();

  let phase = 0;
  function drawPose() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    const w = canvas.width;
    const h = canvas.height;
    phase += 0.04;

    const midX = w * 0.5;
    const headTop = { x: midX, y: h * 0.16 + Math.sin(phase) * 3 };
    const neck = { x: midX, y: h * 0.25 };
    const lShoulder = { x: midX - w * 0.14, y: h * 0.27 };
    const rShoulder = { x: midX + w * 0.14, y: h * 0.27 };
    const spineMid = { x: midX, y: h * 0.42 };
    const lHip = { x: midX - w * 0.11, y: h * 0.54 };
    const rHip = { x: midX + w * 0.11, y: h * 0.54 };
    const lKnee = { x: midX - w * 0.10, y: h * 0.72 };
    const rKnee = { x: midX + w * 0.10, y: h * 0.72 };
    const lAnkle = { x: midX - w * 0.09, y: h * 0.88 };
    const rAnkle = { x: midX + w * 0.09, y: h * 0.88 };

    // Garis Rangka Pose (Cyan Neon Glowing)
    ctx.strokeStyle = '#06B6D4';
    ctx.lineWidth = 3.5;
    ctx.shadowColor = '#06B6D4';
    ctx.shadowBlur = 10;

    function line(p1, p2) {
      ctx.beginPath();
      ctx.moveTo(p1.x, p1.y);
      ctx.lineTo(p2.x, p2.y);
      ctx.stroke();
    }

    line(headTop, neck);
    line(lShoulder, rShoulder);
    line(neck, spineMid);
    line(spineMid, lHip);
    line(spineMid, rHip);
    line(lShoulder, lHip);
    line(rShoulder, rHip);
    line(lHip, lKnee);
    line(rHip, rKnee);
    line(lKnee, lAnkle);
    line(rKnee, rAnkle);

    // Titik-titik Anatomi Sendi
    const joints = [headTop, neck, lShoulder, rShoulder, spineMid, lHip, rHip, lKnee, rKnee, lAnkle, rAnkle];
    joints.forEach(j => {
      ctx.beginPath();
      ctx.arc(j.x, j.y, 6.5, 0, Math.PI * 2);
      ctx.fillStyle = '#38BDF8';
      ctx.fill();
      ctx.beginPath();
      ctx.arc(j.x, j.y, 9, 0, Math.PI * 2);
      ctx.strokeStyle = '#FFFFFF';
      ctx.lineWidth = 1.5;
      ctx.stroke();
    });

    // YOLO Bounding Box & Label
    ctx.shadowBlur = 0;
    ctx.strokeStyle = '#10B981';
    ctx.lineWidth = 2;
    const boxX = midX - w * 0.24;
    const boxY = h * 0.12;
    const boxW = w * 0.48;
    const boxH = h * 0.80;
    ctx.strokeRect(boxX, boxY, boxW, boxH);

    ctx.fillStyle = '#10B981';
    ctx.fillRect(boxX, boxY - 24, 160, 24);
    ctx.fillStyle = '#FFFFFF';
    ctx.font = 'bold 11px Plus Jakarta Sans, sans-serif';
    ctx.fillText('child_posture: 98.2%', boxX + 6, boxY - 7);

    yoloAnimationId = requestAnimationFrame(drawPose);
  }

  if (yoloAnimationId) cancelAnimationFrame(yoloAnimationId);
  drawPose();
}

function loadSampleImage(type) {
  currentPoseSample = type;
  showToast(type === 'stunted' ? '📸 Sampel: Balita 18 Bulan (Stunting - 76.5cm)' : '📸 Sampel: Balita 24 Bulan (Normal - 87.0cm)');
}

function handleImageUpload(e) {
  if (e.target.files && e.target.files[0]) {
    showToast('📸 Foto galeri berhasil dimuat ke viewport inferensi YOLO.');
  }
}

function runYoloInference() {
  const btn = document.getElementById('btn-run-yolo');
  btn.style.transform = 'scale(0.9)';
  showToast('⚡ Mengeksekusi Deep Neural Network YOLOv11-Pose...');

  setTimeout(() => {
    btn.style.transform = '';

    const child = DB.children[0];
    let measuredHeight, estimatedWeight;

    if (currentPoseSample === 'stunted') {
      measuredHeight = 76.4;
      estimatedWeight = 9.2;
    } else {
      measuredHeight = 82.5;
      estimatedWeight = 10.8;
    }

    const haz = calculateWHO_HAZ(measuredHeight, 18, child.gender);
    const classification = classifyStuntingStatus(haz);
    const recommendations = generateNutritionalGuidance(classification.status, 18);

    const newDetection = {
      id: 'SCAN-' + Date.now(),
      childId: child.id,
      childName: child.childName,
      ageMonths: 18,
      gender: child.gender,
      heightCm: measuredHeight,
      weightKg: estimatedWeight,
      haz: haz,
      status: classification.status,
      statusText: classification.text,
      confidence: 0.982,
      validation: 'pending',
      timestamp: new Date().toISOString()
    };

    DB.detections.unshift(newDetection);

    if (classification.status === 'severe' || classification.status === 'stunted') {
      addNotification({
        type: 'alert',
        title: `⚠️ Indikasi ${classification.text}: ${child.childName}`,
        message: `Tinggi badan ${measuredHeight} cm (Z-Score: ${haz} SD). Rekam medis diteruskan ke antrean Dokter Spesialis Anak.`
      });
    } else {
      addNotification({
        type: 'nutrition',
        title: `✅ Pertumbuhan Baik: ${child.childName}`,
        message: `Tinggi badan ${measuredHeight} cm berada dalam kurva normal WHO (Z-Score: ${haz} SD).`
      });
    }

    showDetectionResult(newDetection, classification, recommendations);
  }, 1200);
}

// ==================== ALUR 5: HASIL DETEKSI STUNTING ====================
function showDetectionResult(det, classification, recommendations) {
  const banner = document.getElementById('result-status-banner');
  banner.className = 'result-status-banner ' + classification.bannerClass;
  document.getElementById('result-status-icon').textContent = classification.icon;
  document.getElementById('result-status-title').textContent = classification.text;
  document.getElementById('result-patient-name').textContent = `Pasien: ${det.childName} (${det.ageMonths} Bulan)`;

  document.getElementById('result-haz-val').textContent = det.haz + ' SD';
  document.getElementById('res-metric-height').textContent = det.heightCm + ' cm';
  document.getElementById('res-metric-weight').textContent = det.weightKg + ' kg';
  document.getElementById('res-metric-conf').textContent = (det.confidence * 100).toFixed(1) + '%';
  document.getElementById('res-metric-status').textContent = 'Pending (Menunggu Dokter)';

  const pinPercent = Math.min(Math.max(((det.haz + 4) / 7) * 100, 5), 95);
  document.getElementById('gauge-pin').style.left = pinPercent + '%';

  const recList = document.getElementById('result-rec-list');
  recList.innerHTML = '';
  recommendations.forEach(r => {
    const li = document.createElement('li');
    li.textContent = r;
    recList.appendChild(li);
  });

  navigateTo('result');
}

// ==================== ALUR 6: FITUR UTAMA DOKTER / PAKAR ====================
let currentDoctorFilter = 'ALL';
let activeValidatingDetectionId = null;

function renderDoctorDashboard() {
  // Update Header Info Pakar/Dokter Ahli Aktif
  const activeExpert = (DB.experts && DB.experts.length > 0) ? DB.experts[0] : null;
  const nameTitleEl = document.getElementById('expert-name-title');
  const subTitleEl = document.getElementById('expert-meta-subtitle');
  if (activeExpert && nameTitleEl) {
    nameTitleEl.textContent = activeExpert.name;
    if (subTitleEl) {
      subTitleEl.textContent = `${activeExpert.titleRole || 'Pakar Ahli Pediatri'} • SIP: ${activeExpert.sipNumber} • WhatsApp: ${activeExpert.phone}`;
    }
  }

  const total = DB.detections.length;
  const pending = DB.detections.filter(d => d.validation === 'pending').length;
  const verified = DB.detections.filter(d => d.validation === 'approved').length;

  document.getElementById('doc-kpi-total').textContent = total + ' Kasus';
  document.getElementById('doc-kpi-pending').textContent = pending + ' Pasien';
  document.getElementById('doc-kpi-verified').textContent = verified + ' Pasien';

  const listContainer = document.getElementById('doctor-queue-list');
  listContainer.innerHTML = '';

  let list = DB.detections;
  if (currentDoctorFilter === 'PENDING') {
    list = list.filter(d => d.validation === 'pending');
  } else if (currentDoctorFilter === 'APPROVED') {
    list = list.filter(d => d.validation === 'approved');
  }

  if (list.length === 0) {
    listContainer.innerHTML = `
      <div style="text-align: center; padding: 36px 16px; background: white; border-radius: 14px; border: 1px dashed #cbd5e1;">
        <div style="font-size: 32px; margin-bottom: 8px;">🩺</div>
        <div style="font-weight: 700; font-size: 15px; color: #1e293b; margin-bottom: 4px;">Tidak Ada Antrian Pasien</div>
        <p style="font-size: 12px; color: #64748b; margin-bottom: 14px;">Belum ada data pemeriksaan pasien yang memerlukan validasi atau tindakan.</p>
        <div style="display: flex; justify-content: center; gap: 10px; flex-wrap: wrap;">
          <button class="btn-primary-gradient" style="padding: 8px 16px; font-size: 12px;" onclick="openAddPatientModal()">+ Tambah Pasien Baru</button>
          <button class="btn-secondary" style="padding: 8px 16px; font-size: 12px;" onclick="loadDemoDetectionData()">📥 Muat Pasien Demo (Uji Hapus/Edit)</button>
        </div>
      </div>
    `;
    return;
  }

  list.forEach(item => {
    const card = document.createElement('div');
    card.className = 'queue-card card-' + item.status;
    card.innerHTML = `
      <div class="q-info">
        <div class="q-title-row">
          <h4>${item.childName}</h4>
          <span class="status-pill status-${item.status}">${item.statusText}</span>
        </div>
        <p class="q-meta">Usia: ${item.ageMonths} Bulan • TB: ${item.heightCm} cm • BB: ${item.weightKg} kg • Z-Score: <strong>${item.haz} SD</strong> • YOLO: ${(item.confidence * 100).toFixed(1)}%</p>
        ${item.doctorNotes ? `<p class="q-notes">Catatan: "${item.doctorNotes}"</p>` : ''}
      </div>
      <div class="queue-actions-group">
        <button class="btn-verify-action" onclick="openDoctorVerifyModal('${item.id}')">
          ${item.validation === 'approved' ? 'Ubah Catatan' : 'Validasi Medis'}
        </button>
        <button class="btn-action-edit" onclick="openEditDetectionModal('${item.id}')">
          ✏️ Edit
        </button>
        <button class="btn-action-delete" onclick="deleteDetectionItem('${item.id}')">
          🗑️ Hapus
        </button>
      </div>
    `;
    listContainer.appendChild(card);
  });
}

function filterDoctorQueue(filter) {
  currentDoctorFilter = filter;
  document.querySelectorAll('.q-filter').forEach(b => b.classList.remove('active'));
  event.target.classList.add('active');
  renderDoctorDashboard();
}

// ==================== OPERASI CRUD DOKTER: TAMBAH DATA PASIEN ====================
function openAddPatientModal() {
  document.getElementById('modal-add-patient').classList.add('active');
}

function closeAddPatientModal() {
  document.getElementById('modal-add-patient').classList.remove('active');
}

function submitAddPatient() {
  const name = document.getElementById('doc-new-child-name').value.trim();
  const age = parseInt(document.getElementById('doc-new-age').value) || 12;
  const gender = document.getElementById('doc-new-gender').value;
  const height = parseFloat(document.getElementById('doc-new-height').value) || 75.0;
  const weight = parseFloat(document.getElementById('doc-new-weight').value) || 9.0;
  const status = document.getElementById('doc-new-status').value;
  const notes = document.getElementById('doc-new-notes').value.trim();

  if (!name) {
    showToast('⚠️ Nama pasien balita wajib diisi!');
    return;
  }

  const statusTextMap = {
    'stunted': 'Stunting (Pendek)',
    'severe': 'Stunting Berat (Sangat Pendek)',
    'normal': 'Normal (Gizi Baik)',
    'tall': 'Tinggi'
  };

  const hazMap = {
    'stunted': -2.35,
    'severe': -3.42,
    'normal': 0.15,
    'tall': 2.15
  };

  const newDet = {
    id: 'DET-' + Date.now(),
    childId: 'CHILD-' + Date.now(),
    childName: name,
    ageMonths: age,
    gender: gender,
    heightCm: height,
    weightKg: weight,
    haz: hazMap[status] || -2.1,
    status: status,
    statusText: statusTextMap[status] || 'Stunting',
    confidence: 0.965,
    validation: notes ? 'approved' : 'pending',
    doctorNotes: notes || '',
    doctorName: 'dr. Farhan Malik, Sp.A (K)',
    timestamp: new Date().toISOString()
  };

  DB.detections.unshift(newDet);

  // Kirim notifikasi realtime
  addNotification({
    type: 'doctor',
    title: '🏥 Pasien Baru Ditambahkan',
    message: `Data pemeriksaan balita ${name} (${age} Bulan) berhasil dicatat oleh dokter ke database realtime.`
  });

  closeAddPatientModal();
  renderDoctorDashboard();
  renderAdminDashboard();
  showToast(`✅ Pasien "${name}" berhasil ditambahkan ke database realtime!`);
}

// ==================== OPERASI CRUD DOKTER: EDIT DATA PASIEN ====================
function openEditDetectionModal(detId) {
  const item = DB.detections.find(d => d.id === detId);
  if (!item) return;

  document.getElementById('edit-det-id').value = item.id;
  document.getElementById('edit-det-name').value = item.childName;
  document.getElementById('edit-det-age').value = item.ageMonths;
  document.getElementById('edit-det-height').value = item.heightCm;
  document.getElementById('edit-det-weight').value = item.weightKg;
  document.getElementById('edit-det-haz').value = item.haz;
  document.getElementById('edit-det-status').value = item.status;
  document.getElementById('edit-det-notes').value = item.doctorNotes || '';

  document.getElementById('modal-edit-detection').classList.add('active');
}

function closeEditDetectionModal() {
  document.getElementById('modal-edit-detection').classList.remove('active');
}

function submitEditDetection() {
  const id = document.getElementById('edit-det-id').value;
  const item = DB.detections.find(d => d.id === id);
  if (!item) return;

  item.childName = document.getElementById('edit-det-name').value.trim();
  item.ageMonths = parseInt(document.getElementById('edit-det-age').value) || item.ageMonths;
  item.heightCm = parseFloat(document.getElementById('edit-det-height').value) || item.heightCm;
  item.weightKg = parseFloat(document.getElementById('edit-det-weight').value) || item.weightKg;
  item.haz = parseFloat(document.getElementById('edit-det-haz').value) || item.haz;
  item.status = document.getElementById('edit-det-status').value;
  item.doctorNotes = document.getElementById('edit-det-notes').value.trim();

  const statusTextMap = {
    'stunted': 'Stunting (Pendek)',
    'severe': 'Stunting Berat (Sangat Pendek)',
    'normal': 'Normal (Gizi Baik)',
    'tall': 'Tinggi'
  };
  item.statusText = statusTextMap[item.status] || item.status;

  closeEditDetectionModal();
  renderDoctorDashboard();
  renderAdminDashboard();
  renderParentDashboard();
  showToast(`✅ Data pemeriksaan ${item.childName} berhasil diperbarui di realtime database!`);
}

// ==================== OPERASI CRUD DOKTER: HAPUS DATA PASIEN ====================
function deleteDetectionItem(detId) {
  openConfirmDelete('detection', detId);
}

function openDoctorVerifyModal(detectionId) {
  activeValidatingDetectionId = detectionId;
  const item = DB.detections.find(d => d.id === detectionId);
  if (!item) return;

  const summary = document.getElementById('doctor-verify-patient-summary');
  summary.innerHTML = `
    <strong>Pasien: ${item.childName} (${item.ageMonths} Bulan)</strong><br>
    Tinggi Badan YOLO: ${item.heightCm} cm | Z-Score TB/U: ${item.haz} SD (${item.statusText})
  `;

  document.getElementById('modal-doctor-verify').classList.add('active');
}

function closeDoctorVerifyModal() {
  document.getElementById('modal-doctor-verify').classList.remove('active');
}

function submitDoctorValidation() {
  const notes = document.getElementById('doc-verify-notes').value;
  const status = document.getElementById('doc-verify-status').value;

  const item = DB.detections.find(d => d.id === activeValidatingDetectionId);
  if (item) {
    item.validation = status;
    item.doctorNotes = notes;
    item.doctorName = 'dr. Farhan Malik, Sp.A (K)';

    addNotification({
      type: 'doctor',
      title: '📋 Validasi Medis dari dr. Farhan Malik, Sp.A',
      message: `Catatan dokter untuk ${item.childName}: "${notes}"`
    });

    closeDoctorVerifyModal();
    renderDoctorDashboard();
    renderParentDashboard();
    showToast('✅ Validasi medis berhasil dikirimkan ke orang tua pasien!');
  }
}

// ==================== ALUR 7: FITUR UTAMA ADMIN ====================
function renderAdminDashboard() {
  const totalChildren = DB.children.length;
  const totalScans = DB.detections.length;
  const stuntedCount = DB.detections.filter(d => d.status === 'stunted' || d.status === 'severe').length;
  const stuntingRate = totalScans > 0 ? ((stuntedCount / totalScans) * 100).toFixed(1) : '0.0';

  document.getElementById('adm-kpi-children').textContent = totalChildren + ' Balita';
  document.getElementById('adm-kpi-scans').textContent = totalScans + ' Kali';
  document.getElementById('adm-kpi-stunted').textContent = stuntingRate + '%';

  const tbody = document.getElementById('admin-children-tbody');
  tbody.innerHTML = '';

  if (DB.children.length === 0) {
    const tr = document.createElement('tr');
    tr.innerHTML = `
      <td colspan="8" style="text-align:center; padding: 32px 16px; color:#64748b;">
        <div style="font-size: 28px; margin-bottom: 8px;">📋</div>
        <div style="font-weight: 600; font-size: 14px; color:#1e293b; margin-bottom: 4px;">Belum Ada Data Balita Terdaftar</div>
        <p style="font-size: 12px; margin-bottom: 12px;">Database realtime kosong. Anda dapat menambahkan data baru atau memuat data contoh untuk menguji tombol Edit dan Hapus.</p>
        <div style="display: flex; justify-content: center; gap: 8px; flex-wrap: wrap;">
          <button class="btn-primary-gradient" style="padding: 7px 14px; font-size: 12px;" onclick="openAddChildModal()">+ Tambah Data Balita Baru</button>
          <button class="btn-secondary" style="padding: 7px 14px; font-size: 12px;" onclick="loadDemoChildrenData()">📥 Muat Data Balita Demo (Uji Hapus & Edit)</button>
        </div>
      </td>
    `;
    tbody.appendChild(tr);
    return;
  }

  DB.children.forEach(c => {
    const scans = DB.detections.filter(d => d.childId === c.id);
    const lastScan = scans.length > 0 ? scans[0].statusText : 'Belum Scan';
    const tr = document.createElement('tr');
    tr.innerHTML = `
      <td><strong>${c.childName}</strong></td>
      <td>${c.nik}</td>
      <td>18 Bulan</td>
      <td>${c.gender === 'L' ? '👦 Laki-laki' : '👧 Perempuan'}</td>
      <td>${c.parentName} (${c.parentId})</td>
      <td>${c.posyandu}</td>
      <td><span class="badge-pill" style="background:#E0E7FF; color:#3730A3;">${lastScan}</span></td>
      <td>
        <div style="display:flex; gap:6px;">
          <button class="btn-action-edit" onclick="openEditChildModal('${c.id}')">✏️ Edit</button>
          <button class="btn-action-delete" onclick="deleteChildItem('${c.id}')">🗑️ Hapus</button>
        </div>
      </td>
    `;
    tbody.appendChild(tr);
  });

  // Render juga tabel manajemen Pakar Ahli & Dokter Spesialis
  renderAdminDoctorsTable();
}

// ==================== OPERASI CRUD ADMIN: TAMBAH DATA BALITA ====================
function openAddChildModal() {
  document.getElementById('modal-add-child').classList.add('active');
}

function closeAddChildModal() {
  document.getElementById('modal-add-child').classList.remove('active');
}

function submitAddChild() {
  const name = document.getElementById('adm-new-name').value.trim();
  const nik = document.getElementById('adm-new-nik').value.trim();
  const gender = document.getElementById('adm-new-gender').value;
  const dob = document.getElementById('adm-new-dob').value;
  const parent = document.getElementById('adm-new-parent').value.trim();
  const rawPhone = document.getElementById('adm-new-phone').value.trim();
  const phone = cleanPhoneNumber(rawPhone);
  const posyandu = document.getElementById('adm-new-posyandu').value.trim() || 'Posyandu Mawar Sejahtera';

  if (!name || !nik || !parent || !phone) {
    showToast('⚠️ Harap isi semua kolom wajib (*)');
    return;
  }

  const childId = 'CHILD-' + Date.now();
  const newChild = {
    id: childId,
    parentId: phone,
    parentName: parent,
    childName: name,
    nik: nik,
    gender: gender,
    dateOfBirth: dob || '2025-01-15',
    birthWeight: 3.1,
    birthHeight: 49.0,
    posyandu: posyandu,
    address: 'Kelurahan Terdaftar'
  };

  DB.children.unshift(newChild);

  // Daftarkan nomor HP jika belum ada agar bisa login
  if (!DB.registeredUsers[phone]) {
    DB.registeredUsers[phone] = {
      phone: phone,
      name: parent,
      role: 'parent',
      childId: childId
    };
  }

  addNotification({
    type: 'system',
    title: '👶 Balita Baru Ditambahkan',
    message: `Data balita ${name} (NIK: ${nik}) berhasil didaftarkan ke ${posyandu}.`
  });

  closeAddChildModal();
  renderAdminDashboard();
  showToast(`✅ Data balita "${name}" berhasil ditambahkan ke database realtime!`);
}

// ==================== OPERASI CRUD ADMIN: EDIT DATA BALITA ====================
function openEditChildModal(childId) {
  const child = DB.children.find(c => c.id === childId);
  if (!child) return;

  document.getElementById('adm-edit-id').value = child.id;
  document.getElementById('adm-edit-name').value = child.childName;
  document.getElementById('adm-edit-nik').value = child.nik;
  document.getElementById('adm-edit-gender').value = child.gender;
  document.getElementById('adm-edit-posyandu').value = child.posyandu;
  document.getElementById('adm-edit-parent').value = child.parentName;
  document.getElementById('adm-edit-phone').value = child.parentId;

  document.getElementById('modal-edit-child').classList.add('active');
}

function closeEditChildModal() {
  document.getElementById('modal-edit-child').classList.remove('active');
}

function submitEditChild() {
  const id = document.getElementById('adm-edit-id').value;
  const child = DB.children.find(c => c.id === id);
  if (!child) return;

  child.childName = document.getElementById('adm-edit-name').value.trim();
  child.nik = document.getElementById('adm-edit-nik').value.trim();
  child.gender = document.getElementById('adm-edit-gender').value;
  child.posyandu = document.getElementById('adm-edit-posyandu').value.trim();
  child.parentName = document.getElementById('adm-edit-parent').value.trim();
  child.parentId = document.getElementById('adm-edit-phone').value.trim();

  closeEditChildModal();
  renderAdminDashboard();
  renderParentDashboard();
  showToast(`✅ Data balita "${child.childName}" berhasil diperbarui di database!`);
}

// ==================== OPERASI CRUD ADMIN: HAPUS DATA BALITA & MODAL KONFIRMASI ====================
let pendingDeleteType = null;
let pendingDeleteId = null;

function openConfirmDelete(type, id) {
  pendingDeleteType = type;
  pendingDeleteId = id;
  const modal = document.getElementById('modal-confirm-delete');
  const msgEl = document.getElementById('confirm-delete-message');
  const detailsEl = document.getElementById('confirm-delete-details');
  if (!modal || !msgEl || !detailsEl) return;

  if (type === 'child') {
    const c = DB.children.find(item => item.id === id);
    if (!c) return;
    msgEl.innerHTML = `Apakah Anda yakin ingin menghapus data balita <strong>"${c.childName}"</strong> dari database realtime?`;
    detailsEl.innerHTML = `
      <strong>Nama Balita:</strong> ${c.childName}<br>
      <strong>NIK:</strong> ${c.nik} | <strong>Gender:</strong> ${c.gender === 'L' ? 'Laki-laki' : 'Perempuan'}<br>
      <strong>Orang Tua:</strong> ${c.parentName} (${c.parentId})<br>
      <strong>Posyandu:</strong> ${c.posyandu}
    `;
  } else if (type === 'detection') {
    const d = DB.detections.find(item => item.id === id);
    if (!d) return;
    msgEl.innerHTML = `Apakah Anda yakin ingin menghapus data rekam medis <strong>"${d.childName}"</strong> dari database realtime?`;
    detailsEl.innerHTML = `
      <strong>Pasien:</strong> ${d.childName} (${d.ageMonths} Bulan)<br>
      <strong>Tinggi Badan:</strong> ${d.heightCm} cm | <strong>Berat:</strong> ${d.weightKg} kg<br>
      <strong>Status Gizi:</strong> ${d.statusText} (Z-Score: ${d.haz} SD)
    `;
  } else if (type === 'expert') {
    const exp = DB.experts.find(item => item.id === id);
    if (!exp) return;
    msgEl.innerHTML = `Apakah Anda yakin ingin menghapus data Pakar Ahli / Dokter <strong>"${exp.name}"</strong> dari database realtime?`;
    detailsEl.innerHTML = `
      <strong>Nama:</strong> ${exp.name}<br>
      <strong>Peran:</strong> ${exp.titleRole || 'Pakar Ahli Pediatri'}<br>
      <strong>NIDN / SIP:</strong> ${exp.nidn || '-'} / ${exp.sipNumber || '-'}<br>
      <strong>Institusi:</strong> ${exp.institution} | <strong>WhatsApp:</strong> ${exp.phone}
    `;
  }

  modal.classList.add('active');
}

function closeConfirmDeleteModal() {
  const modal = document.getElementById('modal-confirm-delete');
  if (modal) modal.classList.remove('active');
  pendingDeleteType = null;
  pendingDeleteId = null;
}

function executeConfirmDelete() {
  if (!pendingDeleteId) {
    closeConfirmDeleteModal();
    return;
  }

  if (pendingDeleteType === 'child') {
    const child = DB.children.find(c => c.id === pendingDeleteId);
    const childName = child ? child.childName : 'Balita';
    DB.children = DB.children.filter(c => c.id !== pendingDeleteId);
    DB.detections = DB.detections.filter(d => d.childId !== pendingDeleteId);
    renderAdminDashboard();
    renderDoctorDashboard();
    renderParentDashboard();
    showToast(`🗑️ Data balita "${childName}" berhasil dihapus dari database realtime.`);
  } else if (pendingDeleteType === 'detection') {
    const item = DB.detections.find(d => d.id === pendingDeleteId);
    const itemName = item ? item.childName : 'Pemeriksaan';
    DB.detections = DB.detections.filter(d => d.id !== pendingDeleteId);
    renderDoctorDashboard();
    renderAdminDashboard();
    renderParentDashboard();
    showToast(`🗑️ Data pemeriksaan "${itemName}" berhasil dihapus dari database realtime.`);
  } else if (pendingDeleteType === 'expert') {
    const exp = DB.experts.find(item => item.id === pendingDeleteId);
    const expName = exp ? exp.name : 'Pakar/Dokter Ahli';
    if (exp && exp.phone) {
      delete DB.registeredUsers[exp.phone];
    }
    DB.experts = DB.experts.filter(item => item.id !== pendingDeleteId);
    renderAdminDashboard();
    renderDoctorDashboard();
    showToast(`🗑️ Data Pakar/Dokter Ahli "${expName}" berhasil dihapus dari database realtime.`);
  }

  closeConfirmDeleteModal();
}

function deleteChildItem(childId) {
  openConfirmDelete('child', childId);
}

function deleteDoctorItem(docId) {
  openConfirmDelete('expert', docId);
}

// ==================== OPERASI CRUD PAKAR / DOKTER AHLI REALTIME ====================
function renderAdminDoctorsTable() {
  const tbody = document.getElementById('admin-doctors-tbody');
  if (!tbody) return;
  tbody.innerHTML = '';

  if (!DB.experts || DB.experts.length === 0) {
    const tr = document.createElement('tr');
    tr.innerHTML = `
      <td colspan="7" style="text-align:center; padding: 28px 16px; color:#64748b;">
        <div style="font-size: 26px; margin-bottom: 6px;">👨‍⚕️</div>
        <div style="font-weight: 600; font-size: 14px; color:#1e293b; margin-bottom: 4px;">Belum Ada Data Pakar Ahli / Dokter Terdaftar</div>
        <p style="font-size: 12px; margin-bottom: 12px;">Data tenaga pakar kosong. Klik tombol di bawah untuk menambah data pakar ahli baru atau memuat data contoh.</p>
        <div style="display: flex; justify-content: center; gap: 8px; flex-wrap: wrap;">
          <button class="btn-primary-gradient" style="padding: 7px 14px; font-size: 12px;" onclick="openAddDoctorModal()">+ Tambah Data Pakar / Dokter Ahli</button>
          <button class="btn-secondary" style="padding: 7px 14px; font-size: 12px;" onclick="loadDemoDoctorData()">📥 Muat Data Pakar Ahli Demo</button>
        </div>
      </td>
    `;
    tbody.appendChild(tr);
    return;
  }

  DB.experts.forEach(exp => {
    const tr = document.createElement('tr');
    tr.innerHTML = `
      <td>
        <strong>${exp.name}</strong>
        <div style="font-size:11px; color:#64748b;">${exp.titleRole || 'Pakar Ahli Pediatri'}</div>
      </td>
      <td>
        <div><strong>SIP:</strong> ${exp.sipNumber || '-'}</div>
        <div style="font-size:11px; color:#64748b;"><strong>NIDN:</strong> ${exp.nidn || '-'}</div>
      </td>
      <td>
        <span class="badge-pill" style="background:#e0f2fe; color:#0369a1;">${exp.specialization || 'Spesialis Anak'}</span>
      </td>
      <td>${exp.institution || 'Fakultas Kedokteran'}</td>
      <td><strong>${exp.phone}</strong></td>
      <td>
        <span class="badge-pill" style="background:${exp.status === 'Aktif' ? '#dcfce7' : '#fef3c7'}; color:${exp.status === 'Aktif' ? '#166534' : '#92400e'};">
          ${exp.status === 'Aktif' ? '🟢 Aktif' : '🟡 Cuti'}
        </span>
      </td>
      <td>
        <div style="display:flex; gap:6px;">
          <button class="btn-action-edit" onclick="openEditDoctorModal('${exp.id}')">✏️ Edit</button>
          <button class="btn-action-delete" onclick="deleteDoctorItem('${exp.id}')">🗑️ Hapus</button>
        </div>
      </td>
    `;
    tbody.appendChild(tr);
  });
}

function openAddDoctorModal() {
  document.getElementById('modal-add-doctor').classList.add('active');
}

function closeAddDoctorModal() {
  document.getElementById('modal-add-doctor').classList.remove('active');
}

function submitAddDoctor() {
  const name = document.getElementById('doc-add-name').value.trim();
  const title = document.getElementById('doc-add-title').value.trim();
  const nidn = document.getElementById('doc-add-nidn').value.trim();
  const sip = document.getElementById('doc-add-sip').value.trim();
  const spec = document.getElementById('doc-add-spec').value.trim();
  const inst = document.getElementById('doc-add-inst').value.trim();
  const rawPhone = document.getElementById('doc-add-phone').value.trim();
  const phone = cleanPhoneNumber(rawPhone);

  if (!name || !sip || !phone) {
    showToast('⚠️ Nama, Nomor SIP, dan Nomor WhatsApp wajib diisi!');
    return;
  }

  const newId = 'doc-' + Date.now();
  const newDoctor = {
    id: newId,
    name: name,
    titleRole: title || 'Pakar Ahli Pediatri & Dokter Spesialis Anak',
    nidn: nidn || '-',
    sipNumber: sip,
    specialization: spec || 'Spesialis Anak',
    institution: inst || 'Fakultas Kedokteran / RS',
    phone: phone,
    email: phone + '@stuntingguard.id',
    status: 'Aktif'
  };

  DB.experts.push(newDoctor);

  // Daftarkan ke DB.registeredUsers agar langsung bisa login
  DB.registeredUsers[phone] = {
    phone: phone,
    name: name,
    email: newDoctor.email,
    role: 'expert',
    specialization: spec || 'Spesialis Anak',
    sipNumber: sip
  };

  closeAddDoctorModal();
  renderAdminDashboard();
  renderDoctorDashboard();
  showToast(`✅ Data Pakar/Dokter Ahli "${name}" berhasil ditambahkan ke database realtime!`);
}

function openEditDoctorModal(docId) {
  let doc = null;
  if (docId === 'self') {
    doc = DB.experts[0];
  } else {
    doc = DB.experts.find(d => d.id === docId);
  }

  if (!doc) return;

  document.getElementById('doc-edit-id').value = doc.id;
  document.getElementById('doc-edit-name').value = doc.name;
  document.getElementById('doc-edit-title').value = doc.titleRole || '';
  document.getElementById('doc-edit-nidn').value = doc.nidn || '';
  document.getElementById('doc-edit-sip').value = doc.sipNumber || '';
  document.getElementById('doc-edit-spec').value = doc.specialization || '';
  document.getElementById('doc-edit-inst').value = doc.institution || '';
  document.getElementById('doc-edit-phone').value = doc.phone;
  document.getElementById('doc-edit-status').value = doc.status || 'Aktif';

  document.getElementById('modal-edit-doctor').classList.add('active');
}

function closeEditDoctorModal() {
  document.getElementById('modal-edit-doctor').classList.remove('active');
}

function submitEditDoctor() {
  const docId = document.getElementById('doc-edit-id').value;
  const doc = DB.experts.find(d => d.id === docId);
  if (!doc) return;

  const oldPhone = doc.phone;
  const name = document.getElementById('doc-edit-name').value.trim();
  const title = document.getElementById('doc-edit-title').value.trim();
  const nidn = document.getElementById('doc-edit-nidn').value.trim();
  const sip = document.getElementById('doc-edit-sip').value.trim();
  const spec = document.getElementById('doc-edit-spec').value.trim();
  const inst = document.getElementById('doc-edit-inst').value.trim();
  const rawPhone = document.getElementById('doc-edit-phone').value.trim();
  const phone = cleanPhoneNumber(rawPhone);
  const status = document.getElementById('doc-edit-status').value;

  if (!name || !sip || !phone) {
    showToast('⚠️ Nama, SIP, dan No WhatsApp wajib diisi!');
    return;
  }

  doc.name = name;
  doc.titleRole = title;
  doc.nidn = nidn;
  doc.sipNumber = sip;
  doc.specialization = spec;
  doc.institution = inst;
  doc.phone = phone;
  doc.status = status;

  // Update akun login di registeredUsers
  if (oldPhone !== phone) {
    delete DB.registeredUsers[oldPhone];
  }
  DB.registeredUsers[phone] = {
    phone: phone,
    name: name,
    email: doc.email,
    role: 'expert',
    specialization: spec,
    sipNumber: sip
  };

  closeEditDoctorModal();
  renderAdminDashboard();
  renderDoctorDashboard();
  showToast(`✅ Data Pakar/Dokter Ahli "${name}" berhasil diperbarui di database realtime!`);
}

function loadDemoDoctorData() {
  const sample = [
    {
      id: 'doc-demo-1',
      name: 'dr. Farhan Malik, Sp.A (K)',
      titleRole: 'Pakar Ahli Pediatri & Spesialis Anak Konsultan',
      phone: '081198765432',
      email: 'dr.farhan@rumahsakit.id',
      sipNumber: 'SIP.440/129/DINKES/2024',
      nidn: '0012058501',
      institution: 'Fakultas Kedokteran UI / RS Hermina',
      specialization: 'Nutrisi & Penyakit Metabolik Anak',
      status: 'Aktif'
    },
    {
      id: 'doc-demo-2',
      name: 'Dr. dr. Anisa Putri, M.Kes, Sp.A',
      titleRole: 'Pakar Ahli Tumbuh Kembang & Spesialis Anak',
      phone: '081299887766',
      email: 'anisa.putri@fk-univ.ac.id',
      sipNumber: 'SIP.440/215/DINKES/2023',
      nidn: '0028098203',
      institution: 'Fakultas Kedokteran / RSUP Nasional',
      specialization: 'Tumbuh Kembang & Deteksi Dini Stunting',
      status: 'Aktif'
    }
  ];
  sample.forEach(s => {
    if (!DB.experts.some(e => e.id === s.id)) {
      DB.experts.push(s);
      DB.registeredUsers[s.phone] = {
        phone: s.phone,
        name: s.name,
        email: s.email,
        role: 'expert',
        specialization: s.specialization,
        sipNumber: s.sipNumber
      };
    }
  });
  renderAdminDashboard();
  renderDoctorDashboard();
  showToast('✅ Data Pakar Ahli berhasil dimuat! Tombol Edit & Hapus siap diuji.');
}

function loadDemoChildrenData() {
  const sample = [
    {
      id: 'c-demo-1',
      childName: 'Muhammad Rayyan',
      nik: '3201281504240001',
      dob: '2025-04-15',
      gender: 'L',
      parentId: '081234567890',
      parentName: 'Bunda Siti Aminah',
      posyandu: 'Posyandu Mawar Sejahtera'
    },
    {
      id: 'c-demo-2',
      childName: 'Aisyah Azzahra',
      nik: '3201282208240002',
      dob: '2024-08-22',
      gender: 'P',
      parentId: '082198765432',
      parentName: 'Bunda Dewi Lestari',
      posyandu: 'Posyandu Mawar Sejahtera'
    }
  ];
  sample.forEach(s => {
    if (!DB.children.some(c => c.id === s.id)) DB.children.push(s);
  });
  renderAdminDashboard();
  renderDoctorDashboard();
  showToast('✅ Data balita berhasil dimuat! Tombol Edit & Hapus siap diuji.');
}

function loadDemoDetectionData() {
  const sample = [
    {
      id: 'det-demo-1',
      childId: 'c-demo-1',
      childName: 'Muhammad Rayyan',
      ageMonths: 18,
      heightCm: 76.5,
      weightKg: 9.8,
      haz: -2.12,
      waz: -1.35,
      status: 'stunted',
      statusText: 'Stunting (Pendek)',
      confidence: 0.94,
      timestamp: '2026-10-26 10:15',
      validation: 'pending',
      doctorNotes: 'Rekomendasikan intervensi protein hewani 2 butir telur/hari.'
    },
    {
      id: 'det-demo-2',
      childId: 'c-demo-2',
      childName: 'Aisyah Azzahra',
      ageMonths: 14,
      heightCm: 77.2,
      weightKg: 10.2,
      haz: 0.15,
      waz: 0.22,
      status: 'normal',
      statusText: 'Normal (Gizi Baik)',
      confidence: 0.96,
      timestamp: '2026-10-26 11:30',
      validation: 'approved',
      doctorNotes: 'Tumbuh kembang optimal sesuai kurva WHO.'
    }
  ];
  sample.forEach(s => {
    if (!DB.detections.some(d => d.id === s.id)) DB.detections.push(s);
  });
  renderDoctorDashboard();
  renderAdminDashboard();
  showToast('✅ Data antrian pasien dokter berhasil dimuat! Tombol Edit & Hapus siap diuji.');
}

// ==================== SUPABASE REALTIME CLIENT INITIALIZATION ====================
let SUPABASE_URL = localStorage.getItem('SP_URL') || 'https://xyzstuntingguard.supabase.co';
let SUPABASE_KEY = localStorage.getItem('SP_KEY') || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.dummy_anon_key_stunting_ai_2026';
let supabaseClient = null;

function initSupabaseClient() {
  if (typeof supabase !== 'undefined' && supabase.createClient) {
    try {
      supabaseClient = supabase.createClient(SUPABASE_URL, SUPABASE_KEY);
      console.log('⚡ [Supabase Web] Client initialized:', SUPABASE_URL);
    } catch (e) {
      console.warn('⚠️ [Supabase Web] Fallback mode:', e);
    }
  }
}

// ==================== MODAL BUKA & EDIT FILE DATABASE SUPABASE ====================
const DB_FILE_PATH = '/Users/eyzelula/Antigravity/Deteksi/Penyakit/Stunting_Anak/data/stunting_database.json';

const SUPABASE_SCHEMA_SQL = `-- Skema Tabel Realtime Supabase untuk StuntingGuard AI
CREATE TABLE IF NOT EXISTS public.registered_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(150) NOT NULL,
    email VARCHAR(150),
    role VARCHAR(20) NOT NULL CHECK (role IN ('parent', 'expert', 'admin')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.children (
    id VARCHAR(100) PRIMARY KEY,
    parent_id VARCHAR(100) NOT NULL,
    parent_name VARCHAR(150) NOT NULL,
    child_name VARCHAR(150) NOT NULL,
    nik VARCHAR(20) UNIQUE NOT NULL,
    gender CHAR(1) NOT NULL CHECK (gender IN ('L', 'P')),
    date_of_birth DATE NOT NULL,
    birth_weight_kg NUMERIC(4, 2) NOT NULL DEFAULT 3.10,
    birth_height_cm NUMERIC(4, 1) NOT NULL DEFAULT 49.0,
    address TEXT NOT NULL,
    posyandu_name VARCHAR(150) NOT NULL DEFAULT 'Posyandu Mawar Sejahtera',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.stunting_detections (
    id VARCHAR(100) PRIMARY KEY,
    child_id VARCHAR(100) NOT NULL REFERENCES public.children(id) ON DELETE CASCADE,
    child_name VARCHAR(150) NOT NULL,
    age_months INT NOT NULL,
    gender CHAR(1) NOT NULL,
    measured_height_cm NUMERIC(5, 2) NOT NULL,
    measured_weight_kg NUMERIC(5, 2) NOT NULL,
    haz_score NUMERIC(5, 2) NOT NULL,
    waz_score NUMERIC(5, 2) NOT NULL,
    status VARCHAR(30) NOT NULL,
    yolo_confidence NUMERIC(4, 3) NOT NULL DEFAULT 0.950,
    validation_status VARCHAR(30) NOT NULL DEFAULT 'pending',
    doctor_notes TEXT,
    timestamp TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.notifications (
    id VARCHAR(100) PRIMARY KEY,
    recipient_id VARCHAR(100) NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER PUBLICATION supabase_realtime ADD TABLE public.children;
ALTER PUBLICATION supabase_realtime ADD TABLE public.stunting_detections;
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;`;

function openDatabaseEditorModal() {
  document.getElementById('supabase-input-url').value = SUPABASE_URL;
  document.getElementById('supabase-input-key').value = SUPABASE_KEY;
  document.getElementById('supabase-sql-textarea').value = SUPABASE_SCHEMA_SQL;

  const fullDatabaseDump = {
    registered_users: DB.registeredUsers,
    children: DB.children,
    stunting_detections: DB.detections,
    notifications: DB.notifications,
    posyandu_centers: [
      {
        id: "POSYANDU-001",
        name: "Posyandu Mawar Sejahtera",
        village: "Kelurahan Melati Indah",
        schedule: "Setiap Rabu ke-2 & ke-4"
      }
    ]
  };

  document.getElementById('db-json-textarea').value = JSON.stringify(fullDatabaseDump, null, 2);
  switchDbModalTab('config');
  document.getElementById('modal-database-editor').classList.add('active');
}

function closeDatabaseEditorModal() {
  document.getElementById('modal-database-editor').classList.remove('active');
}

function switchDbModalTab(tab) {
  document.getElementById('tab-btn-sp-config').classList.remove('active');
  document.getElementById('tab-btn-sp-sql').classList.remove('active');
  document.getElementById('tab-btn-sp-json').classList.remove('active');

  document.getElementById('tab-content-sp-config').style.display = 'none';
  document.getElementById('tab-content-sp-sql').style.display = 'none';
  document.getElementById('tab-content-sp-json').style.display = 'none';

  if (tab === 'config') {
    document.getElementById('tab-btn-sp-config').classList.add('active');
    document.getElementById('tab-content-sp-config').style.display = 'block';
  } else if (tab === 'sql') {
    document.getElementById('tab-btn-sp-sql').classList.add('active');
    document.getElementById('tab-content-sp-sql').style.display = 'block';
  } else if (tab === 'json') {
    document.getElementById('tab-btn-sp-json').classList.add('active');
    document.getElementById('tab-content-sp-json').style.display = 'block';
  }
}

function testAndSaveSupabaseConfig() {
  const url = document.getElementById('supabase-input-url').value.trim();
  const key = document.getElementById('supabase-input-key').value.trim();

  if (!url || !key) {
    alert('Harap masukkan Supabase Project URL dan Anon Public Key');
    return;
  }

  SUPABASE_URL = url;
  SUPABASE_KEY = key;
  localStorage.setItem('SP_URL', url);
  localStorage.setItem('SP_KEY', key);

  initSupabaseClient();

  const badge = document.getElementById('supabase-status-badge');
  badge.textContent = '● Terhubung ke ' + url.replace('https://', '').split('.')[0];
  badge.style.background = '#10b981';

  showToast('⚡ Kredensial Supabase berhasil disimpan dan diaktifkan!');
}

function copySqlSchema() {
  navigator.clipboard.writeText(SUPABASE_SCHEMA_SQL).then(() => {
    showToast('📋 Skema SQL Supabase berhasil disalin ke clipboard!');
  }).catch(() => {
    prompt('Salin skema SQL di bawah:', SUPABASE_SCHEMA_SQL);
  });
}

function saveDatabaseJson() {
  try {
    const raw = document.getElementById('db-json-textarea').value;
    const parsed = JSON.parse(raw);

    if (parsed.registered_users) DB.registeredUsers = parsed.registered_users;
    if (parsed.children) DB.children = parsed.children;
    if (parsed.stunting_detections) DB.detections = parsed.stunting_detections;
    if (parsed.notifications) DB.notifications = parsed.notifications;

    renderAdminDashboard();
    renderDoctorDashboard();
    renderParentDashboard();

    closeDatabaseEditorModal();
    showToast('💾 Database realtime berhasil diperbarui dari editor JSON!');
  } catch (err) {
    alert('❌ Format JSON tidak valid: ' + err.message);
  }
}

function copyDatabaseFilePath() {
  navigator.clipboard.writeText(DB_FILE_PATH).then(() => {
    showToast('📋 Path file database berhasil disalin ke clipboard!');
  }).catch(() => {
    prompt('Salin path file database di bawah:', DB_FILE_PATH);
  });
}

function downloadDatabaseJson() {
  const raw = document.getElementById('db-json-textarea').value;
  const blob = new Blob([raw], { type: 'application/json' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = 'stunting_database.json';
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  URL.revokeObjectURL(url);
  showToast('📥 File stunting_database.json berhasil diunduh!');
}

function openBroadcastModal() {
  document.getElementById('modal-broadcast').classList.add('active');
}

function closeBroadcastModal() {
  document.getElementById('modal-broadcast').classList.remove('active');
}

function submitBroadcastNotification() {
  const title = document.getElementById('broadcast-title').value;
  const msg = document.getElementById('broadcast-msg').value;

  addNotification({
    type: 'broadcast',
    title: title,
    message: msg
  });

  closeBroadcastModal();
  showToast('📢 Pengumuman massal berhasil disiarkan ke seluruh orang tua secara realtime!');
}

// ==================== FITUR NOTIFIKASI REALTIME ====================
function addNotification({ type, title, message }) {
  const notif = {
    id: 'NOTIF-' + Date.now(),
    type,
    title,
    message,
    isRead: false,
    timestamp: new Date().toISOString()
  };

  DB.notifications.unshift(notif);
  updateNotificationBadge();
  showToast(`🔔 ${title}`);
}

function updateNotificationBadge() {
  const unreadCount = DB.notifications.filter(n => !n.isRead).length;
  const badge = document.getElementById('notif-badge');
  badge.textContent = unreadCount;
  badge.style.display = unreadCount > 0 ? 'flex' : 'none';
}

function toggleNotificationsModal() {
  const modal = document.getElementById('modal-notifs');
  modal.classList.toggle('active');

  const container = document.getElementById('notif-list-container');
  container.innerHTML = '';

  DB.notifications.forEach(n => {
    const item = document.createElement('div');
    item.className = 'notif-item ' + (n.isRead ? '' : 'unread');
    item.innerHTML = `
      <div class="notif-icon-circle">🔔</div>
      <div class="notif-body">
        <strong>${n.title}</strong>
        <p>${n.message}</p>
      </div>
    `;
    container.appendChild(item);
  });
}

function markAllNotifsAsRead() {
  DB.notifications.forEach(n => n.isRead = true);
  updateNotificationBadge();
  toggleNotificationsModal();
  showToast('Semua notifikasi ditandai telah dibaca.');
}

function showToast(msg) {
  const container = document.getElementById('toast-container');
  const toast = document.createElement('div');
  toast.className = 'toast';
  toast.innerHTML = `<span>${msg}</span>`;
  container.appendChild(toast);

  setTimeout(() => {
    toast.style.opacity = '0';
    setTimeout(() => toast.remove(), 300);
  }, 3500);
}

// ==================== INTERAKTIVITAS FITUR GIZI & MPASI ====================
function calculateNutritionNeeds() {
  const weightInput = document.getElementById('calc-child-weight');
  const ageInput = document.getElementById('calc-child-age');
  if (!weightInput || !ageInput) return;

  const weight = parseFloat(weightInput.value) || 9.5;
  const age = parseInt(ageInput.value) || 18;

  // Standar Angka Kecukupan Gizi (AKG) Kemenkes: ~1.5g protein per kg BB/hari
  const targetProtein = (weight * 1.5).toFixed(1);
  const eggEquiv = Math.max(1, Math.round((weight * 1.5) / 6.5));
  const calorieMin = Math.round(weight * 85);
  const calorieMax = Math.round(weight * 100);

  const protEl = document.getElementById('res-protein-target');
  const eggEl = document.getElementById('res-egg-target');
  const calEl = document.getElementById('res-calorie-target');

  if (protEl) protEl.textContent = `${targetProtein} g`;
  if (eggEl) eggEl.textContent = `${eggEquiv} Butir Telur`;
  if (calEl) calEl.textContent = `${calorieMin} - ${calorieMax} kkal`;
}

// ==================== INTERAKTIVITAS KONSULTASI TELEMEDISIN DOKTER ====================
function sendConsultationMessage() {
  const input = document.getElementById('consult-chat-input');
  if (!input) return;
  const text = input.value.trim();
  if (!text) return;

  const container = document.getElementById('chat-messages-container');
  if (!container) return;

  // Waktu saat ini
  const now = new Date();
  const timeStr = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;

  // Tambahkan bubble chat orang tua
  const parentMsg = document.createElement('div');
  parentMsg.className = 'chat-msg parent-msg';
  parentMsg.innerHTML = `
    <div class="msg-sender">Anda (Orang Tua Balita)</div>
    <div class="msg-bubble">${text}</div>
    <div class="msg-time">Hari ini ${timeStr}</div>
  `;
  container.appendChild(parentMsg);
  input.value = '';
  container.scrollTop = container.scrollHeight;

  // Simulasi auto-reply dokter spesialis anak
  setTimeout(() => {
    const replies = [
      'Terima kasih atas pertanyaannya Bunda. Untuk mempercepat kejar tumbuh tinggi badan balita, utamakan asupan protein hewani tinggi seperti 2 butir telur/hari, hati ayam, dan daging merah yang kaya zat besi heme & zinc.',
      'Sangat baik Bunda telah aktif memantau kurva stunting WHO. Pastikan jadwal makan teratur (feeding rules) tidak lebih dari 30 menit per sesi makan ya Bun.',
      'Data deteksi balita Anda telah saya tinjau. Rekomendasi medis utama: lengkapi imunisasi dasar, berikan MPASI padat gizi, dan pantau kembali pengukuran tinggi badan di Posyandu dalam 14 hari ke depan.'
    ];
    const replyText = replies[Math.floor(Math.random() * replies.length)];

    const docMsg = document.createElement('div');
    docMsg.className = 'chat-msg doc-msg';
    docMsg.innerHTML = `
      <div class="msg-sender">dr. Farhan Malik, Sp.A (K)</div>
      <div class="msg-bubble">${replyText}</div>
      <div class="msg-time">Hari ini ${timeStr}</div>
    `;
    container.appendChild(docMsg);
    container.scrollTop = container.scrollHeight;
  }, 900);
}

// ==================== INISIALISASI ====================
window.addEventListener('DOMContentLoaded', () => {
  initSupabaseClient();

  const d = new Date();
  d.setMonth(d.getMonth() - 18);
  const dobInput = document.getElementById('reg-child-dob');
  if (dobInput) dobInput.value = d.toISOString().split('T')[0];

  updateNotificationBadge();
  renderParentDashboard();
  renderDoctorDashboard();
  renderAdminDashboard();

  // Layar awal: Registrasi Balita & Nomor HP
  navigateTo('register');
});
