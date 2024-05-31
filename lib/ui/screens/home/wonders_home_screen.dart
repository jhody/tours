import 'package:tours/common_libs.dart';
import 'package:tours/logic/data/wonder_data.dart';
import 'package:tours/ui/common/app_icons.dart';
import 'package:tours/ui/common/controls/app_header.dart';
import 'package:tours/ui/common/controls/app_page_indicator.dart';
import 'package:tours/ui/common/gradient_container.dart';
import 'package:tours/ui/common/previous_next_navigation.dart';
import 'package:tours/ui/common/themed_text.dart';
import 'package:tours/ui/common/utils/app_haptics.dart';
import 'package:tours/ui/screens/home_menu/home_menu.dart';
import 'package:tours/ui/wonder_illustrations/common/animated_clouds.dart';
import 'package:tours/ui/wonder_illustrations/common/wonder_illustration.dart';
import 'package:tours/ui/wonder_illustrations/common/wonder_illustration_config.dart';
import 'package:tours/ui/wonder_illustrations/common/wonder_title_text.dart';

part '_vertical_swipe_controller.dart';
part 'widgets/_animated_arrow_button.dart';

class HomeScreen extends StatefulWidget with GetItStatefulWidgetMixin {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// Muestra una lista desplazable horizontalmente PageView intercalada entre las capas de primer plano y de fondo
/// organizado en un parallax style.
class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  List<WonderData> get _wonders => wondersLogic.all;
  bool _isMenuOpen = false;

  /// Set initial wonderIndex
  late int _wonderIndex = 0;
  int get _numWonders => _wonders.length;

  /// Se utiliza para pulir la transición al salir de esta página para la vista de detalles.
  /// Se utiliza para capturar _swipeAmt en el momento de la transición y congelar el maravilloso primer plano en su lugar a medida que nos alejamos.
  double? _swipeOverride;

  /// Se utiliza para permitir que el primer plano se desvanezca cuando se regresa a esta vista (desde los detalles)
  bool _fadeInOnNextBuild = false;

  /// Todos los elementos que deberían aparecer gradualmente al regresar de la vista de detalles.
  /// Usar interpolaciones individuales es más eficiente que interpolar a todo el padre
  final _fadeAnims = <AnimationController>[];

  WonderData get currentWonder => _wonders[_wonderIndex];

  late final _VerticalSwipeController _swipeController =
      _VerticalSwipeController(this, _showDetailsPage);

  bool _isSelected(WonderType t) => t == currentWonder.type;

  @override
  void initState() {
    super.initState();
    // Cargar wonderIndex previamente guardado si tenemos uno
    _wonderIndex = settingsLogic.prevWonderIndex.value ?? 0;
    // permite el desplazamiento 'infinito' comenzando en un número de página muy alto, agrega WonderIndex para comenzar en la página correcta
    final initialPage = _numWonders * 100 + _wonderIndex;
    // Create page controller,
    _pageController =
        PageController(viewportFraction: 1, initialPage: initialPage);
  }

  void _handlePageChanged(value) {
    final newIndex = value % _numWonders;
    if (newIndex == _wonderIndex) {
      return; // Exit early si ya estamos en esta página
    }
    setState(() {
      _wonderIndex = newIndex;
      settingsLogic.prevWonderIndex.value = _wonderIndex;
    });
    AppHaptics.lightImpact();
  }

  void _handleOpenMenuPressed() async {
    setState(() => _isMenuOpen = true);
    WonderType? pickedWonder =
        await appLogic.showFullscreenDialogRoute<WonderType>(
      context,
      HomeMenu(data: currentWonder),
      transparent: true,
    );
    setState(() => _isMenuOpen = false);
    if (pickedWonder != null) {
      _setPageIndex(_wonders.indexWhere((w) => w.type == pickedWonder));
    }
  }

  void _handleFadeAnimInit(AnimationController controller) {
    _fadeAnims.add(controller);
    controller.value = 1;
  }

  void _handlePageIndicatorDotPressed(int index) => _setPageIndex(index);

  void _handlePrevNext(int i) => _setPageIndex(_wonderIndex + i, animate: true);

