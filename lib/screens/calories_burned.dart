import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:healthharmony/models/Daily/daily_data_dto.dart';
import 'package:healthharmony/services/Daily/daily_data_service.dart';
import 'package:healthharmony/utils/secure_storage.dart';
import 'package:healthharmony/widget/daily_calorie_tile.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class CaloriesBurnedPage extends StatefulWidget {
  const CaloriesBurnedPage({super.key});

  @override
  State<CaloriesBurnedPage> createState() => _CaloriesBurnedPageState();
}

class _CaloriesBurnedPageState extends State<CaloriesBurnedPage> {
  final DailyDataService _service = DailyDataService();
  final SecureStorage _secureStorage = SecureStorage();
  List<DailyDataDTO> _data = [];
  bool _isLoading = true;
  final DateFormat _chartDayFormatter = DateFormat('dd');
  final DateFormat _tooltipDateFormatter = DateFormat('dd MMM', 'tr_TR');

  int? _touchedIndex;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _touchedIndex = null;
    });
    try {
      final userId = await _secureStorage.getUserId();
      if (userId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kullanıcı kimliği bulunamadı.')),
        );
        setState(() => _data = []);
        return;
      }
      var result = await _service.getLastSixDaysData(userId);
      if (!mounted) return;
      result.sort((a, b) => a.date.compareTo(b.date)); // En eski önce
      setState(() {
        _data = result;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kalori verileri yüklenirken hata oluştu: ${e.toString()}')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  BarChartGroupData makeGroupData(int x, double y, {bool isTouched = false}) {
    final color = isTouched ? Colors.deepOrange.shade700 : Colors.orange.shade400; // Kalori için farklı renkler
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 18,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    if (_data.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxYValue = _data.map((d) => d.caloriesBurned).reduce((a, b) => a > b ? a : b);
    final maxY = (maxYValue * 1.2).ceilToDouble();

    return AspectRatio(
      aspectRatio: 1.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 24.0),
        child: BarChart(
          BarChartData(
            maxY: maxY,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (BarChartGroupData group) { // tooltipBgColor yerine
                  return Colors.orange.shade800; // Kalori için farklı tooltip rengi
                },
                tooltipPadding: const EdgeInsets.all(8),
                tooltipMargin: 8,
                //tooltipRoundedRadius: 8,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final dailyData = _data[group.x.toInt()];
                  return BarTooltipItem(
                    '${_tooltipDateFormatter.format(dailyData.date.toLocal())}\n',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: NumberFormat("#,##0", "tr_TR").format(rod.toY.toInt()),
                        style: TextStyle(
                          color: Colors.yellow.shade300, // Vurgu rengi
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const TextSpan(
                        text: ' kcal', // Birim güncellendi
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
              ),
              touchCallback: (FlTouchEvent event, barTouchResponse) {
                setState(() {
                  if (!event.isInterestedForInteractions || barTouchResponse == null || barTouchResponse.spot == null) {
                    _touchedIndex = -1;
                    return;
                  }
                  _touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                });
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < _data.length) {
                      return SideTitleWidget(
                        meta: meta,
                        space: 4,
                        child: Text(
                          _chartDayFormatter.format(_data[index].date.toLocal()),
                          style: const TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      );
                    }
                    return const Text('');
                  },
                  reservedSize: 30,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, TitleMeta meta) {
                    if (value == 0) return const Text('');
                    if (value == meta.max) return const Text('');
                    return SideTitleWidget(
                      meta: meta,
                      child: Text(
                        NumberFormat.compact(locale: "tr_TR").format(value.toInt()),
                        style: const TextStyle(color: Colors.black54, fontSize: 12),
                        textAlign: TextAlign.left,
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(_data.length, (i) {
              return makeGroupData(
                i,
                _data[i].caloriesBurned.toDouble(), // Veri caloriesBurned oldu
                isTouched: i == _touchedIndex,
              );
            }),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) {
                return const FlLine(
                  //color: Colors.grey_300,
                  strokeWidth: 0.7,
                );
              },
            ),
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
        title: const Text(
          "Yakılan Kalori Geçmişi", // Başlık güncellendi
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_data.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                    child: _buildBarChart(),
                  ),
                if (_data.isEmpty && !_isLoading)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(FontAwesomeIcons.fire, size: 60, color: Colors.grey.shade400), // İkon güncellendi
                          const SizedBox(height: 16),
                          Text(
                            "Grafik için yakılan kalori verisi bulunamadı.", // Metin güncellendi
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 17, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadData,
                    child: _data.isEmpty && !_isLoading
                        ? Center(
                            child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FontAwesomeIcons.folderOpen, size: 50, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                "Geçmiş yakılan kalori kaydı bulunamadı.", // Metin güncellendi
                                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                              ),
                            ],
                          ))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                            itemCount: _data.length,
                            itemBuilder: (context, index) {
                              final entry = _data[index];
                              return DailyCalorieTile(dailyData: entry); // Yeni tile widget'ı
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}