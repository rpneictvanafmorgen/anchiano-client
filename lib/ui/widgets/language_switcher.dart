import 'package:flutter/material.dart';

class LanguageSwitcher extends StatelessWidget {
  final void Function(Locale locale) onChangeLanguage;

  const LanguageSwitcher({
    super.key,
    required this.onChangeLanguage,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      onSelected: (value) {
        if (value == 'nl') {
          onChangeLanguage(const Locale('nl'));
        } else if (value == 'en') {
          onChangeLanguage(const Locale('en'));
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'nl',
          child: Text('🇳🇱 Nederlands'),
        ),
        PopupMenuItem(
          value: 'en',
          child: Text('🇬🇧 English'),
        ),
      ],
    );
  }
}
