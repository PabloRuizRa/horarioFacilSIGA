import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'data/models/asignatura.dart';
import 'data/models/bloque.dart';
import 'data/models/horario.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();
  Hive.registerAdapter(AsignaturaAdapter());
  Hive.registerAdapter(BloqueAdapter());
  Hive.registerAdapter(HorarioAdapter());
  await Hive.openBox<Horario>('horarios');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Horarios UTFSM',
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
