import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:healthharmony/models/Activity/activity_dto.dart';
import 'package:healthharmony/screens/activitiy_detail_screen.dart'; // Bu ekran varsa ve kullanılacaksa
import 'package:healthharmony/services/Activity/activity_service.dart';


class BrowseActivitiesScreen extends StatefulWidget {
  const BrowseActivitiesScreen({super.key});

  @override
  _BrowseActivitiesScreenState createState() => _BrowseActivitiesScreenState();
}

class _BrowseActivitiesScreenState extends State<BrowseActivitiesScreen> {
  final ActivityService _activityService = ActivityService();
  List<ActivityDTO> _activities = [];
  bool _isLoading = true;
  bool _isAddingActivity = false; // Aktivite ekleme yükleme durumu
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadActivities() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final activities = await _activityService.getActivities();
      if (!mounted) return;
      setState(() => _activities = activities);
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackbar('Aktiviteler yüklenirken hata: ${e.toString()}');
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addUserActivity(ActivityDTO activity) async {
    if (!mounted) return;
    setState(() => _isAddingActivity = true);
    try {
      final success = await _activityService.addUserActivity(activity);
      if (!mounted) return;
      if (success) {
        _showSuccessSnackbar("'${activity.activityName}' aktivitelerinize eklendi!");
        // İsteğe bağlı: Ekledikten sonra ActivitiesScreen'a geri dönebilir
        // Navigator.pop(context, true); // true, bir değişiklik yapıldığını belirtir
      } else {
         _showErrorSnackbar("'${activity.activityName}' eklenemedi. Zaten eklemiş olabilirsiniz.");
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackbar('Aktivite eklenirken hata: ${e.toString()}');
    } finally {
      if (!mounted) return;
      setState(() => _isAddingActivity = false);
    }
  }

  List<ActivityDTO> get _filteredActivities {
    if (_searchQuery.isEmpty) return _activities;
    return _activities.where((activity) {
      return activity.activityName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             activity.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
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
        title: const Text(
          'Aktivitelere Gözat',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.grey.shade100,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: GestureDetector(
        onTap: () => _searchFocusNode.unfocus(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'Aktivite adı veya açıklaması ara...',
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade600),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white, // Veya Colors.grey.shade200
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                ),
                onChanged: (value) {
                  if (!mounted) return;
                  setState(() => _searchQuery = value);
                },
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
                  : _filteredActivities.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _searchQuery.isEmpty ? FontAwesomeIcons.personHiking : FontAwesomeIcons.magnifyingGlassMinus,
                                  size: 60, color: Colors.grey.shade400),
                                const SizedBox(height: 20),
                                Text(
                                  _searchQuery.isEmpty ? 'Yüklenecek aktivite bulunamadı.' : "Arama kriterlerine uygun aktivite bulunamadı.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          itemCount: _filteredActivities.length,
                          itemBuilder: (context, index) {
                            final activity = _filteredActivities[index];
                            return _buildBrowseActivityCard(activity, theme);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrowseActivityCard(ActivityDTO activity, ThemeData theme) {
    return Card(
      elevation: 2.5,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () {
          // ActivityDetailScreen'a yönlendirme (eğer kullanılacaksa)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ActivityDetailScreen(activity: activity),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      activity.activityName,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: theme.primaryColorDark),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline_rounded, color: theme.primaryColor, size: 28),
                    tooltip: "Aktivitelerime Ekle",
                    padding: EdgeInsets.zero, // Buton padding'ini azalt
                    constraints: const BoxConstraints(), // Buton boyutunu küçült
                    onPressed: _isAddingActivity ? null : () => _addUserActivity(activity),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                activity.description,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(FontAwesomeIcons.fire, color: Colors.orange.shade600, size: 14),
                      const SizedBox(width: 5),
                      Text(
                        '~${activity.estimatedCaloriesBurn} kcal',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(FontAwesomeIcons.gaugeHigh, color: Colors.blue.shade600, size: 14),
                      const SizedBox(width: 5),
                      Text(
                        'Zorluk: ${activity.difficultyLevel}/5',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ],
              ),
              if (activity.imageUrl != null && activity.imageUrl!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      activity.imageUrl!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 150,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: Center(child: CircularProgressIndicator(value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null)),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image_outlined, size: 40, color: Colors.grey.shade400),
                              const SizedBox(height: 4),
                              Text("Resim yüklenemedi", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}