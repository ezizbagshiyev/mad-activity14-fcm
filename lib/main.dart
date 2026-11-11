import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'fcm_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('onBackgroundMessage: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Activity 14: FCM',
    theme: ThemeData(colorSchemeSeed: Colors.teal),
    home: const HomePage(),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FCMService _fcmService = FCMService();
  static const _assets = {
    'default': 'assets/images/default.png',
    'promo': 'assets/images/promo.png',
  };
  String _title = 'Waiting for a cloud message';
  String _image = _assets['default']!;
  String _feedback = 'Initializing messaging...';
  String _handler = 'None yet';
  String _messageId = 'None yet';
  int _count = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_initialize());
  }

  void _report(String text) {
    if (mounted) setState(() => _feedback = text);
  }

  Future<void> _initialize() async {
    try {
      await _fcmService.initialize(onData: _handle, onStatus: _report);
    } catch (error, stack) {
      debugPrint('Messaging error: $error\n$stack');
      _report('Messaging error: $error');
    }
  }

  void _handle(RemoteMessage message, String source) {
    if (!mounted) return;
    final path = _assets[message.data['asset']];
    setState(() {
      _handler = source;
      _messageId = message.messageId ?? '(no ID)';
      _count++;
      if (message.data['action'] != 'update_ui' || path == null) {
        _feedback =
            'Rejected payload: use action=update_ui and '
            'asset=default or asset=promo. Previous content preserved.';
        return;
      }
      _title = message.notification?.title ?? 'Payload received';
      _image = path;
      _feedback = 'Applied payload $_messageId';
    });
  }

  @override
  void dispose() {
    unawaited(
      _fcmService.dispose().catchError((Object e, StackTrace s) {
        debugPrint('FCM cleanup error: $e\n$s');
      }),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Activity 14: FCM')),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(_title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Image.asset(
          _image,
          height: 180,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stack) => Text('Cannot load $_image'),
        ),
        const SizedBox(height: 16),
        Text('Last handler: $_handler'),
        Text('Messages handled this launch: $_count'),
        Text('Last message ID: $_messageId'),
        const SizedBox(height: 16),
        Text(_feedback),
      ],
    ),
  );
}
