import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // .env is optional in MVP mode; app must still run fully offline.
  await dotenv.load(fileName: '.env', isOptional: true);
  runApp(const ProviderScope(child: LearnGridApp()));
}
