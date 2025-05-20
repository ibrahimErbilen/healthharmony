import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:healthharmony/models/Daily/daily_data_dto.dart';
import 'package:healthharmony/services/Daily/daily_data_service.dart';
import 'package:healthharmony/utils/secure_storage.dart';
import 'package:healthharmony/widget/large_metric_card.dart'; // Bu dosyanın doğru yolda olduğundan emin olun
import 'package:intl/intl.dart'; // Sayı formatlama için

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DailyDataService _dailyDataService = DailyDataService();
  final SecureStorage _secureStorage = SecureStorage();
  DailyDataDTO? _todayData;
  bool _isLoading = true;

  // --- Günlük Hedefler için State ve Controller'lar ---
  int _stepGoal = 8000; // Varsayılan değerler
  int _calorieBurnGoal = 500;
  double _targetWeight = 70.0;
  bool _isEditingGoals = false;

  final _stepGoalController = TextEditingController();
  final _calorieBurnGoalController = TextEditingController();
  final _targetWeightController = TextEditingController();
  // --- Bitiş: Günlük Hedefler ---

  @override
  void initState() {
    super.initState();
    _loadTodayData();
    _loadGoals(); // Hedefleri yükle
  }

  @override
  void dispose() {
    _stepGoalController.dispose();
    _calorieBurnGoalController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  Future<void> _loadTodayData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _dailyDataService.getTodayData();
      String? userId = await _secureStorage.getUserId();

      if (data == null) {
        final newData = DailyDataDTO(
          userId: userId,
          stepCount: 0,
          caloriesBurned: 0,
          caloriesConsumed: 0,
          date: DateTime.now(),
        );
        await _dailyDataService.saveDailyData(newData);
        if (!mounted) return;
        setState(() {
          _todayData = newData;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bugün için veri bulunamadı, yeni veri oluşturuldu.')),
        );
      } else {
        if (!mounted) return;
        setState(() {
          _todayData = data;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veri yüklenirken hata: ${e.toString()}')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadGoals() async {
    try {
      final stepGoal = await _secureStorage.getStepGoal();
      final calorieBurnGoal = await _secureStorage.getCalorieBurnGoal();
      final targetWeight = await _secureStorage.getTargetWeight();

      if (!mounted) return;
      setState(() {
        _stepGoal = stepGoal ?? 8000;
        _calorieBurnGoal = calorieBurnGoal ?? 500;
        _targetWeight = targetWeight ?? 70.0;

        _stepGoalController.text = _stepGoal.toString();
        _calorieBurnGoalController.text = _calorieBurnGoal.toString();
        _targetWeightController.text = _targetWeight.toStringAsFixed(1);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hedefler yüklenirken hata: ${e.toString()}')),
      );
    }
  }

  Future<void> _saveGoals() async {
    try {
      final stepGoal = int.tryParse(_stepGoalController.text.trim()) ?? _stepGoal;
      final calorieBurnGoal = int.tryParse(_calorieBurnGoalController.text.trim()) ?? _calorieBurnGoal;
      final targetWeight = double.tryParse(_targetWeightController.text.trim().replaceAll(',', '.')) ?? _targetWeight;

      await _secureStorage.saveStepGoal(stepGoal);
      await _secureStorage.saveCalorieBurnGoal(calorieBurnGoal);
      await _secureStorage.saveTargetWeight(targetWeight);

      if (!mounted) return;
      setState(() {
        _stepGoal = stepGoal;
        _calorieBurnGoal = calorieBurnGoal;
        _targetWeight = targetWeight;
        _isEditingGoals = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hedefler başarıyla kaydedildi!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hedefler kaydedilirken hata: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color cardColor1Start = Color(0xFF3EAEFF);
    const Color cardColor1End = Color(0xFF1B7AFC);
    const Color cardColor2Start = Color(0xFF20C3FF);
    const Color cardColor2End = Color(0xFF279EEE);
    const Color cardColor3Start = Color(0xFF00D4FF);
    const Color cardColor3End = Color(0xFF00A6F0);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'HealthHarmony',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.email_outlined, color: Colors.blueAccent, size: 28),
            onPressed: () {
              Navigator.pushNamed(context, '/conversation');
            },
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTodayData,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    margin: const EdgeInsets.only(bottom: 20.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(FontAwesomeIcons.bullseye, color: Colors.blue.shade700, size: 22),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Günlük Hedeflerim',
                                    style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Icon(
                                  _isEditingGoals ? Icons.close_rounded : Icons.edit_outlined,
                                  color: Colors.blue.shade600,
                                ),
                                onPressed: () {
                                  if (!mounted) return;
                                  setState(() {
                                    _isEditingGoals = !_isEditingGoals;
                                    if (!_isEditingGoals) {
                                      _stepGoalController.text = _stepGoal.toString();
                                      _calorieBurnGoalController.text = _calorieBurnGoal.toString();
                                      _targetWeightController.text = _targetWeight.toStringAsFixed(1);
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _isEditingGoals
                              ? _buildEditGoalsForm()
                              : _buildDisplayGoals(),
                        ],
                      ),
                    ),
                  ),
                  LargeMetricDisplayCard(
                    iconData: FontAwesomeIcons.personRunning,
                    value: _todayData?.stepCount ?? 0,
                    unit: 'adım',
                    gradientColors: const [cardColor1Start, cardColor1End],
                    onTap: () {
                      Navigator.pushNamed(context, '/step-count', arguments: _todayData);
                    },
                  ),
                  const SizedBox(height: 16),
                  LargeMetricDisplayCard(
                    iconData: FontAwesomeIcons.fireFlameCurved,
                    value: _todayData?.caloriesBurned ?? 0,
                    unit: 'kalori',
                    gradientColors: const [cardColor2Start, cardColor2End],
                    onTap: () {
                      Navigator.pushNamed(context, '/caloriesBurned', arguments: _todayData);
                    },
                  ),
                  const SizedBox(height: 16),
                  LargeMetricDisplayCard(
                    iconData: FontAwesomeIcons.burger,
                    value: _todayData?.caloriesConsumed ?? 0,
                    unit: 'kalori',
                    gradientColors: const [cardColor3Start, cardColor3End],
                    onTap: () {
                      Navigator.pushNamed(context, '/caloriesConsumed', arguments: _todayData);
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey.shade600,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.personWalking),
            activeIcon: Icon(FontAwesomeIcons.personRunning),
            label: 'Aktiviteler',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.wandMagicSparkles),
            label: 'AI\'a Sor',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.brain),
            label: 'Koç\'a Sor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Ayarlar',
          ),
        ],
        onTap: (index) {
          if (index == 0) return;
          switch (index) {
            case 1:
              Navigator.pushNamed(context, '/activities');
              break;
            case 2:
              Navigator.pushNamed(context, '/gemini');
              break;
            case 3:
              Navigator.pushNamed(context, '/coach');
              break;
            case 4:
              Navigator.pushNamed(context, '/settings');
              break;
          }
        },
      ),
    );
  }

  Widget _buildDisplayGoals() {
    return Column(
      children: [
        _buildGoalDisplayRow('Adım Hedefi:', '$_stepGoal adım', FontAwesomeIcons.shoePrints),
        const SizedBox(height: 10),
        _buildGoalDisplayRow('Kalori Yakımı Hedefi:', '$_calorieBurnGoal kcal', FontAwesomeIcons.fire),
        const SizedBox(height: 10),
        _buildGoalDisplayRow('Hedef Kilo:', '${_targetWeight.toStringAsFixed(1)} kg', FontAwesomeIcons.weightScale),
      ],
    );
  }

  Widget _buildGoalDisplayRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: TextStyle(fontSize: 16, color: Colors.grey.shade700))),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildEditGoalsForm() {
    return Column(
      children: [
        TextFormField(
          controller: _stepGoalController,
          decoration: InputDecoration(
            labelText: 'Adım Hedefi',
            hintText: 'örn: 8000',
            suffixText: 'adım',
            prefixIcon: const Icon(FontAwesomeIcons.shoePrints),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _calorieBurnGoalController,
          decoration: InputDecoration(
            labelText: 'Kalori Yakımı Hedefi',
            hintText: 'örn: 500',
            suffixText: 'kcal',
            prefixIcon: const Icon(FontAwesomeIcons.fire),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _targetWeightController,
          decoration: InputDecoration(
            labelText: 'Hedef Kilo',
            hintText: 'örn: 70.5',
            suffixText: 'kg',
            prefixIcon: const Icon(FontAwesomeIcons.weightScale),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.save_alt_rounded),
            onPressed: _isLoading ? null : _saveGoals,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            label: const Text('Hedefleri Kaydet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}