part of 'wonders_home_screen.dart';

class _VerticalSwipeController {
  _VerticalSwipeController(this.ticker, this.onSwipeComplete) {
    swipeReleaseAnim = AnimationController(vsync: ticker)
      ..addListener(handleSwipeReleaseAnimTick);
  }
  final TickerProvider ticker;
  final swipeAmt = ValueNotifier<double>(0);
  final isPointerDown = ValueNotifier<bool>(false);
  final double _pullToViewDetailsThreshold = 150;
  final VoidCallback onSwipeComplete;
  late final AnimationController swipeReleaseAnim;

  /// Cuando se reproduzca _swipeReleaseAnim, sincronice su valor con _swipeUpAmt
  void handleSwipeReleaseAnimTick() => swipeAmt.value = swipeReleaseAnim.value;
  void handleTapDown() => isPointerDown.value = true;
  void handleTapCancelled() => isPointerDown.value = false;

  void handleVerticalSwipeCancelled() {
    swipeReleaseAnim.duration = swipeAmt.value.seconds * .5;
    swipeReleaseAnim.reverse(from: swipeAmt.value);
    isPointerDown.value = false;
  }

  void handleVerticalSwipeUpdate(DragUpdateDetails details) {
    if (swipeReleaseAnim.isAnimating) swipeReleaseAnim.stop();

    isPointerDown.value = true;
    double value =
        (swipeAmt.value - details.delta.dy / _pullToViewDetailsThreshold)
            .clamp(0, 1);
    if (value != swipeAmt.value) {
      swipeAmt.value = value;
      if (swipeAmt.value == 1) {
        onSwipeComplete();
      }
    }

    //print(_swipeUpAmt.value);
  }

  /// Método de utilidad para empaquetar un par de ValueListenableBuilders y pasar los valores a un método de construcción.
  /// Guarda la interfaz de usuario en parte repetitiva al suscribirse a los cambios.
  Widget buildListener(
      {required Widget Function(
              double swipeUpAmt, bool isPointerDown, Widget? child)
          builder,
      Widget? child}) {
    return ValueListenableBuilder<double>(
      valueListenable: swipeAmt,
      builder: (_, swipeAmt, __) => ValueListenableBuilder<bool>(
        valueListenable: isPointerDown,
        builder: (_, isPointerDown, __) {
          return builder(swipeAmt, isPointerDown, child);
        },
      ),
    );
  }

  /// Método de utilidad para envolver un detector de gestos y conectar los controladores necesarios.
  Widget wrapGestureDetector(Widget child, {Key? key}) => GestureDetector(
      key: key,
      excludeFromSemantics: true,
      onTapDown: (_) => handleTapDown(),
      onTapUp: (_) => handleTapCancelled(),
      onVerticalDragUpdate: handleVerticalSwipeUpdate,
      onVerticalDragEnd: (_) => handleVerticalSwipeCancelled(),
      onVerticalDragCancel: handleVerticalSwipeCancelled,
      behavior: HitTestBehavior.translucent,
      child: child);

  void dispose() {
    swipeAmt.dispose();
    isPointerDown.dispose();
    swipeReleaseAnim.dispose();
  }
}
