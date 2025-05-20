import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Video URL'si için eklenecek paket
import 'package:healthharmony/models/Activity/activity_dto.dart'; // Kendi model yolunuzu kullanın

// Örnek ActivityDTO (kendi modelinizi kullanın)


class ActivityDetailScreen extends StatelessWidget {
  final ActivityDTO activity;

  const ActivityDetailScreen({super.key, required this.activity});

  // Zorluk seviyesini metne çeviren yardımcı fonksiyon
  String _getDifficultyText(int level) {
    switch (level) {
      case 1:
        return 'Çok Kolay';
      case 2:
        return 'Kolay';
      case 3:
        return 'Orta';
      case 4:
        return 'Zor';
      case 5:
        return 'Çok Zor';
      default:
        return '$level/5';
    }
  }

  // URL'yi açmak için yardımcı fonksiyon
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // Hata durumunda kullanıcıya bilgi verilebilir
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Video açılamadı: $urlString')));
      print('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Temayı alalım

    return Scaffold(
      appBar: AppBar(
        title: Text(activity.activityName),
        elevation: 0, // Daha modern bir görünüm için gölgeyi kaldırabiliriz
      ),
      body: SingleChildScrollView( // İçerik taşarsa kaydırma sağlar
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resim Bölümü
            if (activity.imageUrl != null && activity.imageUrl!.isNotEmpty)
              Center( // Resmi ortalamak için
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    activity.imageUrl!,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 250,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 250,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image, size: 60, color: Colors.grey[600]),
                            const SizedBox(height: 8),
                            Text('Resim yüklenemedi', style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              )
            else
              // Resim yoksa gösterilecek placeholder
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey[400]),
              ),

            const SizedBox(height: 24),

            // Aktivite Adı
            Text(
              activity.activityName,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Açıklama
            if (activity.description.isNotEmpty)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    activity.description,
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              )
            else
              Text("Bu aktivite için açıklama bulunmamaktadır.", style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),

            const SizedBox(height: 20),

            // Detaylar Bölümü (Kalori ve Zorluk)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    _buildInfoRow(
                      icon: Icons.local_fire_department,
                      iconColor: Colors.orangeAccent,
                      label: 'Yaklaşık Kalori',
                      value: '${activity.estimatedCaloriesBurn} kcal',
                      context: context,
                    ),
                    const Divider(height: 20),
                    _buildInfoRow(
                      icon: Icons.fitness_center,
                      iconColor: Colors.blueAccent,
                      label: 'Zorluk Seviyesi',
                      value: _getDifficultyText(activity.difficultyLevel),
                      context: context,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Video Linki
            if (activity.videoUrl != null && activity.videoUrl!.isNotEmpty)
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.play_circle_fill_rounded),
                  label: const Text('Aktivite Videosunu İzle'),
                  style: ElevatedButton.styleFrom(
                    // backgroundColor: theme.colorScheme.secondary, // Temaya uygun renk
                    // foregroundColor: theme.colorScheme.onSecondary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: theme.textTheme.labelLarge,
                  ),
                  onPressed: () {
                    _launchURL(activity.videoUrl!);
                  },
                ),
              ),
            const SizedBox(height: 20), // Alt boşluk
          ],
        ),
      ),
    );
  }

  // Bilgi satırlarını oluşturmak için yardımcı widget
  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.end, // Değeri sağa yasla
          ),
        ),
      ],
    );
  }
}