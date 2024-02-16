import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rbh_task_management/src/core/session_manager.dart';
import 'package:rbh_task_management/src/presentation/pin_verify/pin_verify_page.dart';

import '../main.dart';
import 'presentation/task_list/task_list_page.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => getIt<SessionManager>().startIdleTimer(),
      onPointerMove: (_) => getIt<SessionManager>().startIdleTimer(),
      child: MaterialApp(
        restorationScopeId: 'app',
        supportedLocales: const [Locale('en')],
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: Colors.deepPurpleAccent,
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              textStyle: const TextStyle(fontSize: 28),
              side: const BorderSide(
                color: Colors.deepPurple,
              ),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              textStyle: const TextStyle(
                fontSize: 18,
              ),
              backgroundColor: Colors.deepPurpleAccent,
              foregroundColor: Colors.white,
            ),
          ),
          fontFamily: GoogleFonts.montserrat().fontFamily,
          primarySwatch: Colors.deepPurple,
          tabBarTheme: TabBarTheme(
            labelStyle: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            unselectedLabelStyle: const TextStyle(
              color: Colors.deepPurpleAccent,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            dividerHeight: 0,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Colors.deepPurpleAccent]),
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.5,
            ),
            displayMedium: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.5,
            ),
            displaySmall: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            bodyLarge: TextStyle(fontWeight: FontWeight.w600),
            titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            labelLarge: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
        darkTheme: ThemeData.dark(),
        initialRoute: PinVerifyPage.routeName,
        onGenerateRoute: (RouteSettings routeSettings) {
          return MaterialPageRoute<void>(
            settings: routeSettings,
            builder: (BuildContext context) {
              switch (routeSettings.name) {
                case TaskListPage.routeName:
                  return const TaskListPage();
                case PinVerifyPage.routeName:
                  return const PinVerifyPage();
                default:
                  return Scaffold(
                    appBar: AppBar(
                      title: const Text("Error"),
                    ),
                    body: const Center(child: Text("Route not found")),
                  );
              }
            },
          );
        },
      ),
    );
  }
}
