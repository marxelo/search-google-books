import 'package:flutter/material.dart';
import 'package:gbooks/pages/my_home_page.dart';
import 'package:gbooks/utils/color_schemes.g.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ligrá',
      theme: _buildTheme(),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
      home: const MyHomePage(title: 'Ligrá - Livros Grátis'),
    );
  }

  ThemeData _buildTheme() {
    var baseTheme = ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
        bottomSheetTheme: const BottomSheetThemeData(
          surfaceTintColor: Colors.white,
        ));

    return baseTheme.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme),
    );
  }
}
