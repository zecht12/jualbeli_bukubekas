# Ujian Akhir Semester Pemrograman Lanjut: Jual Beli Buku Bekas

Saya memilih tema aplikasi Jual Beli Buku Bekas untuk proyek ini dengan bekerja sendiri tanpa anggota kelompok lainnya. Aplikasi ini dirancang dengan berbagai fitur yang komprehensif mulai dari autentikasi pengguna, manajemen produk (buku), fitur keranjang belanja, hingga fitur chat real-time antara penjual dan pembeli.

Pengembangan aplikasi ini dilakukan secara mandiri dengan perhatian khusus pada kemudahan penggunaan dan antarmuka yang modern. Setiap fitur dirancang agar intuitif, memastikan pengguna dapat menavigasi aplikasi dengan mudah. Dokumentasi ini menyajikan penjelasan rinci mengenai setiap fitur yang ada dalam aplikasi, dilengkapi dengan tangkapan layar terbaru.

Berikut adalah laporan hasil coding dan dokumentasi fitur aplikasi:

## 1. Halaman Login
![Halaman Login](public/login.jpeg)

Halaman login memiliki tampilan yang bersih dengan sapaan "Selamat Datang". Pengguna diminta memasukkan kredensial untuk masuk ke sistem.
- **Header**: Logo aplikasi dan teks sapaan.
- **Form**: Input field untuk Email dan Password (dengan fitur *toggle visibility*).
- **Navigasi**: Tombol "Masuk" dan link untuk mendaftar jika belum memiliki akun.

## 2. Halaman Registrasi
![Halaman Registrasi](public/register.jpeg)

Halaman ini digunakan untuk pendaftaran pengguna baru.
- **Header**: "Buat Akun" dengan sub-header instruksi.
- **Form**:
  - Nama Lengkap
  - Email
  - Password
  - Konfirmasi Password
- **Action**: Tombol "Daftar Sekarang" untuk menyimpan data ke database.

## 3. Halaman Beranda (Homepage)
![Halaman Beranda](public/homepage.jpeg)

Halaman utama aplikasi yang muncul setelah login. Halaman ini menjadi pusat navigasi bagi pengguna.
- **Banner**: Promosi visual "Buku Bekas, Ilmu Berkualitas".
- **Header Action**: Ikon Chat dan Keranjang Belanja di pojok kanan atas.
- **List Buku**: Menampilkan daftar buku "Terbaru Hari Ini" dengan gambar cover, judul, dan harga.
- **Floating Action Button**: Tombol "+ Jual Buku" untuk akses cepat menjual produk.
- **Bottom Navigation Bar**: Navigasi ke Beranda, Pesan, Toko Saya, Riwayat, Keranjang, dan Profil.

## 4. Halaman Jual Buku (Tambah Produk)
![Jual Buku](public/add%20buku.jpeg)

Fitur bagi pengguna untuk mengunggah buku yang ingin dijual.
- **Media**: Area untuk upload foto sampul buku.
- **Form Input**:
  - Judul Buku
  - Harga (Rp)
  - Stok
  - Kategori (Dropdown: misal Novel)
  - Kondisi (Dropdown: misal Bekas)
  - Deskripsi Buku

## 5. Halaman Produk Saya
![Produk Saya](public/list%20produk%20saya.jpeg)

Halaman manajemen untuk melihat daftar buku yang sedang dijual oleh pengguna.
- **List Item**: Menampilkan thumbnail, judul, stok, dan harga.
- **Actions**: Ikon pensil untuk mengedit detail buku dan ikon tempat sampah untuk menghapus buku dari daftar jual.

## 6. Halaman Keranjang Belanja
![Keranjang](public/keranjang.jpeg)

Halaman ini menampung buku yang akan dibeli pengguna. Tangkapan layar menunjukkan "Empty State" ketika keranjang kosong.
- **Visual**: Ikon keranjang dan teks informasi "Keranjang kamu kosong".
- **Action**: Tombol "Mulai Belanja" untuk mengarahkan pengguna kembali mencari buku.

## 7. Fitur Chat (Daftar Pesan)
![List Chat](public/list%20chat.jpeg)

Halaman yang memuat riwayat percakapan pengguna dengan pengguna lain (penjual/pembeli).
- **List Item**: Menampilkan avatar pengguna, nama lawan bicara, *preview* pesan terakhir, dan waktu pengiriman pesan.

## 8. Fitur Chat (Ruang Percakapan)
![Chat Room](public/chat%20room.jpeg)

Detail percakapan antar pengguna untuk negosiasi atau tanya jawab seputar buku.
- **Header**: Nama lawan bicara.
- **Bubble Chat**: Membedakan pesan masuk (kiri, abu-abu) dan pesan keluar (kanan, biru).
- **Input**: Kolom "Tulis pesan..." dan tombol kirim.

## 9. Halaman Profil Pengguna
![Profil Saya](public/profile.jpeg)

Menampilkan informasi detail akun pengguna yang sedang login.
- **Info Utama**: Foto profil, Nama, dan Email.
- **Detail**: Nomor HP dan Alamat Lengkap.
- **Edit**: Ikon pensil di pojok kanan atas untuk masuk ke mode edit.
- **Logout**: Tombol "Keluar" untuk mengakhiri sesi.

## 10. Halaman Edit Profil
![Edit Profil](public/edit%20profile.jpeg)

Formulir untuk memperbarui data diri pengguna.
- **Avatar**: Opsi untuk mengganti foto profil.
- **Form Edit**:
  - Nama Lengkap
  - Nomor HP
  - Alamat Lengkap
- **Action**: Tombol "Simpan Perubahan" untuk mengupdate data.

## 11. Riwayat Pembelian (Pembeli)
![Riwayat Pembelian](public/riwayat%20transaksi%20pembelian.jpeg)

Tab "Pembelian Saya" menampilkan daftar pesanan yang telah dilakukan oleh pengguna sebagai pembeli.
- **Info Pesanan**: Menampilkan ID Order, item yang dibeli, dan total harga.
- **Status**: Indikator status pesanan (misalnya "Selesai") dan informasi apakah pesanan sudah diulas.

## 12. Manajemen Pesanan Masuk (Penjual)
![Pesanan Masuk](public/riwayat%20transaksi%20masuk.jpeg)

Tab "Pesanan Masuk" ditujukan bagi pengguna saat bertindak sebagai penjual. Di sini pengguna dapat mengelola pesanan yang masuk dari pembeli lain.
- **List Order**: Daftar pesanan yang perlu diproses.
- **Kontrol Status**: Tombol interaktif untuk memperbarui status pesanan secara bertahap:
  - **Dikemas**: Menandai barang sedang disiapkan.
  - **Dikirim**: Menandai barang sudah dalam pengiriman.
  - **Selesai**: Menandai transaksi telah rampung.
