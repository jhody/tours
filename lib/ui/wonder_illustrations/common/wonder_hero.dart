import 'package:tours/common_libs.dart';
import 'package:tours/ui/wonder_illustrations/common/wonder_illustration_config.dart';

/// Utility class that wraps a normal [Hero] widget, but respects WonderIllustrationConfig.enableHero setting
class WonderHero extends StatelessWidget {
  const WonderHero(this.config, this.tag, {super.key, required this.child});
  final WonderIllustrationConfig config;
  final Widget child;
  final String tag;

  @override
  Widget build(BuildContext context) => config.enableHero
      ? Hero(
          createRectTween: (begin, end) => RectTween(begin: begin!, end: end!),
          tag: tag,
          child: child,
        )
      : child;
}
