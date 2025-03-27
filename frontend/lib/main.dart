import 'package:book_swap/providers/book_provider.dart';
import 'package:book_swap/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:book_swap/utils/routes.dart';
import 'package:book_swap/pages/add_books.dart';
import 'package:book_swap/pages/added_books.dart';
import 'package:book_swap/pages/home_page.dart';
import 'package:book_swap/pages/login_page.dart';
import 'package:book_swap/pages/profile_section.dart';
import 'package:book_swap/pages/search_section.dart';
import 'package:book_swap/pages/signup_page.dart';
import 'package:book_swap/pages/welcome_page.dart';
import 'package:provider/provider.dart';
// import 'services/api_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BookProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light, // dark mode chahiyo vane
      theme: AppTheme.lightTheme,
      initialRoute: MyRoutes.loginRoute, // Set initial route
      routes: {
        MyRoutes.welcomeRoute: (context) => const WelcomePage(),
        MyRoutes.signupRoute: (context) => const SignupPage(),
        MyRoutes.homeRoute: (context) => const MyHomePage(),
        MyRoutes.loginRoute: (context) => const LoginPage(),
        MyRoutes.addBooksRoute: (context) => const AddBooksSection(),
        MyRoutes.profileRoute: (context) => const ProfileSection(),
        MyRoutes.searchRoute: (context) => const SearchSection(),
        MyRoutes.booksRoute: (context) => const BooksSection(),
      },
    );
  }
}
