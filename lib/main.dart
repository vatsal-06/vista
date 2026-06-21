import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'utils/app_routes.dart';
import 'views/screens/splash_screen.dart';
import 'views/screens/home_screen.dart';
import 'views/screens/active_walk_screen.dart';
import 'views/screens/speak_mode_screen.dart';
import 'views/screens/sos_screen.dart';
import 'views/screens/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation — this is a mobile walking app
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const SaathChaloApp());
}

class SaathChaloApp extends StatelessWidget {
  const SaathChaloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Saath Chalo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.activeWalk: (context) => const ActiveWalkScreen(),
        AppRoutes.speakMode: (context) => const SpeakModeScreen(),
        AppRoutes.sos: (context) => const SOSScreen(),
        AppRoutes.settings: (context) => const SettingsScreen(),
      },
      // Page transition — clean slide animation
      onGenerateRoute: (settings) {
        final routes = <String, WidgetBuilder>{
          AppRoutes.splash: (_) => const SplashScreen(),
          AppRoutes.home: (_) => const HomeScreen(),
          AppRoutes.activeWalk: (_) => const ActiveWalkScreen(),
          AppRoutes.speakMode: (_) => const SpeakModeScreen(),
          AppRoutes.sos: (_) => const SOSScreen(),
          AppRoutes.settings: (_) => const SettingsScreen(),
        };
        final builder = routes[settings.name];
        if (builder != null) {
          return PageRouteBuilder(
            settings: settings,
            pageBuilder: (context, _, __) => builder(context),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 280),
          );
        }
        return null;
      },
    );
  }
}
