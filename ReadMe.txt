# 🎓 ANJUNGAN

## Aplikasi Bimbingan Skripsi & Tugas Akhir

**Anjungan** adalah aplikasi mobile berbasis **Flutter** yang dirancang untuk mendigitalisasi proses bimbingan skripsi dan tugas akhir. Aplikasi ini memfasilitasi interaksi antara **Mahasiswa**, **Dosen Pembimbing**, dan **Admin Prodi** dalam pencatatan jadwal, validasi bimbingan, serta pengelolaan data pengguna secara terpusat dan real-time.

---

## 🛠️ Prasyarat (System Requirements)

Pastikan perangkat Anda telah memenuhi kebutuhan berikut:

* **Flutter SDK** (versi 3.0 atau lebih baru)
* **VS Code** atau **Android Studio**
* **Git**
* **Android Emulator** atau **Perangkat Fisik** (USB Debugging aktif)
* **Koneksi Internet Stabil** (wajib untuk Firebase)

---

## 🚀 Cara Menjalankan Aplikasi (Installation)

Ikuti langkah-langkah berikut untuk menjalankan aplikasi:

### 1. Clone Repository

Buka terminal lalu jalankan perintah:

```bash
git clone https://github.com/Ages-V/anjungan.git
```

### 2. Masuk ke Direktori Project

```bash
cd anjungan
```

### 3. Install Dependencies

Unduh seluruh package yang dibutuhkan:

```bash
flutter pub get
```

### 4. Jalankan Aplikasi

Pastikan emulator sudah aktif atau device terhubung:

```bash
flutter run
```

---

## 🔑 Akun Demo (Credentials)

Gunakan akun demo berikut untuk pengujian aplikasi.

⚠️ **Peringatan:** Jangan gunakan data pribadi asli karena database bersifat publik untuk keperluan testing.

| Role         | Email                                         | Password | Keterangan              |
| ------------ | --------------------------------------------- | -------- | ----------------------- |
| 👮 Admin     | [adminif@gmail.com](mailto:adminif@gmail.com) | 123456   | Akses penuh kelola user |
| 👨‍🏫 Dosen  | [dosen@gmail.com](mailto:dosen@gmail.com)     | 12345678 | Validasi bimbingan      |
| 🎓 Mahasiswa | [ages123@demo.com](mailto:ages123@demo.com)   | 23312120 | Pengajuan bimbingan     |

---

## 📖 Panduan Pengguna (User Manual)

### 🎓 Mahasiswa

**Mengajukan Bimbingan**

1. Klik tombol **(+)** atau menu **Ajukan Bimbingan**
2. Isi Judul, Deskripsi, serta Tanggal & Jam
3. Klik **Simpan**

**Status Bimbingan**

* 🟡 **Pending**: Menunggu respon dosen
* 🟢 **Disetujui**: Jadwal diterima
* 🔴 **Ditolak**: Periksa catatan revisi dari dosen

**Edit Pengajuan**

* Hanya dapat dilakukan jika status masih **Pending**
* Maksimal **30 menit** setelah pengajuan dibuat

---

### 👨‍🏫 Dosen

**Verifikasi Bimbingan**

* Melihat daftar pengajuan dari mahasiswa bimbingan

**Respon Pengajuan**

* **SETUJUI** untuk menerima jadwal
* **TOLAK** untuk menolak topik/jadwal
* Wajib mengisi **Catatan Dosen**

---

### 🛡️ Admin

**Manajemen User**

* Menambahkan user baru (Admin / Dosen / Mahasiswa)
* Penulisan role harus menggunakan huruf kecil:

  * `admin`
  * `dosen`
  * `mahasiswa`
* Dapat mengedit data user jika terjadi kesalahan input

---

## ❓ Pemecahan Masalah (Troubleshooting)

**Q: Login berhasil tetapi layar putih / muncul UID?**
**Penyebab:** Akun Auth berhasil dibuat, namun data user belum ada di Firestore.
**Solusi:**

1. Salin UID yang muncul
2. Login sebagai **Admin**
3. Tambahkan user baru dan masukkan UID tersebut

---

**Q: Muncul error merah `Permission Denied`?**
**Penyebab:** Firestore Security Rules tidak mengizinkan akses.
**Solusi:**
Gunakan rules berikut (mode development):

```
allow read, write: if request.auth != null;
```

---

**Q: Aplikasi loading terus-menerus?**
**Solusi:**

* Pastikan koneksi internet stabil
* Firebase membutuhkan koneksi online aktif

---

## 👨‍💻 Author

**Project Akhir – ANJUNGAN**
Dikembangkan menggunakan **Flutter** dan **Firebase** sebagai bagian dari tugas akhir.
