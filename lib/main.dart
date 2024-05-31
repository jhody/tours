import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:tours/common_libs.dart';
import 'package:tours/logic/artifact_api_logic.dart';
import 'package:tours/logic/artifact_api_service.dart';
import 'package:tours/logic/collectibles_logic.dart';
import 'package:tours/logic/native_widget_service.dart';
import 'package:tours/logic/locale_logic.dart';
import 'package:tours/logic/timeline_logic.dart';
import 'package:tours/logic/unsplash_logic.dart';
import 'package:tours/logic/wonders_logic.dart';
import 'package:tours/ui/common/app_shortcuts.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // Mantenga activa la pantalla de presentación nativa hasta que la aplicación termine de iniciarse
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  GoRouter.optionURLReflectsImperativeAPIs = true;

  // Start app
  registerSingletons();

  runApp(ToursApp());
  await appLogic.bootstrap();
  // Remove splash screen when bootstrap is complete
  FlutterNativeSplash.remove();
}

/// Crea una aplicación usando el constructor [MaterialApp.router] y el `appRouter` global, una instancia de [GoRouter].
class ToursApp extends StatelessWidget with GetItMixin {
  ToursApp({super.key});
  @override
  Widget build(BuildContext context) {
    final locale = watchX((SettingsLogic s) => s.currentLocale);
    return MaterialApp.router(
      routeInformationProvider: appRouter.routeInformationProvider,
      routeInformationParser: appRouter.routeInformationParser,
      locale: locale == null ? null : Locale(locale),
      debugShowCheckedModeBanner: false,
      routerDelegate: appRouter.routerDelegate,
      shortcuts: AppShortcuts.defaults,
      theme: ThemeData(
          fontFamily: $styles.text.body.fontFamily, useMaterial3: true),
      color: $styles.colors.black,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}

/// Crear singletons (logic and services) que se puede compartir en toda la aplicación.
void registerSingletons() {
  // Top level app controller
  GetIt.I.registerLazySingleton<AppLogic>(() => AppLogic());
  // Wonders
  GetIt.I.registerLazySingleton<WondersLogic>(() => WondersLogic());
  // Timeline / Events
  GetIt.I.registerLazySingleton<TimelineLogic>(() => TimelineLogic());
  // Search
  GetIt.I.registerLazySingleton<ArtifactAPILogic>(() => ArtifactAPILogic());
  GetIt.I.registerLazySingleton<ArtifactAPIService>(() => ArtifactAPIService());
  // Settings
  GetIt.I.registerLazySingleton<SettingsLogic>(() => SettingsLogic());
  // Unsplash
  GetIt.I.registerLazySingleton<UnsplashLogic>(() => UnsplashLogic());
  // Collectibles
  GetIt.I.registerLazySingleton<CollectiblesLogic>(() => CollectiblesLogic());
  // Localizations
  GetIt.I.registerLazySingleton<LocaleLogic>(() => LocaleLogic());
  // Home Widget Service
  GetIt.I.registerLazySingleton<NativeWidgetService>(() => NativeWidgetService());
}

/// Agregue azúcar de sintaxis para acceder rápidamente a los principales controladores "lógicos" de la aplicación
/// Deliberadamente no creamos accesos directos para servicios, para desalentar su uso directamente en la capa de vista/widget..
AppLogic get appLogic => GetIt.I.get<AppLogic>();
WondersLogic get wondersLogic => GetIt.I.get<WondersLogic>();
TimelineLogic get timelineLogic => GetIt.I.get<TimelineLogic>();
SettingsLogic get settingsLogic => GetIt.I.get<SettingsLogic>();
UnsplashLogic get unsplashLogic => GetIt.I.get<UnsplashLogic>();
ArtifactAPILogic get artifactLogic => GetIt.I.get<ArtifactAPILogic>();
CollectiblesLogic get collectiblesLogic => GetIt.I.get<CollectiblesLogic>();
LocaleLogic get localeLogic => GetIt.I.get<LocaleLogic>();

/// Ayudantes globales para la legibilidad
AppLocalizations get $strings => localeLogic.strings;
AppStyle get $styles => WondersAppScaffold.style;
