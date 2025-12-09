import 'package:_abm/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'dbmodels/models.dart';
import 'dbmodels/profile.dart';
import 'responsive/desktop.dart';
import 'responsive/mobile.dart';
import 'responsive/responsive_layout.dart';
import 'responsive/tablet.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://hhezduzrlkojnerxuvbv.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhoZXpkdXpybGtvam5lcnh1dmJ2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUyODY1NDksImV4cCI6MjA4MDg2MjU0OX0.f0ZslLkPIssqiNVQYcRdXyaTGUg1RutL-gDN37YYbpo',
  );

  // if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(ProfileAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(StudentAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(CollectionAdapter());

  await Hive.openBox<Profile>('profileBox');
  await Hive.openBox<Collection>('collectionsBox');
  await Hive.openBox('myBox');
  // await Hive.openBox('myBox');
  await Hive.openBox('calcHistory');
  await Hive.openBox('settingsBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeManager,
      builder: (context, themeMode, child) {
        return MaterialApp(
          title: 'A B M',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF7F9FC), // Light BG
            primaryColor: const Color(0xFF0A57FF), // Electric Blue
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0A57FF),
              secondary: Color(0xFFD7D7D7), // Secondary Button
              surface: Color(0xFFFFFFFF), // Card
              onSurface: Color(0xFF000000), // Primary Text
              onSurfaceVariant: Color(0xFF555555), // Secondary Text
              outline: Color(0xFFCFCFCF), // Borders
              shadow: Color(0xFFE5E5E5),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFF7F9FC),
              elevation: 0,
              iconTheme: IconThemeData(color: Color(0xFF000000)),
              titleTextStyle: TextStyle(color: Color(0xFF000000), fontSize: 20),
            ),
            cardColor: const Color(0xFFFFFFFF),
            dividerColor: const Color(0xFFCFCFCF),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF000000), // Deep Black
            primaryColor: const Color(0xFF0A57FF), // Neon Electric Blue
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF0A57FF),
              secondary: Color(0xFFB8B8B8), // Secondary Button
              surface: Color(0xFF111111), // Dark Card
              onSurface: Color(0xFFFFFFFF), // Primary Text
              onSurfaceVariant: Color(0xFFB8B8B8), // Secondary Text
              outline: Color(0xFF1F1F1F), // Outline Stroke
              tertiary: Color(0xFF2F8DFF), // Icon Highlight
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF000000),
              elevation: 0,
              iconTheme: IconThemeData(color: Color(0xFFFFFFFF)),
              titleTextStyle: TextStyle(color: Color(0xFFFFFFFF), fontSize: 20),
            ),
            cardColor: const Color(0xFF111111),
            dividerColor: const Color(0xFF1F1F1F),
            useMaterial3: true,
          ),
          home: const ResponsiveLayout(
            mobileScaffold: MobileScreen(),
            tabletScaffold: TabletScreen(),
            desktopScaffold: DesktopScreen(),
          ),
        );
      },
    );
  }
}