  void _setPageIndex(int index, {bool animate = false}) {
    if (index == _wonderIndex) return;
    // Para admitir el desplazamiento infinito, no podemos saltar directamente al índice presionado. En su lugar, hágalo relativo a nuestra posición actual.
    final pos =
        ((_pageController.page ?? 0) / _numWonders).floor() * _numWonders;
    final newIndex = pos + index;
    if (animate == true) {
      _pageController.animateToPage(newIndex,
          duration: $styles.times.med, curve: Curves.easeOutCubic);
    } else {
      _pageController.jumpToPage(newIndex);
    }
  }

  void _showDetailsPage() async {
    _swipeOverride = _swipeController.swipeAmt.value;
    context.go(ScreenPaths.wonderDetails(currentWonder.type, tabIndex: 0));
    await Future.delayed(100.ms);
    _swipeOverride = null;
    _fadeInOnNextBuild = true;
  }

  void _startDelayedFgFade() async {
    try {
      for (var a in _fadeAnims) {
        a.value = 0;
      }
      await Future.delayed(300.ms);
      for (var a in _fadeAnims) {
        a.forward();
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_fadeInOnNextBuild == true) {
      _startDelayedFgFade();
      _fadeInOnNextBuild = false;
    }

    return _swipeController.wrapGestureDetector(Container(
      color: $styles.colors.black,
      child: PreviousNextNavigation(
        listenToMouseWheel: false,
        onPreviousPressed: () => _handlePrevNext(-1),
        onNextPressed: () => _handlePrevNext(1),
        child: Stack(
          children: [
            /// Background
            ..._buildBgAndClouds(),

            /// Wonders Illustrations (main content)
            _buildMgPageView(),

            /// Foreground illustrations and gradients
            _buildFgAndGradients(),

            /// Controles que flotan sobre las distintas ilustraciones.
            _buildFloatingUi(),
          ],
        ).animate().fadeIn(),
      ),
    ));
  }

  @override
  void dispose() {
    _swipeController.dispose();
    super.dispose();
  }

  Widget _buildMgPageView() {
    return ExcludeSemantics(
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: _handlePageChanged,
        itemBuilder: (_, index) {
          final wonder = _wonders[index % _wonders.length];
          final wonderType = wonder.type;
          bool isShowing = _isSelected(wonderType);
          return _swipeController.buildListener(
            builder: (swipeAmt, _, child) {
              final config = WonderIllustrationConfig.mg(
                isShowing: isShowing,
                zoom: .05 * swipeAmt,
              );
              return WonderIllustration(wonderType, config: config);
            },
          );
        },
      ),
    );
  }

  List<Widget> _buildBgAndClouds() {
    return [
      // Background
      ..._wonders.map((e) {
        final config =
            WonderIllustrationConfig.bg(isShowing: _isSelected(e.type));
        return WonderIllustration(e.type, config: config);
      }),
      // Clouds
      FractionallySizedBox(
        widthFactor: 1,
        heightFactor: .5,
        child: AnimatedClouds(wonderType: currentWonder.type, opacity: 1),
      )
    ];
  }

