# Dokumentasi AI Challenge — Week 6
## Authentication, Firebase Cloud Messaging (FCM), dan Deep Linking

Dokumentasi ini mencatat prompt AI, ruang untuk menyimpan keluaran awal AI, checklist verifikasi, temuan audit, perbaikan manual, serta keputusan teknis untuk praktikum Week 6 pada aplikasi Flutter Campus Notification App.

---

## 1. AI Prompt Challenge

Prompt yang digunakan sesuai instruksi praktikum:

```text
Aplikasi Flutter Campus Notification App.
Stack: firebase_messaging, flutter_local_notifications,
flutter_secure_storage, go_router, Riverpod.
Buatkan PushService dengan:
- requestPermission + getToken + onTokenRefresh (kirim ke POST /devices)
- onMessage (tampilkan local notification manual)
- onMessageOpenedApp + getInitialMessage (navigasi ke data.route)
- subscribe/unsubscribe topic pengumuman-kampus
- background handler top-level dengan @pragma('vm:entry-point')
Tandai bagian yang BERBEDA untuk Android 13+ vs iOS,
dan bagian yang tidak boleh mengakses BuildContext.
```

## 2. Output Awal AI

> **Catatan:** Tempelkan hasil kode mentah dari AI pada bagian ini setelah prompt di atas dijalankan. Bagian ini sengaja disediakan sebagai tempat dokumentasi keluaran awal sebelum dilakukan audit dan perbaikan manual.

```dart
// Tempelkan kode mentah PushService dari keluaran awal AI di sini.
```

---

## 3. AI Verification Checklist & Temuan Audit Kode

Bagian ini merangkum hasil verifikasi terhadap `PushService` pada `lib/messaging/push_service.dart` dan konfigurasi proyek.

### 3.1. Background handler berupa fungsi top-level dengan `@pragma('vm:entry-point')`

- **Status:** **Lolos (Valid)**
- **Bukti dan analisis:** Fungsi `firebaseMessagingBackgroundHandler(RemoteMessage message)` diletakkan di luar kelas `PushService` sebagai fungsi *top-level* dan dilengkapi anotasi `@pragma('vm:entry-point')`.
- **Alasan teknis:** Saat aplikasi menerima pesan ketika berada di kondisi *background*, Firebase Messaging dapat menjalankan handler pada *isolate* terpisah. Handler harus berupa fungsi top-level dan dipertahankan dari proses *tree-shaking* agar dapat ditemukan saat runtime. Handler background juga tidak boleh bergantung pada `BuildContext` atau navigasi UI.

### 3.2. `onTokenRefresh` mengirim token baru ke backend

- **Status:** **Perlu Perbaikan Manual**
- **Temuan awal:** Listener `_fcm.onTokenRefresh.listen` hanya mencetak token ke konsol (`debugPrint`) dan menyertakan komentar `// Di sini token baru bisa dikirim ke server/backend`.
- **Perbaikan manual:** Tambahkan pemanggilan fungsi sinkronisasi ke endpoint backend `POST /devices`. Perbarui penyimpanan token lokal melalui `TokenStore` yang menggunakan `flutter_secure_storage`, sehingga token yang tersimpan di backend tetap mutakhir ketika FCM melakukan rotasi token perangkat.
- **Catatan implementasi:** Pastikan permintaan ke backend memiliki autentikasi yang sesuai, penanganan error, serta mekanisme pembaruan atau penggantian token perangkat yang sudah terdaftar.

### 3.3. Foreground menggunakan local notification secara manual

- **Status:** **Terverifikasi (Catatan Teknis Implementasi)**
- **Bukti dan analisis:** Secara default, `firebase_messaging` meneruskan pesan saat aplikasi aktif melalui `FirebaseMessaging.onMessage`. Tampilan notifikasi saat *foreground* tidak otomatis sama dengan tampilan notifikasi ketika aplikasi berada di *background*.
- **Observasi praktikum:** Saat pengujian pada perangkat fisik Realme (RMX3933) tanpa implementasi `flutter_local_notifications`, pesan *foreground* hanya muncul di log terminal (`Pesan diterima (foreground)`) dan tidak menampilkan pop-up visual.
- **Implikasi implementasi:** Untuk menampilkan notifikasi secara manual ketika aplikasi aktif, gunakan `FlutterLocalNotificationsPlugin.show()` dan konfigurasi channel Android yang sesuai, misalnya `AndroidNotificationChannel` dengan `Importance.max` jika memang membutuhkan notifikasi berprioritas tinggi.
- **Catatan:** Tampilan akhir tetap dipengaruhi oleh izin notifikasi, pengaturan channel, versi Android, serta pengaturan perangkat pengguna.

### 3.4. Klik notifikasi dari foreground, background, dan terminated menuju rute yang benar

