import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/theme_service.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // Chargé de façon asynchrone après le premier rendu (voir _init ci-dessous
    // appelé depuis main.dart) ; ThemeMode.system tant que la préférence
    // enregistrée n'a pas encore été lue.
    return ThemeMode.system;
  }

  Future<void> init() async {
    state = await ThemeService.getSavedMode();
  }

  Future<void> changer(ThemeMode mode) async {
    state = mode;
    await ThemeService.saveMode(mode);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
