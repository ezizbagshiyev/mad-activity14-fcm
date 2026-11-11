import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FCMService {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  StreamSubscription<RemoteMessage>? _foreground;
  StreamSubscription<RemoteMessage>? _opened;
  StreamSubscription<String>? _tokenRefresh;
  bool _started = false;
  bool _disposed = false;

  Future<void> initialize({
    required void Function(RemoteMessage, String) onData,
    required void Function(String) onStatus,
  }) async {
    if (_started || _disposed) {
      throw StateError('Initialize a new service instance only once.');
    }
    _started = true;
    void receive(String source, RemoteMessage message) {
      if (!_disposed) onData(message, source);
    }

    void streamError(Object error, StackTrace stack) {
      debugPrint('FCM stream error: $error\n$stack');
      if (!_disposed) onStatus('Messaging stream error: $error');
    }

    _foreground = FirebaseMessaging.onMessage.listen(
      (message) => receive('onMessage', message),
      onError: streamError,
    );
    _opened = FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => receive('onMessageOpenedApp', message),
      onError: streamError,
    );
    final initial = await messaging.getInitialMessage();
    if (_disposed) return;
    if (initial != null) receive('getInitialMessage', initial);
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (_disposed) return;
    onStatus('Permission: ${settings.authorizationStatus.name}');
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      final apns = await messaging.getAPNSToken();
      if (_disposed) return;
      if (apns == null) throw StateError('APNs token is not ready.');
    }
    _tokenRefresh = messaging.onTokenRefresh.listen((token) {
      if (_disposed) return;
      debugPrint('FCM token refreshed (development only): $token');
      onStatus('Token refreshed; use the current installation token.');
    }, onError: streamError);
    final token = await messaging.getToken();
    if (_disposed) return;
    if (token == null) throw StateError('No FCM token; check device setup.');
    debugPrint('FCM token (development only): $token');
  }

  Future<void> dispose() async {
    _disposed = true;
    await Future.wait([
      if (_foreground != null) _foreground!.cancel(),
      if (_opened != null) _opened!.cancel(),
      if (_tokenRefresh != null) _tokenRefresh!.cancel(),
    ]);
  }
}
