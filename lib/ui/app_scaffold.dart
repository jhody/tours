import 'package:tours/common_libs.dart';
import 'package:tours/ui/common/app_scroll_behavior.dart';

class WondersAppScaffold extends StatelessWidget {
  const WondersAppScaffold({super.key, required this.child});
  final Widget child;
  static AppStyle get style => _style;
  static AppStyle _style = AppStyle();

  @override
  Widget build(BuildContext context) {
    // Escuche el tamaño del dispositivo y actualice AppStyle cuando cambie
    final mq = MediaQuery.of(context);
    appLogic.handleAppSizeChanged(mq.size);
    // Establecer el tiempo predeterminado para las animaciones en la aplicación
    Animate.defaultDuration = _style.times.fast;
    // Cree un objeto de estilo que se transmitirá al árbol de widgets.
    _style = AppStyle(screenSize: context.sizePx);
    return KeyedSubtree(
      key: ValueKey($styles.scale),
      child: Theme(
        data: $styles.colors.toThemeData(),
        // Proporcionar un estilo de texto predeterminado para permitir que Hero represente el texto correctamente
        child: DefaultTextStyle(
          style: $styles.text.body,
          // Utilice un comportamiento de desplazamiento personalizado en toda la aplicación
          child: ScrollConfiguration(
            behavior: AppScrollBehavior(),
            child: child,
          ),
        ),
      ),
    );
  }
}
