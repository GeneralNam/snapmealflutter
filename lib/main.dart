import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/custom_bottom_navigation.dart';
import 'providers/navigation_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'database/database_helper.dart';

const supabaseUrl = 'https://omjdminkjcpqnqysyztf.supabase.co';
const supabaseKey = String.fromEnvironment(
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9tamRtaW5ramNwcW5xeXN5enRmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk2MTI2MDcsImV4cCI6MjA1NTE4ODYwN30.oci1HqvsQ65QLARfK-FUBVHGRFd7YksNk6e9wVYu5cU');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.deleteDatabase(); // DB 삭제
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnapMeal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        scaffoldBackgroundColor: const Color(0xFFFBFAF8),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationProvider);
    final pages = [
      const HomeScreen(),
      const Scaffold(), // 통계 페이지 (아직 미구현)
      const SettingsScreen(),
    ];

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: const CustomBottomNavigation(),
    );
  }
}
