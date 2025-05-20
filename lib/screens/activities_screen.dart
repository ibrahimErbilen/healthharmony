import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:healthharmony/models/Activity/user_activity_dto.dart';
import 'package:healthharmony/services/Activity/activity_service.dart';
import 'package:healthharmony/widget/activity_card.dart';
// ActivityCard widget'ınız

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  _ActivitiesScreenState createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  final ActivityService _activityService = ActivityService();
  List<UserActivityDTO> _activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final activities = await _activityService.getUserActivities();
      final incompleteActivities = activities.where((a) => !a.isCompleted).toList();
      incompleteActivities.sort((a, b) => b.addedDate.compareTo(a.addedDate));
      if (!mounted) return;
      setState(() => _activities = incompleteActivities);
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackbar('Aktiviteler yüklenirken hata: ${e.toString()}');
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  // Aktiviteyi tamamlamak için onay dialogu gösteren ve işlemi yapan metot
  Future<void> _confirmAndToggleActivityCompletion(UserActivityDTO activity) async {
    if (!mounted) return;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Aktiviteyi Tamamla'),
          content: Text("'${activity.activityName}' adlı aktiviteyi tamamlandı olarak işaretlemek istediğinizden emin misiniz?"),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.green.shade700),
              child: const Text('Onayla ve Tamamla'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      // Kullanıcı onayladıysa tamamlama işlemini yap
      await _performToggleActivityCompletion(activity);
    }
  }

  // Asıl tamamlama işlemini yapan metot
  Future<void> _performToggleActivityCompletion(UserActivityDTO activity) async {
    // Optimistic UI için orijinal durumu kaydetmeye gerek yok,
    // çünkü işlem sadece onaylandıktan sonra yapılıyor ve liste yeniden yükleniyor.
    try {
      final success = await _activityService.toggleActivityCompletion(activity); // Backend'e gönder

      if (!mounted) return;
      if (success) {
        _showSuccessSnackbar('Aktivite başarıyla tamamlandı!');
        _loadActivities(); // Listeyi backend'den güncelleyerek doğrula (tamamlanan aktivite listeden kalkacak)
      } else {
        _showErrorSnackbar('Aktivite durumu güncellenemedi. Lütfen tekrar deneyin.');
        _loadActivities(); // Başarısız olsa bile listeyi senkronize et
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackbar('İşlem sırasında bir hata oluştu: ${e.toString()}');
      _loadActivities(); // Hata durumunda listeyi kesin olarak backend'den al
    }
  }


  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  void _showSuccessSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green.shade600),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Yapılacak Aktiviteler',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.grey.shade100,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: theme.primaryColor),
            tooltip: "Yenile",
            onPressed: _isLoading ? null : _loadActivities,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
          : _activities.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(FontAwesomeIcons.listCheck, size: 60, color: Colors.grey.shade400),
                        const SizedBox(height: 20),
                        Text(
                          'Tamamlanacak aktiviteniz bulunmuyor.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Yeni aktiviteler eklemek için '+' butonuna dokunun.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadActivities,
                  color: theme.primaryColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _activities.length,
                    itemBuilder: (context, index) {
                      final activity = _activities[index];
                      return ActivityCard(
                        activity: activity,
                        // onToggleCompletion direkt çağırmak yerine onay dialogunu gösteren metodu çağır
                        onToggleCompletion: () => _confirmAndToggleActivityCompletion(activity),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/activities/browse').then((value) {
            _loadActivities();
          });
        },
        backgroundColor: const Color.fromARGB(255, 40, 117, 180),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded, size: 28),
        tooltip: "Yeni Aktivite Gözat",
      ),
    );
  }
}