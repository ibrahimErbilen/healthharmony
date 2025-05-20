import 'dart:io';
import 'package:flutter/material.dart';
import 'package:healthharmony/screens/calories_burned.dart';
import 'package:healthharmony/screens/calories_consumed.dart';
import 'package:healthharmony/screens/coach_screen.dart';
import 'package:healthharmony/screens/conversations_screen.dart';
import 'package:healthharmony/screens/gemini_au_screen.dart';
import 'package:healthharmony/screens/profile_screen.dart';
import 'package:healthharmony/screens/settings_screen.dart';
import 'package:healthharmony/screens/step_count.dart';
import 'package:healthharmony/utils/my_http_overrides.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/register_screen.dart';
import 'screens/activities_screen.dart';
import 'screens/browse_activities_screen.dart';
import 'utils/secure_storage.dart';
import 'utils/navigation_service.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides(); 
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NavigationService navigationService = NavigationService();
    
    return MaterialApp(
      title: 'HealthHarmony',
      navigatorKey: NavigationService().navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0),)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Colors.blue, width: 2.0),
          ),
        ),
      ),
       debugShowCheckedModeBanner: false,
      home: const AuthCheckScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/activities': (context) => const ActivitiesScreen(),
        '/activities/browse': (context) => const BrowseActivitiesScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/gemini': (context) => const GeminiAuScreen(),
        '/step-count' : (context) => StepCountPage(),
        '/caloriesConsumed' : (context) => CaloriesConsumedPage(),
        '/caloriesBurned' : (context) => CaloriesBurnedPage(),
        '/coach' : (context) => CoachSearchPage(),
        '/conversation': (context) => FutureBuilder<String?>(
          future: _getCurrentUserId(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              final currentUserId = snapshot.data;
              return ConversationsScreen(currentUserId: currentUserId!); // currentUserId'yı ConversationsScreen'e geçir
            } else {
              return const Text('No user data');
            }
          },
        ),
      },
    );
  }

  // Asenkron metot
  Future<String?> _getCurrentUserId() async {
    final SecureStorage _secureStorage = SecureStorage();
    return await _secureStorage.getUserId(); // SecureStorage'den userId'yi al
  }
}

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({Key? key}) : super(key: key);

  @override
  _AuthCheckScreenState createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  final SecureStorage _secureStorage = SecureStorage();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await _secureStorage.getAccessToken();
    
    setState(() {
      _isLoading = false;
    });
    
    if (token != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.health_and_safety,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'HealthHarmony',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
