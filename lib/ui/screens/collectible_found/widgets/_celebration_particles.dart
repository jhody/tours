part of '../collectible_found_screen.dart';

class _CelebrationParticles extends StatelessWidget {
  const _CelebrationParticles({super.key, this.fadeMs = 1000});

  final int fadeMs;

  @override
  Widget build(BuildContext context) {
    final Color color = $styles.colors.accent1;
    int particleCount = 1200;

    return Positioned.fill(
      child: RepaintBoundary(
        child: ParticleField(
          blendMode: BlendMode.dstIn,
          spriteSheet: SpriteSheet(
            image: AssetImage(ImagePaths.particle),
            frameWidth: 21,
            scale: 0.75,
          ),
          onTick: (controller, elapsed, size) {
            List<Particle> particles = controller.particles;

            // calcule la distancia de la base desde el centro y la velocidad según el ancho/alto:
            final double d = min(size.width, size.height) * 0.3;
            final double v = d * 0.08;

            // calcule un multiplicador de opacidad en función del tiempo transcurrido (es decir, desvanecimiento):
            controller.opacity = Curves.easeOutExpo
                .transform(max(0, 1 - elapsed.inMilliseconds / fadeMs));
            if (controller.opacity == 0) return;

            // agregue nuevas partículas, reduciendo el número agregado en cada tick:
            int addCount = particleCount ~/ 30;
            particleCount -= addCount;
            while (--addCount > 0) {
              final double angle = rnd.getRad();
              particles.add(Particle(
                // agregar variación aleatoria lo hace más interesante visualmente:
                x: cos(angle) * d * rnd(0.8, 1),
                y: sin(angle) * d * rnd(0.8, 1),
                vx: cos(angle) * v * rnd(0.5, 1.5),
                vy: sin(angle) * v * rnd(0.5, 1.5),
                color: color.withOpacity(rnd(0.5, 1)),
              ));
            }

            // actualice las partículas existentes y elimine las antiguas:
            for (int i = particles.length - 1; i >= 0; i--) {
              final Particle o = particles[i];
              o.update(frame: o.age ~/ 3);
              if (o.age > 40) particles.removeAt(i);
            }
          },
        ),
      ),
    );
  }
}
