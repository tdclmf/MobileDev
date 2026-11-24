import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Supabase/supabase.dart';
import 'package:flutter_application_1/Supabase/supabase_auth_component.dart';
import 'package:flutter_application_1/firebase.dart';
import 'package:flutter_application_1/firebase_auth_component.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
  var supabaseEnabled = false;
  var firebaseEnabled = false;
  final errors = <String>[];

  if (supabaseUrl.isNotEmpty || supabaseKey.isNotEmpty) {
    try {
      final uri = Uri.tryParse(supabaseUrl);
      if (uri == null ||
          uri.scheme != 'https' ||
          uri.host.isEmpty ||
          supabaseKey.isEmpty) {
        throw const FormatException(
          'Укажите HTTPS URL и публичный ключ Supabase.',
        );
      }
      await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseKey);
      supabaseEnabled = true;
    } catch (_) {
      errors.add('Не удалось подключить Supabase. Проверьте настройки и сеть.');
    }
  }

  try {
    final options = DefaultFirebaseOptions.currentPlatform;
    if (options != null) {
      await Firebase.initializeApp(options: options);
      firebaseEnabled = true;
    }
  } catch (_) {
    errors.add('Не удалось подключить Firebase. Проверьте настройки и сеть.');
  }

  runApp(
    MyApp(
      supabaseEnabled: supabaseEnabled,
      firebaseEnabled: firebaseEnabled,
      setupError: errors.isEmpty ? null : errors.join('\n'),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    this.supabaseEnabled = false,
    this.firebaseEnabled = false,
    this.setupError,
  });

  final bool supabaseEnabled;
  final bool firebaseEnabled;
  final String? setupError;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MobileDev',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (_) => MyHomePage(
          supabaseEnabled: supabaseEnabled,
          firebaseEnabled: firebaseEnabled,
          setupError: setupError,
        ),
        '/supabase': (_) =>
            supabaseEnabled ? const SupabasePage() : const BackendSetupPage(),
        '/supabase/auth': (_) => supabaseEnabled
            ? const SupabaseAuthPage()
            : const BackendSetupPage(),
        '/firebase': (_) =>
            firebaseEnabled ? const FirebasePage() : const BackendSetupPage(),
        '/firebase/auth': (_) => firebaseEnabled
            ? const FirebaseAuthPage()
            : const BackendSetupPage(),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({
    super.key,
    required this.supabaseEnabled,
    required this.firebaseEnabled,
    this.setupError,
  });

  final bool supabaseEnabled;
  final bool firebaseEnabled;
  final String? setupError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MobileDev — главное меню')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            spacing: 20,
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: supabaseEnabled
                    ? () => Navigator.pushNamed(context, '/supabase')
                    : null,
                child: const Text('Supabase'),
              ),
              ElevatedButton(
                onPressed: firebaseEnabled
                    ? () => Navigator.pushNamed(context, '/firebase')
                    : null,
                child: const Text('Firebase'),
              ),
              if (!supabaseEnabled || !firebaseEnabled)
                const Text(
                  'Подключите свои Supabase и Firebase по инструкции в README.',
                  textAlign: TextAlign.center,
                ),
              if (setupError != null)
                Text(
                  setupError!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class BackendSetupPage extends StatelessWidget {
  const BackendSetupPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Настройка подключения')),
    body: const Center(
      child: Text(
        'Подключите свой проект по инструкции в README.',
        textAlign: TextAlign.center,
      ),
    ),
  );
}
