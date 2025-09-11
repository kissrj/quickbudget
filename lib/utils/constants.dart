// App constants and configuration
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'constants.g.dart';

class AppConstants {
  // Colors
  static const Color primaryColor = Color(0xFF00509E);
  static const Color positiveColor = Color(0xFF007A33); // Green for income
  static const Color expenseColor = Color(0xFF00509E); // Blue for expenses
  static const Color alertColor = Color(0xFFD62828);
  static const Color lightGray = Color(0xFFF5F7FA);
  static const Color textColor = Color(0xFF1A1A1A);
  static const Color whiteColor = Color(0xFFFFFFFF);

  // App settings
  static const appName = 'QuickBudget';
  static const freePlanLimit = 10;

  // Premium price
  static const premiumPrice = '4.99';
  static const premiumCurrency = 'USD';
}

// Transaction categories
@HiveType(typeId: 1)
enum TransactionType {
  @HiveField(0)
  income,
  @HiveField(1)
  expense,
}

@HiveType(typeId: 2)
enum TransactionCategory {
  // Expense categories
  @HiveField(0)
  groceries, // Mercado
  @HiveField(1)
  transportation, // Transporte
  @HiveField(2)
  housing, // Moradia
  @HiveField(3)
  entertainment, // Lazer
  @HiveField(4)
  health, // Saúde
  @HiveField(5)
  food, // Alimentação
  @HiveField(6)
  utilities, // Utilidades
  @HiveField(7)
  shopping, // Compras
  @HiveField(8)
  education, // Educação
  @HiveField(9)
  personal, // Pessoal
  // Income categories
  @HiveField(10)
  salary, // Salário
  @HiveField(11)
  freelance, // Freelance
  @HiveField(12)
  investments, // Investimentos
  @HiveField(13)
  rental, // Aluguel
  @HiveField(14)
  business, // Negócios
  @HiveField(15)
  gifts, // Presentes
  @HiveField(16)
  other, // Outros
}

// Language support
enum AppLanguage { portuguese, english }

// Currency support
enum AppCurrency { brl, usd, eur }
