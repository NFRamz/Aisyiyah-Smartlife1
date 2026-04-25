# Aisyiyah Smartlife (Private Repository)

![Project Status](https://img.shields.io/badge/status-active-success.svg)
![Platform](https://img.shields.io/badge/platform-flutter-blue.svg)
![Access](https://img.shields.io/badge/access-private-red.svg)

> **⚠️ PERINGATAN KERAHASIAAN** 
>
> Repositori ini hanya berisi aplikasi **Aisyiyah Smartlife** yang digunakan untuk memberikan update app kepada pengguna sehingga dapat melakukan pembaruan via inApp(pengunduhan&perbaruan langsung didalam aplikasi).Hal ini bertujuan agar para pengguna tidak ketinggalan dengan fitur terbaru, sembari aplikasi sedang proses pengajuan untuk dipublish ke playstore. Source code project app ini bersifat private sehingga tidak diperuntukkan untuk publik.

---

## A. Tentang Aisyiyah Smartlife

**Aisyiyah Smartlife** adalah aplikasi *mobile* berbasis Flutter yang dirancang untuk mendukung ekosistem digital para anggota Aisyiyah. Aplikasi ini **hadir untuk semua tipe pengguna**, menyediakan fitur akses Tamu (Guest) untuk publik dan Login khusus untuk anggota yang telah terdaftar emailnya dikantor PD Aisyiyah Pamekasan.

Tujuan utama aplikasi ini adalah mempermudah manajemen kegiatan,donasi,umkm, dan transparansi organisasi dari tingkat Ranting hingga Wilayah, serta menyediakan fitur ibadah harian yang lengkap.

---

## B. Hak Akses & Tipe Pengguna

Aplikasi ini memiliki 6 tipe pengguna dengan hierarki dan hak akses yang berbeda:

| Role | Deskripsi & Hak Akses |
| :--- | :--- |
| **1. Wilayah** | • Kelola kegiatan tingkat Wilayah<br>• Monitoring aktivitas seluruh bawahan (Daerah/Cabang/Ranting)<br>• Melihat daftar & total Daerah, Cabang, Ranting<br>• Kirim notifikasi ke seluruh bawahan<br>• Export rekap kegiatan ke Excel<br>• Kelola Donasi tingkat Wilayah |
| **2. Daerah** | • Kelola kegiatan tingkat Daerah<br>• Monitoring aktivitas & total Cabang/Ranting<br>• Kirim notifikasi ke bawahan<br>• Export rekap kegiatan ke Excel<br>• Kelola Donasi tingkat Daerah |
| **3. Cabang** | • Kelola kegiatan tingkat Cabang<br>• Monitoring aktivitas & total Ranting<br>• Kirim notifikasi ke bawahan<br>• Export rekap kegiatan ke Excel<br>• Kelola Donasi tingkat Cabang<br>• **Kelola UMKM tingkat Cabang** |
| **4. Ranting** | • Kelola kegiatan tingkat Ranting<br>• Monitoring aktivitas bawahan<br>• Kirim notifikasi ke bawahan<br>• Export rekap kegiatan ke Excel<br>• Kelola Donasi tingkat Ranting<br>• **Kelola UMKM tingkat Ranting** |
| **5. Anggota** | • Melihat kegiatan, myquran, UMKM, dan melakukan Donasi<br>• Mengakses seluruh layanan tersedia sesuai lokasi terdaftar |
| **6. Tamu** | • Akses fitur My Quran |

---

## C. Fitur Unggulan

### a. Manajemen Jadwal Kegiatan
Fitur transparansi agenda dari tingkat Ranting hingga Wilayah.
* **Hierarki Monitoring yang tersinkonisasi:** Memantau kegiatan bawahan atau atasan untuk transparansi yang lebih baik.
* **Hierarki Notifikasi:** Terima Notifikasi kegiatan terbaru berdasarkan tingkatan dan cakupan lokasi para pengguna.
* **Filter Cerdas:** Filter kegiatan sesuai tingkatan dan cakupan wilayah.
* **Custom Alarm:** Pengingat kegiatan yang waktunya dapat disesuaikan pengguna.
* **Deskripsi Detail:** Menampilkan detail terkait kegiatan yang dilakukan.
* **Integrasi Peta:** Lokasi kegiatan terhubung langsung dengan Google Maps.
* **Export Data:** Fitur unduh rekap kegiatan ke Excel (khusus Role tertentu).

### b. My Quran & Fitur Islami
Pendamping ibadah harian yang lengkap.

#### **1. Baca Quran**
* Teks dan audio kata per kata (word-by-word).
* Audio playback per ayat.
* Kustomisasi ukuran font Arab dan Latin.
* Footnote (catatan kaki) pada setiap ayat.

#### **2. Quran Audio (Online & Offline)**
Mendukung *background playback* dengan pilihan Qari ternama:
* *Abdul Baset Abdul Samad (Murattal, Mujawwad)*
* *Mohamed Siddiq al-Minshawi (Murattal, Mujawwad)*
* *Abu Bakr al-Shatri, Hani ar-Rifai, Mahmoud Khalil Al-Husary*
* *Mishari Rashid al-Afasy, Abdur-Rahman as-Sudais, Sa’ud ash-Shuraym*

#### **3. Ensiklopedi Hadist**
* Status kesahihan (Shahih, Hasan, dll).
* Teks Arab, Terjemahan, dan Syarah (Penjelasan).
* Pelajaran dan faedah di setiap hadist.
* Kategori tematik (Klasifikasi Utama & Sub-kategori).

#### **4. Kalender & Jadwal Sholat**
* **Dual Date System:** Penanggalan Masehi & Hijriyah.
* **Penanda:** Puasa Sunnah & Hari Besar Islam.
* **Jadwal Sholat:** Realtime GPS (Offline support).
* **4 Tipe Jadwal:** Pagi, Siang & Sore, Malam, Qiyamul Lail.
* **Asmaul Husna:** Teks, terjemahan, dan pencarian.

### c. UMKM & Donasi
* **Direktori UMKM:** Daftar unit usaha lengkap (Deskripsi, Kontak, Lokasi). Pengguna bisa langsung menghubungi penjual.
* **Donasi Terpercaya:** Informasi program sosial transparan dengan detail rekening bank pengurus yang jelas.

---

## D. Tech Stack & API

Aplikasi ini dibangun menggunakan teknologi modern:

### **Core**
* **Frontend:** [Flutter](https://flutter.dev/)
* **Backend:** [Supabase](https://supabase.com/) & [Firebase](https://firebase.google.com/)

### **3rd Party APIs**
Aplikasi ini mengambil data islami dari sumber berikut:
* `quran.com` (Data Al-Quran)
* `hadeeth.com` & `https://hadeethenc.com/` (Ensiklopedia Hadist)
* `aladhan.com` (Jadwal Sholat & Kalender)

**Frontend & Language:**
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white)

**Backend & Database:**
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=flat&logo=supabase&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=flat&logo=firebase&logoColor=black)

**External APIs:**
![Quran.com](https://img.shields.io/badge/API-Quran.com-2CA5E0?style=flat&logo=book&logoColor=white)
![Hadeeth](https://img.shields.io/badge/API-Hadeeth-00BFA5?style=flat)
![Aladhan](https://img.shields.io/badge/API-Aladhan-4CAF50?style=flat)
---

## 📸 Preview video
*(Klik gambar untuk memutar video)*
[![Aisyiyah Smartlife Promo](https://img.youtube.com/vi/GSf9P0pX-aI/maxresdefault.jpg)](https://www.youtube.com/watch?v=GSf9P0pX-aI)



### 🖼️ Foto (Testing)
Berikut adalah dokumentasi pertemuan dan proses pengujian aplikasi:

| Sesi Pembukaan | Diskusi&sesi tanya terkait App | Uji Coba User |
| :---: | :---: | :---: |
| ![Foto 1](foto/1.jpg) | ![Foto 2](foto/2.jpg) | ![Foto 3](foto/3.jpg) |
---
