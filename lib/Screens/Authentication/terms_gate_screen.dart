import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:odadee/components/web_view_page.dart';
import 'package:odadee/constants.dart';
import 'package:odadee/services/auth_service.dart';

const _termsVersion = '2026-08-05';
const _pendingAcceptanceKey = 'terms_pending_acceptance';
const _secureStorage = FlutterSecureStorage();

Future<String> _acceptanceKey() async {
  final userId = await _secureStorage.read(key: 'user_id');
  return 'terms_accepted_${userId?.isNotEmpty == true ? userId : 'anonymous'}';
}

Future<void> markTermsAcceptedForNewSignup() async {
  final preferences = await SharedPreferences.getInstance();
  await preferences.setString(_pendingAcceptanceKey, _termsVersion);
}

Future<bool> hasAcceptedCurrentTerms() async {
  final preferences = await SharedPreferences.getInstance();
  final key = await _acceptanceKey();
  final hasPendingSignupAcceptance =
      preferences.getString(_pendingAcceptanceKey) == _termsVersion;

  try {
    final response = await AuthService().authenticatedRequest(
      'GET',
      '/api/terms/status',
    );
    if (response.statusCode != 200) return false;

    final status = jsonDecode(response.body) as Map<String, dynamic>;
    final version = status['currentVersion']?.toString() ?? _termsVersion;
    if (status['accepted'] == true) {
      await preferences.setString(key, version);
      return true;
    }

    if (hasPendingSignupAcceptance) {
      final accepted = await _acceptTermsOnServer(version);
      if (accepted) {
        await preferences.setString(key, version);
        await preferences.remove(_pendingAcceptanceKey);
      }
      return accepted;
    }
    return false;
  } catch (_) {
    return false;
  }
}

Future<bool> _acceptTermsOnServer(String version) async {
  try {
    final response = await AuthService().authenticatedRequest(
      'POST',
      '/api/terms/accept',
      body: {'version': version},
    );
    return response.statusCode == 200 || response.statusCode == 201;
  } catch (_) {
    return false;
  }
}

Future<bool> acceptCurrentTermsForAuthenticatedUser() async {
  var version = _termsVersion;
  try {
    final statusResponse = await AuthService().authenticatedRequest(
      'GET',
      '/api/terms/status',
    );
    if (statusResponse.statusCode == 200) {
      final status = jsonDecode(statusResponse.body) as Map<String, dynamic>;
      version = status['currentVersion']?.toString() ?? version;
    }
  } catch (_) {
    return false;
  }

  final accepted = await _acceptTermsOnServer(version);
  if (!accepted) return false;
  final preferences = await SharedPreferences.getInstance();
  await preferences.setString(await _acceptanceKey(), version);
  await preferences.remove(_pendingAcceptanceKey);
  return true;
}

class TermsGateScreen extends StatefulWidget {
  const TermsGateScreen({super.key, required this.onAccepted});

  final VoidCallback onAccepted;

  @override
  State<TermsGateScreen> createState() => _TermsGateScreenState();
}

class _TermsGateScreenState extends State<TermsGateScreen> {
  bool _acceptedTerms = false;
  bool _acceptedPrivacy = false;
  bool _isSaving = false;
  String _currentVersion = _termsVersion;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCurrentVersion();
  }

  Future<void> _loadCurrentVersion() async {
    try {
      final response = await AuthService().authenticatedRequest(
        'GET',
        '/api/terms/status',
      );
      if (response.statusCode != 200) return;
      final status = jsonDecode(response.body) as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          _currentVersion =
              status['currentVersion']?.toString() ?? _termsVersion;
        });
      }
    } catch (_) {
      // Acceptance surfaces a retry message if the API is unavailable.
    }
  }

  Future<void> _accept() async {
    if (!_acceptedTerms || !_acceptedPrivacy || _isSaving) return;
    setState(() {
      _isSaving = true;
      _error = null;
    });
    final accepted = await _acceptTermsOnServer(_currentVersion);
    if (!mounted) return;
    if (!accepted) {
      setState(() {
        _isSaving = false;
        _error =
            'Could not record your acceptance. Check your connection and try again.';
      });
      return;
    }
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(await _acceptanceKey(), _currentVersion);
    await preferences.remove(_pendingAcceptanceKey);
    if (!mounted) return;
    widget.onAccepted();
  }

  void _openDocument(String title, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WebViewPage(title: title, url: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: odaBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: odaBackground,
        title: const Text('Community terms'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.verified_user_outlined,
                color: odaSecondary,
                size: 52,
              ),
              const SizedBox(height: 20),
              const Text(
                'Before you continue',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Please review and accept the current terms that govern your use of the Odadee community.',
                style: TextStyle(color: bodyText2, height: 1.5),
              ),
              const SizedBox(height: 28),
              CheckboxListTile(
                value: _acceptedTerms,
                contentPadding: EdgeInsets.zero,
                activeColor: odaPrimary,
                title: const Text(
                  'I accept the Terms of Service',
                  style: TextStyle(color: Colors.white),
                ),
                secondary: IconButton(
                  tooltip: 'Read Terms of Service',
                  icon: const Icon(Icons.open_in_new, color: odaSecondary),
                  onPressed: () => _openDocument(
                    'Terms of Service',
                    'https://odadee.net/terms-service',
                  ),
                ),
                onChanged: (value) =>
                    setState(() => _acceptedTerms = value ?? false),
              ),
              CheckboxListTile(
                value: _acceptedPrivacy,
                contentPadding: EdgeInsets.zero,
                activeColor: odaPrimary,
                title: const Text(
                  'I accept the Privacy Policy',
                  style: TextStyle(color: Colors.white),
                ),
                secondary: IconButton(
                  tooltip: 'Read Privacy Policy',
                  icon: const Icon(Icons.open_in_new, color: odaSecondary),
                  onPressed: () => _openDocument(
                    'Privacy Policy',
                    'https://odadee.net/privacy-policy',
                  ),
                ),
                onChanged: (value) =>
                    setState(() => _acceptedPrivacy = value ?? false),
              ),
              const Spacer(),
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _acceptedTerms && _acceptedPrivacy ? _accept : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: odaPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Accept and continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
