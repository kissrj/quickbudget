import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. See `example/lib/main.dart` for examples.
class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A value for supportedLocales
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// No description provided for @appName.
  ///
  /// In pt, this message translates to:
  /// **'Controle Financeiro'**
  String get appName {
    return _localizedValues[localeName]?['appName'] ?? 'Controle Financeiro';
  }

  /// No description provided for @home.
  ///
  /// In pt, this message translates to:
  /// **'Home'**
  String get home {
    return _localizedValues[localeName]?['home'] ?? 'Home';
  }

  /// No description provided for @history.
  ///
  /// In pt, this message translates to:
  /// **'Histórico'**
  String get history {
    return _localizedValues[localeName]?['history'] ?? 'Histórico';
  }

  /// No description provided for @settings.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get settings {
    return _localizedValues[localeName]?['settings'] ?? 'Configurações';
  }

  /// No description provided for @addTransaction.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar Transação'**
  String get addTransaction {
    return _localizedValues[localeName]?['addTransaction'] ??
        'Adicionar Transação';
  }

  /// No description provided for @income.
  ///
  /// In pt, this message translates to:
  /// **'Receita'**
  String get income {
    return _localizedValues[localeName]?['income'] ?? 'Receita';
  }

  /// No description provided for @expense.
  ///
  /// In pt, this message translates to:
  /// **'Despesa'**
  String get expense {
    return _localizedValues[localeName]?['expense'] ?? 'Despesa';
  }

  /// No description provided for @amount.
  ///
  /// In pt, this message translates to:
  /// **'Valor'**
  String get amount {
    return _localizedValues[localeName]?['amount'] ?? 'Valor';
  }

  /// No description provided for @category.
  ///
  /// In pt, this message translates to:
  /// **'Categoria'**
  String get category {
    return _localizedValues[localeName]?['category'] ?? 'Categoria';
  }

  /// No description provided for @description.
  ///
  /// In pt, this message translates to:
  /// **'Descrição'**
  String get description {
    return _localizedValues[localeName]?['description'] ?? 'Descrição';
  }

  /// No description provided for @save.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get save {
    return _localizedValues[localeName]?['save'] ?? 'Salvar';
  }

  /// No description provided for @cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel {
    return _localizedValues[localeName]?['cancel'] ?? 'Cancelar';
  }

  /// No description provided for @delete.
  ///
  /// In pt, this message translates to:
  /// **'Excluir'**
  String get delete {
    return _localizedValues[localeName]?['delete'] ?? 'Excluir';
  }

  /// No description provided for @edit.
  ///
  /// In pt, this message translates to:
  /// **'Editar'**
  String get edit {
    return _localizedValues[localeName]?['edit'] ?? 'Editar';
  }

  /// No description provided for @language.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get language {
    return _localizedValues[localeName]?['language'] ?? 'Idioma';
  }

  /// No description provided for @currency.
  ///
  /// In pt, this message translates to:
  /// **'Moeda'**
  String get currency {
    return _localizedValues[localeName]?['currency'] ?? 'Moeda';
  }

  /// No description provided for @theme.
  ///
  /// In pt, this message translates to:
  /// **'Tema'**
  String get theme {
    return _localizedValues[localeName]?['theme'] ?? 'Tema';
  }

  /// No description provided for @portuguese.
  ///
  /// In pt, this message translates to:
  /// **'Português'**
  String get portuguese {
    return _localizedValues[localeName]?['portuguese'] ?? 'Português';
  }

  /// No description provided for @english.
  ///
  /// In pt, this message translates to:
  /// **'English'**
  String get english {
    return _localizedValues[localeName]?['english'] ?? 'English';
  }

  /// No description provided for @tapToSpeak.
  ///
  /// In pt, this message translates to:
  /// **'Toque para falar'**
  String get tapToSpeak {
    return _localizedValues[localeName]?['tapToSpeak'] ?? 'Toque para falar';
  }

  /// No description provided for @currentBalance.
  ///
  /// In pt, this message translates to:
  /// **'Saldo Atual'**
  String get currentBalance {
    return _localizedValues[localeName]?['currentBalance'] ?? 'Saldo Atual';
  }

  /// No description provided for @freePlan.
  ///
  /// In pt, this message translates to:
  /// **'Plano Free'**
  String get freePlan {
    return _localizedValues[localeName]?['freePlan'] ?? 'Plano Free';
  }

  /// No description provided for @premiumPlan.
  ///
  /// In pt, this message translates to:
  /// **'Premium Ativo'**
  String get premiumPlan {
    return _localizedValues[localeName]?['premiumPlan'] ?? 'Premium Ativo';
  }

  /// No description provided for @plan.
  ///
  /// In pt, this message translates to:
  /// **'Plano'**
  String get plan {
    return _localizedValues[localeName]?['plan'] ?? 'Plano';
  }

  /// No description provided for @preferences.
  ///
  /// In pt, this message translates to:
  /// **'Preferências'**
  String get preferences {
    return _localizedValues[localeName]?['preferences'] ?? 'Preferências';
  }

  /// No description provided for @voiceInput.
  ///
  /// In pt, this message translates to:
  /// **'Entrada por Voz'**
  String get voiceInput {
    return _localizedValues[localeName]?['voiceInput'] ?? 'Entrada por Voz';
  }

  /// No description provided for @data.
  ///
  /// In pt, this message translates to:
  /// **'Dados'**
  String get data {
    return _localizedValues[localeName]?['data'] ?? 'Dados';
  }

  /// No description provided for @about.
  ///
  /// In pt, this message translates to:
  /// **'Sobre'**
  String get about {
    return _localizedValues[localeName]?['about'] ?? 'Sobre';
  }

  /// No description provided for @exportData.
  ///
  /// In pt, this message translates to:
  /// **'Exportar Dados'**
  String get exportData {
    return _localizedValues[localeName]?['exportData'] ?? 'Exportar Dados';
  }

  /// No description provided for @importData.
  ///
  /// In pt, this message translates to:
  /// **'Importar Dados'**
  String get importData {
    return _localizedValues[localeName]?['importData'] ?? 'Importar Dados';
  }

  /// No description provided for @clearAllData.
  ///
  /// In pt, this message translates to:
  /// **'Limpar Todos os Dados'**
  String get clearAllData {
    return _localizedValues[localeName]?['clearAllData'] ??
        'Limpar Todos os Dados';
  }

  /// No description provided for @voiceTutorial.
  ///
  /// In pt, this message translates to:
  /// **'Tutorial de Voz'**
  String get voiceTutorial {
    return _localizedValues[localeName]?['voiceTutorial'] ?? 'Tutorial de Voz';
  }

  /// No description provided for @testRecognition.
  ///
  /// In pt, this message translates to:
  /// **'Testar Reconhecimento'**
  String get testRecognition {
    return _localizedValues[localeName]?['testRecognition'] ??
        'Testar Reconhecimento';
  }

  /// No description provided for @help.
  ///
  /// In pt, this message translates to:
  /// **'Ajuda'**
  String get help {
    return _localizedValues[localeName]?['help'] ?? 'Ajuda';
  }

  /// No description provided for @privacy.
  ///
  /// In pt, this message translates to:
  /// **'Privacidade'**
  String get privacy {
    return _localizedValues[localeName]?['privacy'] ?? 'Privacidade';
  }

  /// No description provided for @terms.
  ///
  /// In pt, this message translates to:
  /// **'Termos de Uso'**
  String get terms {
    return _localizedValues[localeName]?['terms'] ?? 'Termos de Uso';
  }

  /// No description provided for @version.
  ///
  /// In pt, this message translates to:
  /// **'Versão'**
  String get version {
    return _localizedValues[localeName]?['version'] ?? 'Versão';
  }

  /// No description provided for @upgrade.
  ///
  /// In pt, this message translates to:
  /// **'Upgrade'**
  String get upgrade {
    return _localizedValues[localeName]?['upgrade'] ?? 'Upgrade';
  }

  /// No description provided for @close.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get close {
    return _localizedValues[localeName]?['close'] ?? 'Fechar';
  }

  /// No description provided for @test.
  ///
  /// In pt, this message translates to:
  /// **'Testar'**
  String get test {
    return _localizedValues[localeName]?['test'] ?? 'Testar';
  }

  /// No description provided for @understood.
  ///
  /// In pt, this message translates to:
  /// **'Entendi'**
  String get understood {
    return _localizedValues[localeName]?['understood'] ?? 'Entendi';
  }

  /// No description provided for @clear.
  ///
  /// In pt, this message translates to:
  /// **'Limpar'**
  String get clear {
    return _localizedValues[localeName]?['clear'] ?? 'Limpar';
  }

  /// No description provided for @light.
  ///
  /// In pt, this message translates to:
  /// **'Claro'**
  String get light {
    return _localizedValues[localeName]?['light'] ?? 'Claro';
  }

  /// No description provided for @dark.
  ///
  /// In pt, this message translates to:
  /// **'Escuro'**
  String get dark {
    return _localizedValues[localeName]?['dark'] ?? 'Escuro';
  }

  /// No description provided for @auto.
  ///
  /// In pt, this message translates to:
  /// **'Automático'**
  String get auto {
    return _localizedValues[localeName]?['auto'] ?? 'Automático';
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

final _localizedValues = <String, Map<String, String>>{
  'en': {
    'appName': 'Financial Control',
    'home': 'Home',
    'history': 'History',
    'settings': 'Settings',
    'addTransaction': 'Add Transaction',
    'income': 'Income',
    'expense': 'Expense',
    'amount': 'Amount',
    'category': 'Category',
    'description': 'Description',
    'save': 'Save',
    'cancel': 'Cancel',
    'delete': 'Delete',
    'edit': 'Edit',
    'language': 'Language',
    'currency': 'Currency',
    'theme': 'Theme',
    'portuguese': 'Portuguese',
    'english': 'English',
    'tapToSpeak': 'Tap to speak',
    'currentBalance': 'Current Balance',
    'freePlan': 'Free Plan',
    'premiumPlan': 'Premium Active',
    'plan': 'Plan',
    'preferences': 'Preferences',
    'voiceInput': 'Voice Input',
    'data': 'Data',
    'about': 'About',
    'exportData': 'Export Data',
    'importData': 'Import Data',
    'clearAllData': 'Clear All Data',
    'voiceTutorial': 'Voice Tutorial',
    'testRecognition': 'Test Recognition',
    'help': 'Help',
    'privacy': 'Privacy',
    'terms': 'Terms of Use',
    'version': 'Version',
    'upgrade': 'Upgrade',
    'close': 'Close',
    'test': 'Test',
    'understood': 'Understood',
    'clear': 'Clear',
    'light': 'Light',
    'dark': 'Dark',
    'auto': 'Auto',
  },
  'pt': {
    'appName': 'Controle Financeiro',
    'home': 'Home',
    'history': 'Histórico',
    'settings': 'Configurações',
    'addTransaction': 'Adicionar Transação',
    'income': 'Receita',
    'expense': 'Despesa',
    'amount': 'Valor',
    'category': 'Categoria',
    'description': 'Descrição',
    'save': 'Salvar',
    'cancel': 'Cancelar',
    'delete': 'Excluir',
    'edit': 'Editar',
    'language': 'Idioma',
    'currency': 'Moeda',
    'theme': 'Tema',
    'portuguese': 'Português',
    'english': 'English',
    'tapToSpeak': 'Toque para falar',
    'currentBalance': 'Saldo Atual',
    'freePlan': 'Plano Free',
    'premiumPlan': 'Premium Ativo',
    'plan': 'Plano',
    'preferences': 'Preferências',
    'voiceInput': 'Entrada por Voz',
    'data': 'Dados',
    'about': 'Sobre',
    'exportData': 'Exportar Dados',
    'importData': 'Importar Dados',
    'clearAllData': 'Limpar Todos os Dados',
    'voiceTutorial': 'Tutorial de Voz',
    'testRecognition': 'Testar Reconhecimento',
    'help': 'Ajuda',
    'privacy': 'Privacidade',
    'terms': 'Termos de Uso',
    'version': 'Versão',
    'upgrade': 'Upgrade',
    'close': 'Fechar',
    'test': 'Testar',
    'understood': 'Entendi',
    'clear': 'Limpar',
    'light': 'Claro',
    'dark': 'Escuro',
    'auto': 'Automático',
  },
};
