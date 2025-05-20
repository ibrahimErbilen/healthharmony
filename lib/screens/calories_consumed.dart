import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:healthharmony/models/Daily/create_daily_food_eat_dto.dart';
import 'package:healthharmony/models/Daily/daily_data_dto.dart';
import 'package:healthharmony/models/Daily/daily_food_dto.dart';
import 'package:healthharmony/services/Daily/daily_data_service.dart';
import 'package:healthharmony/utils/secure_storage.dart';
import 'package:healthharmony/widget/food_search_result_card.dart';
import 'package:healthharmony/widget/today_food_item_tile.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class CaloriesConsumedPage extends StatefulWidget {
  const CaloriesConsumedPage({super.key});

  @override
  State<CaloriesConsumedPage> createState() => _CaloriesConsumedPageState();
}

class _CaloriesConsumedPageState extends State<CaloriesConsumedPage> {
  final DailyDataService _service = DailyDataService();
  final SecureStorage _secureStorage = SecureStorage();
  List<DailyDataDTO> _lastSixDaysData = []; // Grafik ve geçmiş liste için
  List<DailyFoodDto> _todayFoods = [];
  Map<String, dynamic>? _searchedFood;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode(); // Arama sonrası klavyeyi kapatmak için

  bool _isLoadingPage = true; // Sayfa ilk yükleme
  bool _isSearchingFood = false; // Yemek arama yükleme
  bool _isAddingFood = false; // Yemek ekleme yükleme

