import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:healthharmony/models/Daily/daily_data_dto.dart';
import 'package:healthharmony/services/Daily/daily_data_service.dart';
import 'package:healthharmony/utils/secure_storage.dart';
import 'package:healthharmony/widget/daily_step_tile.dart'; // DailyStepTile widget'ınızın yolu
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart'; // fl_chart paketini import edin

class StepCountPage extends StatefulWidget {
  const StepCountPage({super.key});

  @override
  State<StepCountPage> createState() => _StepCountPageState();
}

class _StepCountPageState extends State<StepCountPage> {
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
        SnackBar(content: Text('Adım verileri yüklenirken hata oluştu: ${e.toString()}')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  BarChartGroupData makeGroupData(int x, double y, {bool isTouched = false}) {
    final color = isTouched ? Colors.blue.shade700 : Colors.blue.shade400;
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

    final maxYValue = _data.map((d) => d.stepCount).reduce((a, b) => a > b ? a : b);
    final maxY = (maxYValue * 1.2).ceilToDouble(); // Y ekseni için biraz pay bırak

    return AspectRatio(
      aspectRatio: 1.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 24.0),
        child: BarChart(
          BarChartData(
            maxY: maxY,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                //tooltipBgColor: Colors.blueGrey.shade700,
                tooltipPadding: const EdgeInsets.all(8),
                tooltipMargin: 8,
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
                          color: Colors.yellow.shade700,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const TextSpan(
                        text: ' adım',
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
                        meta: meta, // meta parametresini iletiyoruz
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
                    return SideTitleWidget( // meta parametresini iletiyoruz
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
                _data[i].stepCount.toDouble(),
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
          "Adım Geçmişi",
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
                    padding: const EdgeInsets.only(top: 16.0, bottom: 8.0), // Grafik için padding
                    child: _buildBarChart(),
                  ),
                if (_data.isEmpty && !_isLoading)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(FontAwesomeIcons.chartSimple, size: 60, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            "Grafik için adım verisi bulunamadı.",
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
                                "Geçmiş adım kaydı bulunamadı.",
                                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                              ),
                            ],
                          ))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                            itemCount: _data.length,
                            itemBuilder: (context, index) {
                              final entry = _data[index];
                              return DailyStepTile(dailyData: entry);
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}