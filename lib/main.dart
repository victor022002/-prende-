import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'modulos/auth/login_screen.dart';
import 'modulos/auth/register_screen.dart';
import 'modulos/home/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '/models/student_model.dart';
import 'modulos/syllables/word_lists.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ⭐ Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ⭐ Inicializar Supabase
  await supa.Supabase.initialize(
    url: 'https://eqxughixyacnyeszyjna.supabase.co',       
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxeHVnaGl4eWFjbnllc3p5am5hIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUyODA0OTIsImV4cCI6MjA4MDg1NjQ5Mn0.45TTu8Ar3jgkVQKV0VVtoL3vCXHz5NUynC9PgA1yYYE', 
  );

  await loadAdminWordsIntoLists();

  runApp(const AprendeApp());
}

class AprendeApp extends StatelessWidget {
  const AprendeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '@prende+',

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lightBlueAccent,
        ),
        textTheme: GoogleFonts.baloo2TextTheme(),
      ),

      // 🌍 Español
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
      ],

      // 🔥 RUTAS AÑADIDAS AQUI
      routes: {
        "/login": (_) => const LoginScreen(),
        "/register": (_) => const RegisterScreen(),
      },

      // 🔐 Mantener sesión Firebase
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            final user = snapshot.data!;

            final student = Student(
              id: user.uid.hashCode,
              name: user.email?.split('@').first ?? 'Alumno',
              email: user.email ?? '',
            );

            return HomeScreen(student: student);
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
