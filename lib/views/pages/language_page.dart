import 'package:flutter/material.dart';
import 'package:safewalk/data/language_notifier.dart';
import 'package:safewalk/data/localizations.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FC),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 15),
            // Header
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Volver',
                ),
                Expanded(
                  child: Center(
                    child: ValueListenableBuilder<Locale>(
                      valueListenable: localeNotifier,
                      builder: (context, locale, child) {
                        final texts = AppLocalizations.of(locale.languageCode);
                        return Text(
                          texts.language,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 40),
            // Imagen
            Center(
              child: Image.asset(
                'assets/images/34O.png',
                height: 200,
                width: 200,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 60),
            // Lista de idiomas
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ValueListenableBuilder<Locale>(
                  valueListenable: localeNotifier,
                  builder: (context, locale, child) {
                    final currentLang = locale.languageCode;
                    final texts = AppLocalizations.of(currentLang);

                    return ListView(
                      children: [
                        // Español
                        _LanguageOption(
                          languageName: texts.spanish,
                          nativeName: 'Español',
                          languageCode: 'es',
                          flag: '🇪🇸',
                          isSelected: currentLang == 'es',
                          onTap: () async {
                            await LanguageService.saveLanguage('es');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Idioma cambiado a Español'),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        // Inglés
                        _LanguageOption(
                          languageName: texts.english,
                          nativeName: 'English',
                          languageCode: 'en',
                          flag: '🇺🇸',
                          isSelected: currentLang == 'en',
                          onTap: () async {
                            await LanguageService.saveLanguage('en');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Language changed to English'),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        // Chino
                        _LanguageOption(
                          languageName: texts.chinese,
                          nativeName: '中文',
                          languageCode: 'zh',
                          flag: '🇨🇳',
                          isSelected: currentLang == 'zh',
                          onTap: () async {
                            await LanguageService.saveLanguage('zh');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('语言已更改为中文'),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        // Alemán
                        _LanguageOption(
                          languageName: texts.german,
                          nativeName: 'Deutsch',
                          languageCode: 'de',
                          flag: '🇩🇪',
                          isSelected: currentLang == 'de',
                          onTap: () async {
                            await LanguageService.saveLanguage('de');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Sprache auf Deutsch geändert'),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        // Japonés
                        _LanguageOption(
                          languageName: texts.japanese,
                          nativeName: '日本語',
                          languageCode: 'ja',
                          flag: '🇯🇵',
                          isSelected: currentLang == 'ja',
                          onTap: () async {
                            await LanguageService.saveLanguage('ja');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('言語を日本語に変更しました'),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        // Coreano
                        _LanguageOption(
                          languageName: texts.korean,
                          nativeName: '한국어',
                          languageCode: 'ko',
                          flag: '🇰🇷',
                          isSelected: currentLang == 'ko',
                          onTap: () async {
                            await LanguageService.saveLanguage('ko');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('언어가 한국어로 변경되었습니다'),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        // Tailandés
                        _LanguageOption(
                          languageName: texts.thai,
                          nativeName: 'ภาษาไทย',
                          languageCode: 'th',
                          flag: '🇹🇭',
                          isSelected: currentLang == 'th',
                          onTap: () async {
                            await LanguageService.saveLanguage('th');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('เปลี่ยนภาษาเป็นภาษาไทยแล้ว'),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        // Portugués
                        _LanguageOption(
                          languageName: texts.portuguese,
                          nativeName: 'Português',
                          languageCode: 'pt',
                          flag: '🇵🇹',
                          isSelected: currentLang == 'pt',
                          onTap: () async {
                            await LanguageService.saveLanguage('pt');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Idioma alterado para Português',
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        // Francés
                        _LanguageOption(
                          languageName: texts.french,
                          nativeName: 'Français',
                          languageCode: 'fr',
                          flag: '🇫🇷',
                          isSelected: currentLang == 'fr',
                          onTap: () async {
                            await LanguageService.saveLanguage('fr');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Langue changée en Français'),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String languageName;
  final String nativeName;
  final String languageCode;
  final String flag;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.languageName,
    required this.nativeName,
    required this.languageCode,
    required this.flag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.teal : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.teal,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            // Bandera
            Text(flag, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            // Nombre del idioma
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nativeName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.teal : Colors.black87,
                    ),
                  ),
                  if (languageName != nativeName)
                    Text(
                      languageName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
            // Indicador de selección
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.teal, size: 28)
            else
              Icon(
                Icons.circle_outlined,
                color: Colors.grey.shade400,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