  Widget _buildFgAndGradients() {
    Widget buildSwipeableBgGradient(Color fgColor) {
      return _swipeController.buildListener(
          builder: (swipeAmt, isPointerDown, _) {
        return IgnorePointer(
          child: FractionallySizedBox(
            heightFactor: .6,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    fgColor.withOpacity(0),
                    fgColor.withOpacity(.5 +
                        fgColor.opacity * .25 +
                        (isPointerDown ? .05 : 0) +
                        swipeAmt * .20),
                  ],
                  stops: const [0, 1],
                ),
              ),
            ),
          ),
        );
      });
    }

    final gradientColor = currentWonder.type.bgColor;
    return Stack(children: [
      /// Degradado de primer plano-1, se oscurece al deslizar hacia arriba
      BottomCenter(
        child: buildSwipeableBgGradient(gradientColor.withOpacity(.65)),
      ),

      /// Foreground decorators
      ..._wonders.map((e) {
        return _swipeController.buildListener(builder: (swipeAmt, _, child) {
          final config = WonderIllustrationConfig.fg(
            isShowing: _isSelected(e.type),
            zoom: .4 * (_swipeOverride ?? swipeAmt),
          );
          return Animate(
              effects: const [FadeEffect()],
              onPlay: _handleFadeAnimInit,
              child: IgnorePointer(
                  child: WonderIllustration(e.type, config: config)));
        });
      }),

      /// Degradado de primer plano-2, se oscurece al deslizar hacia arriba
      BottomCenter(
        child: buildSwipeableBgGradient(gradientColor),
      ),
    ]);
  }

  Widget _buildFloatingUi() {
    return Stack(children: [
      /// Floating controls / UI
      AnimatedSwitcher(
        duration: $styles.times.fast,
        child: AnimatedOpacity(
          opacity: _isMenuOpen ? 0 : 1,
          duration: $styles.times.med,
          child: RepaintBoundary(
            child: OverflowBox(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: double.infinity),
                  const Spacer(),

                  /// Title Content
                  LightText(
                    child: IgnorePointer(
                      ignoringSemantics: false,
                      child: Transform.translate(
                        offset: Offset(0, 30),
                        child: Column(
                          children: [
                            Semantics(
                              liveRegion: true,
                              button: true,
                              header: true,
                              onIncrease: () => _setPageIndex(_wonderIndex + 1),
                              onDecrease: () => _setPageIndex(_wonderIndex - 1),
                              onTap: () => _showDetailsPage(),
                              // Ocultar el título cuando el menú esté abierto para pulir visualmente
                              child: WonderTitleText(currentWonder,
                                  enableShadows: true),
                            ),
                            Gap($styles.insets.md),
                            AppPageIndicator(
                              count: _numWonders,
                              controller: _pageController,
                              color: $styles.colors.white,
                              dotSize: 8,
                              onDotPressed: _handlePageIndicatorDotPressed,
                              semanticPageTitle: $strings.homeSemanticWonder,
                            ),
                            Gap($styles.insets.md),
                          ],
                        ),
                      ),
                    ),
                  ),

                  /// Flecha animada y fondo.
                  /// Wrap en un contenedor de ancho completo para que sea más fácil de encontrar para los lectores de pantalla
                  Container(
                    width: double.infinity,
                    alignment: Alignment.center,

                    /// Pierde el estado de los objetos secundarios cuando cambia el índice, esto volverá a ejecutar todo el conmutador animado y la flecha animada.
                    key: ValueKey(_wonderIndex),
                    child: Stack(
                      children: [
                        /// Rectángulo redondeado expandible que crece en altura a medida que el usuario desliza hacia arriba
                        Positioned.fill(
                            child: _swipeController.buildListener(
                          builder: (swipeAmt, _, child) {
                            double heightFactor = .5 + .5 * (1 + swipeAmt * 4);
                            return FractionallySizedBox(
                              alignment: Alignment.bottomCenter,
                              heightFactor: heightFactor,
                              child:
                                  Opacity(opacity: swipeAmt * .5, child: child),
                            );
                          },
                          child: VtGradient(
                            [
                              $styles.colors.white.withOpacity(0),
                              $styles.colors.white.withOpacity(1)
                            ],
                            const [.3, 1],
                            borderRadius: BorderRadius.circular(99),
                          ),
                        )),

                        /// Flecha Btn que aparece y desaparece
                        _AnimatedArrowButton(
                            onTap: _showDetailsPage,
                            semanticTitle: currentWonder.title),
                      ],
                    ),
                  ),
                  Gap($styles.insets.md),
                ],
              ),
            ),
          ),
        ),
      ),

      /// Menu Btn
      TopLeft(
        child: AnimatedOpacity(
          duration: $styles.times.fast,
          opacity: _isMenuOpen ? 0 : 1,
          child: AppHeader(
            backIcon: AppIcons.menu,
            backBtnSemantics: $strings.homeSemanticOpenMain,
            onBack: _handleOpenMenuPressed,
            isTransparent: true,
          ),
        ),
      ),
    ]);
  }
}
