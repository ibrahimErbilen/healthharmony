// lib/widgets/large_metric_display_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LargeMetricDisplayCard extends StatelessWidget {
  final IconData iconData;
  final int value;
  final String unit;
  final List<Color> gradientColors;
  final VoidCallback? onTap;

  const LargeMetricDisplayCard({
    super.key,
    required this.iconData,
    required this.value,
    required this.unit,
    required this.gradientColors,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,##0", "de_DE");
    String formattedValue = formatter.format(value);

    // Temadan gelen varsayılan metin stilini alıp rengini değiştiriyoruz.
    // Bu, fontFamily ve package bilgilerini doğru şekilde korur.
    final TextStyle? baseTextStyle = Theme.of(context).textTheme.bodyLarge;
    final TextStyle effectiveTextStyle = baseTextStyle?.copyWith(color: Colors.white) ??
                                        const TextStyle(color: Colors.white); // Fallback

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(iconData, size: 50, color: Colors.white),
            const SizedBox(width: 20),
            Expanded(
              child: RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  style: effectiveTextStyle, // <<<--- DEĞİŞİKLİK BURADA
                  children: <TextSpan>[
                    TextSpan(
                      text: formattedValue,
                      // Bu alt TextSpan'ın stili ana stilden miras alır,
                      // sadece farklı olan özellikleri override eder.
                      // fontFamily veya package belirtmeye gerek yok.
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 2.0,
                            color: Colors.black26,
                            offset: Offset(1.0, 1.0),
                          ),
                        ],
                      ),
                    ),
                    TextSpan(
                      text: ' $unit',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}