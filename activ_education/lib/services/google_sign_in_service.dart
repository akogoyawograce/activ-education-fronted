import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';

class GoogleSignInService {
  static final GoogleSignInService _instance = GoogleSignInService._internal();
  factory GoogleSignInService() => _instance;
  GoogleSignInService._internal();

  final _googleSignIn = GoogleSignIn.instance;
  final _storage = const FlutterSecureStorage();
  final _api = ApiService();
  bool _initialized = false;

  static const _keyPrefix = 'google_link_';

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await _googleSignIn.initialize();
      _initialized = true;
    }
  }

  Future<GoogleSignInAccount?> signIn() async {
    await _ensureInitialized();
    try {
      return await _googleSignIn.authenticate();
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  Future<void> disconnect() async {
    await _googleSignIn.disconnect();
  }

  Future<String?> getLinkedTrackingId(String email) async {
    return await _storage.read(key: '$_keyPrefix$email');
  }

  Future<void> linkTrackingId(String email, String trackingId) async {
    await _storage.write(key: '$_keyPrefix$email', value: trackingId);
  }

  Future<Map<String, String>?> signInAndGetProfile() async {
    final account = await signIn();
    if (account == null) return null;
    return {
      'email': account.email,
      'displayName': account.displayName ?? account.email,
      'photoUrl': account.photoUrl ?? '',
    };
  }

  Future<bool> tryAutoLogin(String email) async {
    final trackingId = await getLinkedTrackingId(email);
    if (trackingId == null) return false;
    final role = await _storage.read(key: 'user_role');
    if (role == null) return false;
    await _api.auth.saveUserData(trackingId: trackingId, role: role);
    return true;
  }
}
