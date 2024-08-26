import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'pages/leaderboard_screen.dart';
import 'utils/light_theme.dart';
import 'utils/token_service.dart';
import 'utils/custom_http_client.dart';
import 'pages/login_screen.dart';
import 'pages/home_screen.dart';
import 'pages/med_profile.dart';
import 'pages/create_medprofile.dart';
import 'pages/post_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  // Initialize TokenService and retrieve the access token
  final TokenService tokenService = TokenService();
  final String? accessToken = await tokenService.getAccessToken();

  // Create the CustomHttpClient
  final httpClient = CustomHttpClient(client: http.Client(), tokenService: tokenService);
  print(accessToken != null);
  runApp(
    MultiProvider(
      providers: [
        Provider<TokenService>(create: (_) => tokenService),
        Provider<CustomHttpClient>(create: (_) => httpClient),
      ],
      child: MyApp(startScreen: accessToken != null ? HomeScreen() : LoginScreen()),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Widget startScreen;

  MyApp({required this.startScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OurHealth',
      theme: lightTheme,
      themeMode: ThemeMode.system,
      home: startScreen,
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/postDetail': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is int) {
            return PostDetailScreen(postId: args);
          } else {
            return const Scaffold(
              body: Center(
                child: Text('Invalid post ID'),
              ),
            );
          }
        },
        '/viewMedProfile': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is int) {
            return MedProfileScreen(userId: args);
          } else {
            return const Scaffold(
              body: Center(
                child: Text('Invalid user ID'),
              ),
            );
          }
        },
        '/createMedProfile': (context) => CreateEditMedProfileScreen(),
        '/leaderboard': (context) => LeaderboardScreen(),
      },
    );
  }
}
