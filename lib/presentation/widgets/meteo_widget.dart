import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import '../providers/meteo_provider.dart';

class MeteoWidget extends ConsumerWidget {
  const MeteoWidget({super.key});

  PhosphorIconData _icone(String code) {
    if (code.startsWith('01')) return PhosphorIcons.sun(PhosphorIconsStyle.fill);
    if (code.startsWith('02')) return PhosphorIcons.cloudSun(PhosphorIconsStyle.fill);
    if (code.startsWith('03') || code.startsWith('04')) return PhosphorIcons.cloud(PhosphorIconsStyle.fill);
    if (code.startsWith('09') || code.startsWith('10')) return PhosphorIcons.cloudRain(PhosphorIconsStyle.fill);
    if (code.startsWith('11')) return PhosphorIcons.cloudLightning(PhosphorIconsStyle.fill);
    if (code.startsWith('13')) return PhosphorIcons.snowflake(PhosphorIconsStyle.fill);
    return PhosphorIcons.cloudSun(PhosphorIconsStyle.fill);
  }

  // Dégradé "façon ciel" adapté à la condition météo et au moment de la journée
  // (suffixe d = jour, n = nuit dans les codes icône OpenWeatherMap).
  List<Color> _degrade(String code) {
    final nuit = code.endsWith('n');
    if (code.startsWith('01')) {
      return nuit ? [const Color(0xFF0B1E3D), const Color(0xFF2C4874)] : [const Color(0xFF3E9BE0), const Color(0xFF8FD3F4)];
    }
    if (code.startsWith('02') || code.startsWith('03')) {
      return nuit ? [const Color(0xFF25314F), const Color(0xFF4A5C82)] : [const Color(0xFF6FA9D8), const Color(0xFFAFCBE0)];
    }
    if (code.startsWith('04')) {
      return nuit ? [const Color(0xFF2B2F3A), const Color(0xFF4F5666)] : [const Color(0xFF7C8A9E), const Color(0xFFB0BAC7)];
    }
    if (code.startsWith('09') || code.startsWith('10')) {
      return nuit ? [const Color(0xFF1C2B3A), const Color(0xFF3B5166)] : [const Color(0xFF4A6572), const Color(0xFF7E9AA8)];
    }
    if (code.startsWith('11')) {
      return [const Color(0xFF232042), const Color(0xFF4B3F72)];
    }
    if (code.startsWith('13')) {
      return [const Color(0xFF7FA7C9), const Color(0xFFDCE9F0)];
    }
    // Brume/défaut
    return nuit ? [const Color(0xFF2A2E35), const Color(0xFF4B505A)] : [const Color(0xFF8B95A1), const Color(0xFFC3CAD1)];
  }

  String _capitalise(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _formatHeure(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(meteoProvider);

    return async.when(
      loading: () => const _MeteoSkeleton(),
      error: (_, _) => _MeteoErreur(onRetry: () => ref.invalidate(meteoProvider)),
      data: (meteo) {
        final degrade = _degrade(meteo.icone);
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: degrade,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(color: degrade.last.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 8)),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Icône géante en filigrane pour évoquer un "fond image" lié à la météo
              Positioned(
                right: -18,
                bottom: -18,
                child: Opacity(
                  opacity: 0.16,
                  child: PhosphorIcon(_icone(meteo.icone), color: AppColors.white, size: 130),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                PhosphorIcon(PhosphorIcons.mapPin(PhosphorIconsStyle.fill), color: AppColors.white70, size: 14),
                                const SizedBox(width: 4),
                                Text(meteo.ville, style: const TextStyle(color: AppColors.white70, fontSize: 13)),
                              ]),
                              const SizedBox(height: 4),
                              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('${meteo.temperature.round()}',
                                    style: const TextStyle(color: AppColors.white, fontSize: 44, fontWeight: FontWeight.w700, height: 1)),
                                const Padding(
                                  padding: EdgeInsets.only(top: 6),
                                  child: Text('°C', style: TextStyle(color: AppColors.white70, fontSize: 20, fontWeight: FontWeight.w500)),
                                ),
                              ]),
                              Text(_capitalise(meteo.description),
                                  style: const TextStyle(color: AppColors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: PhosphorIcon(_icone(meteo.icone), color: AppColors.white, size: 34),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(height: 1, color: AppColors.white.withValues(alpha: 0.2)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatMeteo(icone: PhosphorIcons.drop(PhosphorIconsStyle.fill), label: '${meteo.humidite}%', titre: 'Humidité'),
                        _StatMeteo(icone: PhosphorIcons.wind(PhosphorIconsStyle.fill), label: '${meteo.vent.round()} km/h', titre: 'Vent'),
                        _StatMeteo(icone: PhosphorIcons.thermometer(PhosphorIconsStyle.fill), label: '${meteo.tempMin.round()}° / ${meteo.tempMax.round()}°', titre: 'Min / Max'),
                      ],
                    ),
                    if (meteo.horsLigne) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          PhosphorIcon(PhosphorIcons.wifiSlash(PhosphorIconsStyle.bold), color: AppColors.white70, size: 13),
                          const SizedBox(width: 6),
                          Text(
                            'Hors ligne · maj ${_formatHeure(meteo.derniereMaj)}',
                            style: const TextStyle(color: AppColors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ]),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatMeteo extends StatelessWidget {
  final PhosphorIconData icone;
  final String label;
  final String titre;
  const _StatMeteo({required this.icone, required this.label, required this.titre});

  @override
  Widget build(BuildContext context) => Column(children: [
    PhosphorIcon(icone, size: 18, color: AppColors.white),
    const SizedBox(height: 4),
    Text(label, style: const TextStyle(color: AppColors.white, fontSize: 13, fontWeight: FontWeight.w600)),
    Text(titre, style: const TextStyle(color: AppColors.white70, fontSize: 10)),
  ]);
}

class _MeteoSkeleton extends StatelessWidget {
  const _MeteoSkeleton();

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    height: 160,
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border, width: 1),
    ),
    child: Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHigh,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 80, height: 12, color: AppColors.white),
            const SizedBox(height: 10),
            Container(width: 100, height: 36, color: AppColors.white),
            const SizedBox(height: 10),
            Container(width: 140, height: 12, color: AppColors.white),
          ],
        ),
      ),
    ),
  );
}

class _MeteoErreur extends StatelessWidget {
  final VoidCallback onRetry;
  const _MeteoErreur({required this.onRetry});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border, width: 1),
    ),
    child: Row(children: [
      PhosphorIcon(PhosphorIcons.cloudSlash(PhosphorIconsStyle.regular), color: AppColors.textMuted, size: 22),
      const SizedBox(width: 12),
      const Expanded(
        child: Text('Météo indisponible', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
      ),
      TextButton(
        onPressed: onRetry,
        child: const Text('Réessayer', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
      ),
    ]),
  );
}
