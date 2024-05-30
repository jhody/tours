import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:tours/common_libs.dart';
import 'package:tours/ui/common/modals//fullscreen_video_viewer.dart';
/*import 'package:tours/ui/common/modals/fullscreen_maps_viewer.dart';
import 'package:tours/ui/screens/artifact/artifact_details/artifact_details_screen.dart';
import 'package:tours/ui/screens/artifact/artifact_search/artifact_search_screen.dart';
import 'package:tours/ui/screens/collection/collection_screen.dart';
import 'package:tours/ui/screens/home/wonders_home_screen.dart';
import 'package:tours/ui/screens/intro/intro_screen.dart';
import 'package:tours/ui/screens/page_not_found/page_not_found.dart';
import 'package:tours/ui/screens/timeline/timeline_screen.dart';
import 'package:tours/ui/screens/wonder_details/wonders_details_screen.dart';*/

class ScreenPaths {
  static String splash = '/';
  static String intro = '/welcome';
  static String home = '/home';
  static String settings = '/settings';
}

final appRouter = GoRouter(
  redirect: _handleRedirect,
  errorPageBuilder: (context, state) =>
      MaterialPage(child: PageNotFound(state.uri.toString())),
  routes: [
    ShellRoute(
        builder: (context, router, navigator) {
          return WondersAppScaffold(child: navigator);
        },
        routes: [
          AppRoute(
              ScreenPaths.splash,
              (_) => Container(
                  color: $styles.colors.greyStrong)), // This will be hidden
          //AppRoute(ScreenPaths.intro, (_) => IntroScreen()),
        ]),
  ],
);

class AppRoute extends GoRoute {
  AppRoute(String path, Widget Function(GoRouterState s) builder,
      {List<GoRoute> routes = const [], this.useFade = false})
      : super(
          path: path,
          routes: routes,
          pageBuilder: (context, state) {
            final pageContent = Scaffold(
              body: builder(state),
              resizeToAvoidBottomInset: false,
            );
            if (useFade) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: pageContent,
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              );
            }
            return CupertinoPage(child: pageContent);
          },
        );
  final bool useFade;
}

String? _handleRedirect(BuildContext context, GoRouterState state) {
  // Evite que alguien salga de `/` si la aplicación se está iniciando.
  /*if (!appLogic.isBootstrapComplete && state.uri.path != ScreenPaths.splash) {
    debugPrint('Redirecting from ${state.uri.path} to ${ScreenPaths.splash}.');
    _initialDeeplink ??= state.uri.toString();
    return ScreenPaths.splash;
  }
  if (appLogic.isBootstrapComplete && state.uri.path == ScreenPaths.splash) {
    debugPrint('Redirecting from ${state.uri.path} to ${ScreenPaths.home}');
    return ScreenPaths.home;
  }
  if (!kIsWeb) debugPrint('Navigate to: ${state.uri}');*/
  return null; // do nothing
}