- **Status:** **Terverifikasi melalui Tabel Pengujian**
- **Analisis:** Deep linking perlu menangani tiga jalur masuk yang berbeda:

  1. **Foreground:** Callback `onDidReceiveNotificationResponse` dari `flutter_local_notifications` menangani klik notifikasi lokal.
  2. **Background:** Stream `FirebaseMessaging.onMessageOpenedApp.listen()` menangani pengguna yang membuka notifikasi FCM ketika aplikasi masih berjalan di background.
  3. **Terminated (cold start):** `await FirebaseMessaging.instance.getInitialMessage()` memeriksa apakah aplikasi dibuka dari keadaan terminated melalui notifikasi FCM.

- **Ketentuan navigasi:** Ambil nilai rute dari `message.data['route']`, validasi bahwa rute tidak kosong dan diizinkan, lalu arahkan melalui instance `GoRouter` yang sudah tersedia.
- **Catatan implementasi:** Untuk notifikasi lokal yang membuka aplikasi dari keadaan terminated, simpan payload rute pada notifikasi dan periksa respons peluncuran awal dari plugin local notifications sesuai API versi yang digunakan. `getInitialMessage()` khusus menangani pesan FCM, bukan semua notifikasi lokal.

### 3.5. Token dan secret tidak di-hardcode atau dicetak utuh ke log

- **Status:** **Perlu Perbaikan Manual**
- **Temuan awal:** Kode awal AI menggunakan `debugPrint('FCM Token: $token')`, sehingga seluruh string token FCM dicetak ke log.
- **Perbaikan manual:**
  - Simpan token autentikasi pengguna secara aman menggunakan `flutter_secure_storage` melalui `TokenStore`; jangan menanamkan secret langsung di kode sumber.
  - Batasi log diagnostik pada mode debug dengan `kDebugMode`.
  - Lakukan *masking* token, misalnya hanya menampilkan delapan karakter awal: `${token.substring(0, 8)}...[MASKED]`.
  - Pastikan kode masking aman untuk token yang panjangnya kurang dari delapan karakter.
  - Hindari mencetak token autentikasi, secret, atau token FCM lengkap ke log produksi.

- **Catatan keamanan:** FCM registration token merupakan pengenal alamat tujuan pesan untuk sebuah instalasi aplikasi. Perlakukan token sebagai data sensitif operasional dan hindari membagikannya secara terbuka.

### 3.6. Keputusan final dan alasan teknis

#### A. Memisahkan `PushService` dari `BuildContext`

`PushService` merupakan *service layer* yang menangani siklus hidup dan aliran pesan. Karena itu, service tidak seharusnya bergantung pada `BuildContext` dari widget yang bisa sudah tidak aktif (*unmounted*).

Navigasi deep link dapat dilakukan melalui instance `GoRouter`, misalnya `router.go(route)`, atau callback navigasi terpisah yang tidak mengikat service pada konteks widget. Validasi rute sebelum navigasi juga diperlukan agar payload notifikasi tidak dapat mengarahkan aplikasi ke rute yang tidak diizinkan.

#### B. Menambahkan metadata channel default pada `AndroidManifest.xml`

Untuk Android 8.0 (API 26) dan yang lebih baru, notifikasi menggunakan notification channel. Metadata berikut dapat menetapkan channel default untuk notifikasi FCM yang tidak menentukan channel secara eksplisit:

```xml
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="high_importance_channel" />
```

Deklarasikan metadata tersebut di dalam elemen `<application>` pada `android/app/src/main/AndroidManifest.xml`. Pastikan channel bernama `high_importance_channel` benar-benar dibuat oleh aplikasi dan memiliki konfigurasi yang sesuai. Metadata saja tidak menjamin banner selalu muncul karena izin notifikasi, pengaturan channel, dan kebijakan sistem operasi tetap berlaku.

#### C. Menangani perbedaan Android 13+ dan iOS

- **Android 13+ (API 33+):** Aplikasi perlu meminta izin runtime `POST_NOTIFICATIONS` untuk menampilkan notifikasi. Status izin harus diperiksa dan alur permintaan izin ditangani dengan tepat.
- **iOS:** Minta otorisasi notifikasi melalui Firebase Messaging, konfigurasi kemampuan *Push Notifications* dan *Background Modes* yang diperlukan di Xcode, serta pastikan APNs dan Firebase sudah dikonfigurasi. Perilaku tampilan notifikasi saat foreground dapat diatur melalui konfigurasi presentasi iOS.
- **Catatan:** Periksa dokumentasi versi paket yang digunakan karena detail API dan konfigurasi dapat berubah ant versi.

#### D. Menyederhanakan dependensi pada build dan pengujian

Untuk menjaga kestabilan proses build Gradle dan menghindari konflik konfigurasi desugaring pada pengujian dasar, pengujian notifikasi utama difokuskan pada *system tray* ketika aplikasi berada di background atau terminated. Perilaku foreground diverifikasi secara terpisah melalui aliran `onMessage`, tampilan local notification bila sudah diimplementasikan, dan navigasi GoRouter.

Keputusan ini merupakan batasan ruang lingkup pengujian, bukan bukti bahwa pengujian banner foreground tidak diperlukan pada implementasi final.

---

## 4. Ringkasan Checklist Verifikasi

