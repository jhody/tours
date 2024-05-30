import 'package:flutter_gen/gen_l10n/app_localizations.dart';
//import 'package:flutter_localizations/flutter_localizations.dart';
//import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:tours/common_libs.dart';
//import 'package:tours/logic/artifact_api_logic.dart';
//import 'package:tours/logic/artifact_api_service.dart';
//import 'package:tours/logic/collectibles_logic.dart';
//import 'package:tours/logic/native_widget_service.dart';
import 'package:tours/logic/locale_logic.dart';
/*import 'package:tours/logic/timeline_logic.dart';
import 'package:tours/logic/unsplash_logic.dart';
import 'package:tours/logic/wonders_logic.dart';
import 'package:tours/ui/common/app_shortcuts.dart';*/

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tours',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(body: Center(child: Text("sdsdsdsd"))),
    );
  }
}

/// Agregue azúcar de sintaxis para acceder rápidamente a los principales controladores "lógicos" de la aplicación
/// Deliberadamente no creamos accesos directos para servicios, para desalentar su uso directamente en la capa de vista/widget..
AppLogic get appLogic => GetIt.I.get<AppLogic>();
//WondersLogic get wondersLogic => GetIt.I.get<WondersLogic>();
//TimelineLogic get timelineLogic => GetIt.I.get<TimelineLogic>();
SettingsLogic get settingsLogic => GetIt.I.get<SettingsLogic>();
/*UnsplashLogic get unsplashLogic => GetIt.I.get<UnsplashLogic>();
ArtifactAPILogic get artifactLogic => GetIt.I.get<ArtifactAPILogic>();
CollectiblesLogic get collectiblesLogic => GetIt.I.get<CollectiblesLogic>();*/
LocaleLogic get localeLogic => GetIt.I.get<LocaleLogic>();

/// Ayudantes globales para la legibilidad
AppLocalizations get $strings => localeLogic.strings;
AppStyle get $styles => WondersAppScaffold.style;
