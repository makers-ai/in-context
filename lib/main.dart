import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:incontext/core/app/app.dart';
import 'package:incontext/core/config/firebase_config.dart';
import 'package:incontext/core/config/flavor_config.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize AppConfig first (also loads .env file)
  await AppConfig.initialize();

  // Initialize Firebase
  final firebaseConfig = FirebaseConfig();
  await firebaseConfig.initialize();

  FlutterNativeSplash.remove();

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
