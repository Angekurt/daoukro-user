import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/cache_manager.dart';
import 'core/services/notification_service.dart';
import 'core/services/settings_service.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/widgets/offline_banner.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheManager.init();

  // Firebase (Crashlytics, FCM) n'est configuré que pour Android/iOS —
  // pas de firebase_options.dart pour le web, et Crashlytics n'existe
  // pas sur cette plateforme.
  if (!kIsWeb) {
    await Firebase.initializeApp();

    // Crashlytics — capturer toutes les erreurs Flutter en production
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    await NotificationService.instance.init();
  }

  await SettingsService.instance.init();

  final container = ProviderContainer();
  await container.read(themeModeProvider.notifier).init();
  // Restaure la session citoyenne (token Sanctum) si un compte est déjà
  // connecté, avant que le premier écran ne fasse ses appels API.
  await container.read(authProvider.future);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'Daoukro Digital',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: appRouter,
      builder: (context, child) => OfflineBanner(child: child ?? const SizedBox.shrink()),
    );
  }
}
