import 'package:dosey/features/auth/data/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeUserInfo extends Fake implements UserInfo {
  _FakeUserInfo(this.providerId);

  @override
  final String providerId;
}

class _FakeUser extends Fake implements User {
  _FakeUser({required this.emailVerified, required String provider})
    : providerData = [_FakeUserInfo(provider)];

  @override
  final bool emailVerified;

  @override
  final List<UserInfo> providerData;
}

void main() {
  test('an unconfirmed email/password account must verify first', () {
    expect(
      AuthRepository.needsEmailVerification(
        _FakeUser(emailVerified: false, provider: 'password'),
      ),
      isTrue,
    );
  });

  test('a confirmed email, or a Google account, goes straight in', () {
    expect(
      AuthRepository.needsEmailVerification(
        _FakeUser(emailVerified: true, provider: 'password'),
      ),
      isFalse,
    );
    expect(
      AuthRepository.needsEmailVerification(
        _FakeUser(emailVerified: false, provider: 'google.com'),
      ),
      isFalse,
    );
  });
}