| No. | Aspek yang diverifikasi | Status | Tindak lanjut |
|---:|---|---|---|
| 1 | Background handler top-level dengan `@pragma('vm:entry-point')` | Lolos | Pastikan handler didaftarkan sebelum `runApp()` dan inisialisasi Firebase sesuai kebutuhan |
| 2 | `onTokenRefresh` mengirim token ke `POST /devices` | Perlu perbaikan manual | Implementasikan sinkronisasi backend dan pembaruan `TokenStore` |
| 3 | Notifikasi foreground ditampilkan secara manual | Terverifikasi dengan catatan | Implementasikan dan uji `FlutterLocalNotificationsPlugin.show()` |
| 4 | Klik notifikasi menangani foreground, background, dan terminated | Terverifikasi melalui tabel pengujian | Uji jalur notifikasi lokal dan FCM secara terpisah |
| 5 | Token/secret tidak di-hardcode atau dicetak utuh | Perlu perbaikan manual | Terapkan penyimpanan aman, log debug terbatas, dan masking |
| 6 | Service tidak bergantung pada `BuildContext` | Keputusan desain | Gunakan instance `GoRouter` atau callback navigasi |
| 7 | Default notification channel Android dikonfigurasi | Keputusan konfigurasi | Pastikan channel dibuat dan izin notifikasi tersedia |
| 8 | Perbedaan Android 13+ dan iOS ditandai | Perlu diverifikasi pada implementasi | Uji izin dan konfigurasi pada kedua platform |

---

## 5. Skenario Pengujian yang Disarankan

| No. | Kondisi aplikasi | Langkah pengujian | Hasil yang diharapkan |
|---:|---|---|---|
| 1 | Foreground | Kirim pesan FCM saat aplikasi sedang terbuka | Callback `onMessage` terpanggil; local notification tampil jika implementasi diaktifkan |
| 2 | Background | Kirim pesan FCM lalu ketuk notifikasi di system tray | Aplikasi terbuka dan diarahkan ke rute pada `data.route` |
| 3 | Terminated | Tutup aplikasi, kirim pesan FCM, lalu ketuk notifikasi | Aplikasi dimulai dan rute tujuan diproses melalui `getInitialMessage()` |
| 4 | Token refresh | Simulasikan atau tunggu perubahan registration token | Token baru disinkronkan ke `POST /devices` dan penyimpanan lokal diperbarui |
| 5 | Subscribe topic | Jalankan fungsi subscribe untuk `pengumuman-kampus` | Perangkat berlangganan ke topic jika permintaan berhasil |
| 6 | Unsubscribe topic | Jalankan fungsi unsubscribe untuk `pengumuman-kampus` | Perangkat berhenti menerima pesan melalui topic tersebut |
| 7 | Izin Android 13+ | Uji saat izin notifikasi belum diberikan | Aplikasi meminta izin dan menangani penolakan dengan benar |
| 8 | iOS | Uji izin, penerimaan pesan, dan presentasi foreground | Perilaku mengikuti otorisasi dan konfigurasi APNs/Firebase |
| 9 | Validasi rute | Kirim payload dengan `data.route` kosong atau tidak diizinkan | Aplikasi tidak melakukan navigasi ke rute yang tidak valid |
| 10 | Keamanan log | Periksa log debug dan log produksi | Token penuh dan secret tidak tercetak |

---

## 6. Catatan Implementasi dan Batasan

- Status **“Terverifikasi melalui Tabel Pengujian”** mengacu pada hasil pengujian yang dicatat dalam laporan praktikum. Simpan bukti tambahan berupa log, screenshot, atau hasil uji bila diperlukan untuk penilaian.
- `getInitialMessage()` menangani pembukaan aplikasi melalui notifikasi FCM, sedangkan respons peluncuran dari notifikasi lokal perlu ditangani melalui API `flutter_local_notifications`.
- `flutter_secure_storage` digunakan untuk menyimpan data sensitif lokal, tetapi tidak menggantikan autentikasi backend, validasi input, atau pengamanan komunikasi jaringan.
- Endpoint `POST /devices` perlu disesuaikan dengan kontrak API backend, termasuk format payload, autentikasi, respons, dan penanganan kegagalan jaringan.
- Jangan menganggap notifikasi pasti tampil hanya karena channel telah dikonfigurasi. Izin pengguna, pengaturan perangkat, payload FCM, serta konfigurasi Firebase/APNs turut memengaruhi hasil.

---

## 7. Kesimpulan

Praktikum Week 6 berfokus pada integrasi autentikasi perangkat untuk push notification, penanganan pesan FCM pada berbagai kondisi aplikasi, local notification saat foreground, dan navigasi deep link melalui GoRouter. Audit awal menunjukkan bahwa struktur background handler sudah sesuai, sedangkan sinkronisasi token ke backend dan perlindungan log masih memerlukan perbaikan manual.

Sebelum implementasi dinyatakan selesai, pastikan seluruh skenario pada checklist diuji pada perangkat target, termasuk izin notifikasi Android 13+, konfigurasi iOS, rotasi token, serta pembukaan aplikasi dari notifikasi FCM dan local notification.
