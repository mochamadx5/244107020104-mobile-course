# week4_api

## AI Verification Checklist

1. **Apakah UI memanggil Dio secara langsung (dilarang) atau lewat repository?**
   - Lewat repository (`PostRepository` / `CommentRepository`). UI (`PostListPage` dan `PagedPostPage`) hanya memantau state melalui provider Riverpod.

2. **Apakah `fromJson` aman null, atau masih memakai cast langsung yang bisa crash?**
   - Aman null. Menggunakan *nullable cast* (`as num?`, `as String?`) dengan nilai fallback (`?? 0`, `?? ''`) sehingga tidak crash saat ada field yang `null` atau hilang.

3. **Apakah semua tipe `DioExceptionType` (timeout, connectionError, badResponse) dipetakan ke pesan pengguna?**
   - Sudah dipetakan seluruhnya di fungsi `friendlyErrorMessage()` (mencakup `connectionTimeout`, `sendTimeout`, `receiveTimeout`, `connectionError`, `badResponse` status 404/500, `cancel`, dan `unknown`).

4. **Apakah `baseUrl`/timeout terpusat di satu client, bukan tersebar di tiap method?**
   - Terpusat di `lib/data/api_client.dart` melalui fungsi `createDio()` (`baseUrl: 'https://jsonplaceholder.typicode.com'`, `connectTimeout` & `receiveTimeout` 10 detik) dan dipakai bersama lewat `dioProvider`.

5. **Apakah test AI benar-benar menguji kasus field hilang, atau hanya happy path? Tambahkan minimal 1 edge case sendiri.**
   - Sudah menguji kasus *field* hilang (*missing fields*), ditambah 1 *edge case* mandiri berupa Map JSON kosong `{}` dan seluruh field bernilai `null`.

6. **Hasil `flutter analyze` dan `flutter test`:**
   - `flutter analyze`: Lolos tanpa warning (`No issues found!`).
   - `flutter test`: Lolos seluruh pengujian (`All tests passed!`).
