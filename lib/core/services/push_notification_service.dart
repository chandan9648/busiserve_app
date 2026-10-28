import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../config/flavor_config.dart';
import '../utils/app_logger.dart';
import 'auth_session.dart';
import 'prefs_service.dart';

/// Subscribes every device to [broadcastTopic], registers it for personal
/// notifications after sign-in, and opens the relevant screen when a
/// notification is tapped.
class PushNotificationService extends GetxService {
  PushNotificationService({required this.session, required this.prefs});

  final AuthSession session;
  final PrefsService prefs;

  /// Every device with notifications on is subscribed to this topic, so the
  /// Firebase console can reach all users (Messaging → target Topic `all`).
  static const String broadcastTopic = 'all';

  /// Only these in-app destinations may be opened from a notification payload.
  static const List<String> allowedRoutePrefixes = [
    '/my-enquiries',
    '/quotations/',
    '/projects',
    '/projects/',
    '/tickets/',
    '/notifications',
  ];

  final List<StreamSubscription<dynamic>> _subs = [];
  Worker? _authWorker;
  String? _registeredToken;
  Future<bool>? _permissionRequest;

  bool get _supported => FirebaseStatus.isReady && !kIsWeb;
  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  @override
  void onInit() {
    super.onInit();
    if (!_supported) return;
    _subs
      ..add(FirebaseMessaging.onMessage.listen(_onForeground))
      ..add(FirebaseMessaging.onMessageOpenedApp.listen(_openFrom));
    _authWorker = ever<String?>(session.currentUid, (uid) {
      if (uid != null && prefs.pushEnabled) unawaited(register(uid));
    });
    unawaited(_messaging.getInitialMessage().then((m) {
      if (m != null) _openFrom(m);
    }),);
    if (prefs.pushEnabled) unawaited(subscribeToBroadcasts());
    final uid = session.uid;
    if (uid != null && prefs.pushEnabled) unawaited(register(uid));
  }

  /// Concurrent callers share one system prompt.
  Future<bool> requestPermission() {
    if (!_supported) return Future.value(false);
    return _permissionRequest ??= _askPermission().whenComplete(() => _permissionRequest = null);
  }

  Future<bool> _askPermission() async {
    final settings = await _messaging.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Works for guests too; no Firestore write is involved.
  Future<void> subscribeToBroadcasts() async {
    if (!_supported) return;
    try {
      if (!await requestPermission()) return;
      await _messaging.subscribeToTopic(broadcastTopic);
    } catch (e, st) {
      AppLogger.error('broadcast subscribe failed', error: e, stackTrace: st);
    }
  }

  Future<void> register(String uid) async {
    if (!_supported) return;
    try {
      if (!await requestPermission()) return;
      final token = await _messaging.getToken();
      if (token == null) return;
      await _saveToken(uid, token);
      _subs.add(_messaging.onTokenRefresh.listen((t) {
        final current = session.uid;
        if (current != null) unawaited(_saveToken(current, t));
      }),);
    } catch (e, st) {
      AppLogger.error('push registration failed', error: e, stackTrace: st);
    }
  }

  /// Call before signing out, while the user can still write their own docs.
  /// Deleting the token also drops topic subscriptions, so the new token is
  /// re-subscribed unless notifications were switched off.
  Future<void> unregister() async {
    if (!_supported) return;
    final uid = session.uid;
    final token = _registeredToken;
    try {
      if (uid != null && token != null) {
        await FirebaseFirestore.instance.doc('users/$uid/devices/$token').delete();
      }
      await _messaging.deleteToken();
    } catch (e, st) {
      AppLogger.error('push unregister failed', error: e, stackTrace: st);
    } finally {
      _registeredToken = null;
    }
    if (prefs.pushEnabled) unawaited(subscribeToBroadcasts());
  }

  Future<void> _saveToken(String uid, String token) async {
    await FirebaseFirestore.instance.doc('users/$uid/devices/$token').set({
      'platform': defaultTargetPlatform.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    _registeredToken = token;
  }

  void _onForeground(RemoteMessage message) {
    final n = message.notification;
    if (n == null) return;
    Get.snackbar(
      n.title ?? 'Busiserve',
      n.body ?? '',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 5),
      onTap: (_) => _openFrom(message),
    );
  }

  void _openFrom(RemoteMessage message) {
    final route = message.data['route'];
    if (route is String && isAllowedRoute(route)) {
      Get.toNamed(route);
    }
  }

  /// Also used by the in-app notification list.
  static bool isAllowedRoute(String route) {
    if (route.contains('..') || route.contains('://')) return false;
    return allowedRoutePrefixes.any(
      (p) => p.endsWith('/') ? route.startsWith(p) && route.length > p.length : route == p,
    );
  }

  @override
  void onClose() {
    for (final s in _subs) {
      s.cancel();
    }
    _authWorker?.dispose();
    super.onClose();
  }
}
