import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Enum para os tipos de tema
enum AppTheme {
  auto, // Verde escuro (padrão)
  dark, // Tema escuro padrão
  light, // Tema claro padrão
}

// Provider para o tema atual
final themeProvider = StateNotifierProvider<ThemeNotifier, AppTheme>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<AppTheme> {
  ThemeNotifier() : super(AppTheme.auto) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('theme') ?? 'auto';
    state = _stringToTheme(themeString);
  }

  Future<void> setTheme(AppTheme theme) async {
    state = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', _themeToString(theme));
  }

  AppTheme _stringToTheme(String themeString) {
    switch (themeString) {
      case 'light':
        return AppTheme.light;
      case 'dark':
        return AppTheme.dark;
      case 'auto':
      default:
        return AppTheme.auto;
    }
  }

  String _themeToString(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return 'light';
      case AppTheme.dark:
        return 'dark';
      case AppTheme.auto:
      default:
        return 'auto';
    }
  }

  // Método para obter o ThemeData baseado no tema selecionado
  ThemeData getThemeData() {
    switch (state) {
      case AppTheme.light:
        return _getLightTheme();
      case AppTheme.dark:
        return _getDarkTheme();
      case AppTheme.auto:
      default:
        return _getAutoTheme(); // Verde escuro personalizado
    }
  }

  ThemeData _getAutoTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF122118), // Verde escuro
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF122118), // Verde escuro
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(
            0xFFE8F5E8,
          ), // Verde claro igual aos cards
          foregroundColor: Colors.black, // Preto para melhor legibilidade
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1B3124),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF264532)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF264532)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF38E07B)),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black), // Preto para cards verdes
        bodyMedium: TextStyle(
          color: Colors.black87,
        ), // Preto escuro para cards verdes
        titleMedium: TextStyle(color: Colors.black), // Preto para títulos
        titleLarge: TextStyle(
          color: Colors.black,
        ), // Preto para títulos grandes
      ),
      iconTheme: const IconThemeData(
        color: Colors.black,
      ), // Ícones pretos para cards verdes
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
      ),
    );
  }

  ThemeData _getDarkTheme() {
    return ThemeData.dark(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: Colors.grey[900],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }

  ThemeData _getLightTheme() {
    return ThemeData.light(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
    );
  }
}