  final DateFormat _chartDayFormatter = DateFormat('dd');
  final DateFormat _tooltipDateFormatter = DateFormat('dd MMM', 'tr_TR');
  int? _touchedIndexInChart;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() => _isLoadingPage = true);
    await _loadLastSixDaysData();
    await _loadTodayFoods();
    if (!mounted) return;
    setState(() => _isLoadingPage = false);
  }

  Future<void> _loadLastSixDaysData() async {
    final userId = await _secureStorage.getUserId();
    if (userId == null) {
      _showErrorSnackbar('Kullanıcı kimliği bulunamadı.');
      if (!mounted) return;
      setState(() => _lastSixDaysData = []);
      return;
    }
    try {
      var result = await _service.getLastSixDaysData(userId);
      if (!mounted) return;
      result.sort((a, b) => a.date.compareTo(b.date)); // En eski önce
      setState(() => _lastSixDaysData = result);
    } catch (e) {
      _showErrorSnackbar('Geçmiş kalori verileri yüklenemedi: ${e.toString()}');
    }
  }

  Future<void> _loadTodayFoods() async {
    final userId = await _secureStorage.getUserId();
    if (userId == null) {
      // _loadLastSixDaysData zaten hata gösterecek.
      if (!mounted) return;
      setState(() => _todayFoods = []);
      return;
    }
    try {
      final todayFoods = await _service.getTodayFoods(userId);
      if (!mounted) return;
      setState(() => _todayFoods = todayFoods);
    } catch (e) {
      _showErrorSnackbar('Bugün yenenler yüklenemedi: ${e.toString()}');
    }
  }

  Future<void> _searchFood() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      _showErrorSnackbar("Lütfen aramak için bir yemek adı girin.");
      return;
    }
    _searchFocusNode.unfocus(); // Klavyeyi kapat
    if (!mounted) return;
    setState(() {
      _isSearchingFood = true;
      _searchedFood = null; // Önceki sonucu temizle
    });

    try {
      final result = await _service.searchFoodByName(query);
      if (!mounted) return;
      setState(() {
        _searchedFood = result;
      });
      if (result == null) {
        _showInfoSnackbar("'$query' için yemek bulunamadı.");
      }
    } catch (e) {
      _showErrorSnackbar("Yemek arama hatası: ${e.toString()}");
    } finally {
      if (!mounted) return;
      setState(() => _isSearchingFood = false);
    }
  }

  Future<void> _addFood() async {
    final userId = await _secureStorage.getUserId();
    if (_searchedFood == null || userId == null) return;

    if (!mounted) return;
    setState(() => _isAddingFood = true);

    try {
      final dto = CreateDailyFoodEatDto(
        userId: userId,
        foodName: _searchedFood!["foodName"],
        calories: _searchedFood!["calories"],
        date: DateTime.now(),
      );
      final success = await _service.addDailyFoodEat(dto);
      if (!mounted) return;
      if (success) {
        _showSuccessSnackbar("Yemek başarıyla eklendi.");
        _searchController.clear();
        setState(() {
          _searchedFood = null;
        });
        await _loadTodayFoods(); // Bugün yenenleri güncelle
        await _loadLastSixDaysData(); // Grafiği de güncellemek için (toplam kalori değişmiş olabilir)
      } else {
        _showErrorSnackbar("Yemek eklenemedi. Lütfen tekrar deneyin.");
      }
    } catch (e) {
      _showErrorSnackbar("Yemek ekleme hatası: $e");
    } finally {
      if (!mounted) return;
      setState(() => _isAddingFood = false);
    }
  }
  
  // Opsiyonel: Yemeği silme fonksiyonu
  // Future<void> _deleteFoodItem(String foodItemId) async { ... }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  void _showSuccessSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green.shade700),
    );
  }
  void _showInfoSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }


  BarChartGroupData _makeChartGroupData(int x, double y, {bool isTouched = false}) {
    final color = isTouched ? Colors.teal.shade700 : Colors.green.shade400;
    return BarChartGroupData(x: x, barRods: [
      BarChartRodData(toY: y, color: color, width: 18, borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6))),
    ]);
  }

  Widget _buildCaloriesConsumedChart() {
    if (_lastSixDaysData.isEmpty) return const SizedBox.shrink();
    final maxYValue = _lastSixDaysData.map((d) => d.caloriesConsumed).reduce((a, b) => a > b ? a : b);
    final maxY = (maxYValue * 1.2).ceilToDouble();

    return AspectRatio(
      aspectRatio: 1.6,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
        child: BarChart(
          BarChartData(
            maxY: maxY > 0 ? maxY : 100, // Min 100 kcal göster
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => Colors.teal.shade800,
                tooltipPadding: const EdgeInsets.all(8),
                tooltipMargin: 8,
                //tooltipRoundedRadius: 8,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final dailyData = _lastSixDaysData[group.x.toInt()];
                  return BarTooltipItem(
                    '${_tooltipDateFormatter.format(dailyData.date.toLocal())}\n',
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    children: <TextSpan>[
                      TextSpan(text: NumberFormat("#,##0", "tr_TR").format(rod.toY.toInt()), style: TextStyle(color: Colors.yellow.shade300, fontSize: 16, fontWeight: FontWeight.w500)),
                      const TextSpan(text: ' kcal', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                    ],
                  );
                },
              ),
              touchCallback: (FlTouchEvent event, barTouchResponse) {
                setState(() {
                  if (!event.isInterestedForInteractions || barTouchResponse == null || barTouchResponse.spot == null) {
                    _touchedIndexInChart = -1; return;
                  }
                  _touchedIndexInChart = barTouchResponse.spot!.touchedBarGroupIndex;
                });
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (double value, TitleMeta meta) {
                final index = value.toInt();
                if (index >= 0 && index < _lastSixDaysData.length) {
                  return SideTitleWidget(meta: meta, space: 4, child: Text(_chartDayFormatter.format(_lastSixDaysData[index].date.toLocal()), style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 13)));
                } return const Text('');
              }, reservedSize: 30)),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (value, TitleMeta meta) {
                if (value == 0 || value == meta.max) return const Text('');
                return SideTitleWidget(meta: meta, child: Text(NumberFormat.compact(locale: "tr_TR").format(value.toInt()), style: const TextStyle(color: Colors.black54, fontSize: 12), textAlign: TextAlign.left));
              })),
            ),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(_lastSixDaysData.length, (i) => _makeChartGroupData(i, _lastSixDaysData[i].caloriesConsumed.toDouble(), isTouched: i == _touchedIndexInChart)),
            gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => const FlLine(color: Colors.amber, strokeWidth: 0.7
            )),
          ),
          swapAnimationDuration: const Duration(milliseconds: 250),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Alınan Kalori Takibi", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _isLoadingPage
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector( // Klavyeyi kapatmak için genel dokunma algılayıcısı
              onTap: () => FocusScope.of(context).unfocus(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Yemek Arama Bölümü
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            decoration: InputDecoration(
                              hintText: "Yemek adı girin...",
                              prefixIcon: const Icon(Icons.search_rounded),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                            ),
                            onSubmitted: (_) => _searchFood(), // Enter ile arama
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _isSearchingFood ? null : _searchFood,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          ),
                          child: _isSearchingFood
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                              : const Icon(Icons.search_rounded, size: 26),
                        ),
                      ],
                    ),
                  ),

                  // Aranan Yemek Sonucu
                  if (_searchedFood != null && !_isSearchingFood)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: FoodSearchResultCard(
                        foodData: _searchedFood!,
                        onAdd: _addFood,
                        isAdding: _isAddingFood,
                      ),
                    ),
                  if (_isSearchingFood) // Arama sırasında yükleme göstergesi
                     const Padding(
                       padding: EdgeInsets.symmetric(vertical: 20.0),
                       child: Center(child: CircularProgressIndicator()),
                     ),
                  
                  // Sekmeler (Bugün Yenenler / Geçmiş Grafiği)
                  Expanded(
                    child: DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          TabBar(
                            labelColor: Colors.green.shade700,
                            unselectedLabelColor: Colors.grey.shade600,
                            indicatorColor: Colors.green.shade700,
                            indicatorWeight: 3,
                            tabs: const [
                              Tab(icon: Icon(FontAwesomeIcons.calendarDay), text: "Bugün Yenenler"),
                              Tab(icon: Icon(FontAwesomeIcons.chartLine), text: "Geçmiş (6 Gün)"),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                // Bugün Yenenler Sekmesi
                                _buildTodayFoodsList(),
                                // Geçmiş Kalori Grafiği ve Listesi Sekmesi
                                _buildPastCaloriesSection(),
                              ],
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

  Widget _buildTodayFoodsList() {
    if (_todayFoods.isEmpty && !_isLoadingPage) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FontAwesomeIcons.mugHot, size: 50, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text("Bugün henüz bir şey yemediniz.", style: TextStyle(fontSize: 17, color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              Text("Yukarıdan yemek arayıp ekleyebilirsiniz.", style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _todayFoods.length,
      itemBuilder: (context, index) {
        final food = _todayFoods[index];
        return TodayFoodItemTile(
          foodItem: food,
          // onDelete: () => _deleteFoodItem(food.id), // Silme işlevi eklenirse
        );
      },
    );
  }

  Widget _buildPastCaloriesSection() {
    return SingleChildScrollView( // Grafik ve listenin kaydırılabilmesi için
      child: Column(
        children: [
          if (_lastSixDaysData.isNotEmpty) _buildCaloriesConsumedChart(),
          if (_lastSixDaysData.isEmpty && !_isLoadingPage)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Column(
                children: [
                  Icon(FontAwesomeIcons.folderOpen, size: 50, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text("Geçmiş kalori kaydı bulunamadı.", style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                ],
              ),
            ),
          // İsteğe bağlı olarak son 6 günlük listeyi de burada gösterebiliriz.
          // Şimdilik sadece grafik.
          // ListView.builder(
          //   shrinkWrap: true, // SingleChildScrollView içinde olduğu için
          //   physics: const NeverScrollableScrollPhysics(), // Kaydırmayı engelle
          //   padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          //   itemCount: _lastSixDaysData.length,
          //   itemBuilder: (context, index) {
          //     final entry = _lastSixDaysData[_lastSixDaysData.length - 1 - index]; // En yeni en üstte
          //     return DailyCalorieConsumedTile(dailyData: entry);
          //   },
          // ),
        ],
      ),
    );
  }
}