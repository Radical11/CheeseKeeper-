import 'package:flutter/material.dart';
import 'features/login/login_page.dart';
import 'features/setup/setup_page.dart';
import 'features/navigation/main_nav_shell.dart';

class CheeseKeeperApp extends StatelessWidget {
  const CheeseKeeperApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CheeseKeeper',
      theme: _buildProfessionalTheme(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginPage(),
        '/setup': (_) => const SetupPage(),
        '/main': (_) => const MainNavShell(),
      },
    );
  }

  ThemeData _buildProfessionalTheme() {
    // Professional color scheme with subtle cheese-inspired accents
    const primaryGold = Color(0xFFDAA520); // Elegant gold accent
    const darkBackground = Color(0xFF0F1419); // Deeper, more sophisticated
    const cardBackground = Color(0xFF1C2128); // Warmer card background
    const surfaceVariant = Color(0xFF252B35); // Elevated surfaces
    const textPrimary = Color(0xFFF5F5DC); // Warm cream white
    const textSecondary = Color(0xFFA5A5A5); // Refined gray
    const accentOrange = Color(0xFFCD853F); // Complementary warm accent
    const borderColor = Color(0xFF2A2F38); // Subtle borders
    
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: MaterialColor(primaryGold.value, {
        50: const Color(0xFFFFF8DC),
        100: const Color(0xFFFFF0B8),
        200: const Color(0xFFFFE894),
        300: const Color(0xFFFFE070),
        400: const Color(0xFFFFD84C),
        500: primaryGold,
        600: const Color(0xFFC4941C),
        700: const Color(0xFF9F7A16),
        800: const Color(0xFF7A6011),
        900: const Color(0xFF55460C),
      }),
      colorScheme: ColorScheme.dark(
        primary: primaryGold,
        primaryContainer: primaryGold.withOpacity(0.3),
        secondary: accentOrange,
        secondaryContainer: accentOrange.withOpacity(0.3),
        surface: cardBackground,
        surfaceContainerHighest: surfaceVariant,
        outline: borderColor,
        error: const Color(0xFFCF6679),
        onPrimary: const Color(0xFF1A1A1A),
        onPrimaryContainer: primaryGold,
        onSecondary: Colors.white,
        onSecondaryContainer: accentOrange,
        onSurface: textPrimary,
        onSurfaceVariant: textSecondary,
        onError: Colors.white,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: cardBackground.withOpacity(0.8),
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(
          color: primaryGold,
          size: 24,
        ),
        actionsIconTheme: const IconThemeData(
          color: primaryGold,
          size: 22,
        ),
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGold,
          foregroundColor: const Color(0xFF1A1A1A),
          shadowColor: primaryGold.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          elevation: 4,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ).copyWith(
          overlayColor: WidgetStatePropertyAll(
            Colors.black.withOpacity(0.1),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryGold,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor.withOpacity(0.7), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryGold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFCF6679), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFCF6679), width: 2),
        ),
        labelStyle: TextStyle(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: textSecondary.withOpacity(0.7),
          fontSize: 14,
        ),
        floatingLabelStyle: const TextStyle(
          color: primaryGold,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        shadowColor: Colors.black.withOpacity(0.3),
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: borderColor.withOpacity(0.5),
            width: 0.5,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardBackground,
        selectedItemColor: primaryGold,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textSecondary.withOpacity(0.8),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
          fontSize: 14,
        ),
      ),
    );
  }
}
