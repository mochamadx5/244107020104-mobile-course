# Week 01 - Mobile Development Ecosystem & Flutter Refresh

**Nama:** Mochamad Reza Firdaus  
**NIM:** 244107020104  
**Kelas:** TI  

---

## Hasil Praktikum
![Screenshot Aplikasi](screenshots/app_profile.jpg)

## Kendala dan Solusi
* **Kendala Memori Build:** Mengalami kegagalan daemon disappeared saat kompilasi Gradle pertama karena alokasi memori default mencoba meminta 8 GB RAM pada sistem dengan kapasitas fisik 4 GB.
* **Solusi:** Menambahkan batas memori pada ndroid/gradle.properties (org.gradle.jvmargs=-Xmx1536m -XX:MaxMetaspaceSize=512m), menghentikan daemon yang macet, serta mengatur Windows Paging File ke 6-8 GB.

---

## Jawaban Refleksi
1. **Kapan native lebih tepat dipilih daripada cross-platform?**
Ketika aplikasi membutuhkan akses perangkat keras atau sensor tingkat rendah tanpa lapisan perantara, integrasi API sistem operasi paling mutakhir pada hari pertama rilis, atau performa grafis intensif seperti game 3D.
2. **Bagaimana perubahan state berhubungan dengan widget tree dan UI deklaratif?**
Dalam model deklaratif Flutter, antarmuka adalah representasi langsung dari state saat itu. Perubahan state akan memicu pemanggilan ulang metode uild(), yang kemudian merekonstruksi bagian pohon widget terkait secara efisien tanpa manipulasi elemen secara imperatif.
3. **Mengapa commit kecil dengan pesan jelas bermanfaat bagi pekerjaan tim dan portofolio?**
Memudahkan pelacakan riwayat kode, mempercepat proses review dan isolasi bug, meminimalkan potensi konflik merge saat kolaborasi tim, serta memperlihatkan kedisiplinan dan profesionalitas alur kerja version control pada portofolio.
