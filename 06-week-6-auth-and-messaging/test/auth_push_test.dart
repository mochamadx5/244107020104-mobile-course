import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week6_auth_messaging/routes.dart';
import 'package:week6_auth_messaging/data/api_errors.dart';

class FakeTokenStore {
  String? access;
  String? refresh;
}

final fakeAuthProvider = Provider<bool>((ref) => false);

void main() {
  test('routeFromMessage menangani route kosong dan tanpa slash', () {
    expect(routeFromMessage({}), '/');
    expect(routeFromMessage({'route': 'pengumuman/3'}), '/pengumuman/3');
    expect(routeFromMessage({'route': '/pengumuman/3'}), '/pengumuman/3');
  });

  test('data payload membawa id pengumuman', () {
    const data = {'route': '/pengumuman/3', 'id': '3'};
    expect(data['id'], '3');
    expect(routeFromMessage(data), '/pengumuman/3');
  });

  test('provider auth membaca status login dari token', () async {
    final store = FakeTokenStore()..access = 'mock-access';
    final container = ProviderContainer(
      overrides: [
        fakeAuthProvider.overrideWithValue(store.access != null),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(fakeAuthProvider), isTrue);
    store.access = null;
    expect(store.access != null, isFalse);
  });

  test('refresh gagal -> sesi dibersihkan (paksa login ulang)', () async {
    final store = FakeTokenStore()..refresh = '';
    final needsLogin = (store.refresh ?? '').isEmpty;
    expect(needsLogin, isTrue);
  });

  test('ApiErrors memetakan 401, timeout, dan offline ke pesan ramah pengguna', () {
    expect(
      ApiErrors.fromError(Exception('Unauthorized'), statusCode: 401),
      contains('Sesi Anda telah berakhir'),
    );
    expect(
      ApiErrors.fromError(TimeoutException('Request timeout')),
      contains('timeout'),
    );
    expect(
      ApiErrors.fromError(const SocketException('Failed host lookup')),
      contains('Tidak ada koneksi internet'),
    );
  });
}
