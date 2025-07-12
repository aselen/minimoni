import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../dashboard/dashboard_providers.dart';
import '../../core/constants/colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FeedingAnalysisPage extends ConsumerWidget {
  const FeedingAnalysisPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartData = ref.watch(weeklyMilkChartProvider);
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    final dayLabels = days.map((d) => _dayShort(d.weekday)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Süt Analizi'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.primaryPink,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      backgroundColor: const Color(0xFFFFF8F0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('🍼', style: TextStyle(fontSize: 28)),
                  SizedBox(width: 8),
                  Text(
                    'Süt Analizi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryPink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Center(
                child: Text(
                  'Son 7 Günlük Süt Miktarı',
                  style: TextStyle(fontSize: 14, color: AppColors.textMedium),
                ),
              ),
              Expanded(
                child: chartData.when(
                  data:
                      (data) => ListView(
                        padding: const EdgeInsets.all(24),
                        children: [
                          // Chart in a card
                          Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.07),
                                      blurRadius: 18,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 220,
                                      child: LineChart(
                                        LineChartData(
                                          gridData: FlGridData(
                                            show: true,
                                            drawVerticalLine: false,
                                            getDrawingHorizontalLine:
                                                (value) => FlLine(
                                                  color: const Color(
                                                    0xFFFFE4E1,
                                                  ).withOpacity(0.5),
                                                  strokeWidth: 1,
                                                ),
                                          ),
                                          titlesData: FlTitlesData(
                                            leftTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                reservedSize: 40,
                                                getTitlesWidget: (value, meta) {
                                                  if (value % 500 == 0) {
                                                    if (value >= 1000) {
                                                      return Text(
                                                        '${(value / 1000).toStringAsFixed(1)}K',
                                                        style: const TextStyle(
                                                          fontSize: 13,
                                                          color:
                                                              AppColors
                                                                  .textMedium,
                                                        ),
                                                      );
                                                    }
                                                    return Text(
                                                      '${value.toInt()}',
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        color:
                                                            AppColors
                                                                .textMedium,
                                                      ),
                                                    );
                                                  }
                                                  return const SizedBox();
                                                },
                                              ),
                                            ),
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                reservedSize:
                                                    36, // was 24 or default, now 36
                                                getTitlesWidget: (value, meta) {
                                                  final idx = value.toInt();
                                                  if (idx < 0 || idx > 6)
                                                    return const SizedBox();
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          top: 8.0,
                                                        ),
                                                    child: Text(
                                                      dayLabels[idx],
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        color:
                                                            AppColors
                                                                .primaryPink,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                interval: 1,
                                              ),
                                            ),
                                            rightTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                            topTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                          ),
                                          borderData: FlBorderData(show: false),
                                          minY: 0,
                                          lineBarsData: [
                                            LineChartBarData(
                                              spots: List.generate(
                                                data.length,
                                                (i) => FlSpot(
                                                  i.toDouble(),
                                                  data[i].toDouble(),
                                                ),
                                              ),
                                              isCurved: true,
                                              color: AppColors.primaryPink,
                                              barWidth: 5,
                                              dotData: FlDotData(show: true),
                                              belowBarData: BarAreaData(
                                                show: true,
                                                color: AppColors.primaryPink
                                                    .withOpacity(0.18),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20), // instead of 8
                                  ],
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 600.ms)
                              .slideY(begin: 0.1, duration: 600.ms),
                          const SizedBox(height: 32),
                          // Summary in a card
                          Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F8FF),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: _buildSummary(data, dayLabels),
                              )
                              .animate()
                              .fadeIn(duration: 600.ms)
                              .slideY(begin: 0.1, duration: 600.ms),
                          const SizedBox(height: 32),
                          // MiniMoni suggestion
                          Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF0F5),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.lightbulb_outline,
                                      color: AppColors.primaryPink,
                                      size: 22,
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Harika gidiyorsunuz! Süt miktarını düzenli takip etmek bebeğinizin sağlığı için çok önemli. 💕',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textMedium,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 800.ms)
                              .slideY(begin: 0.2, duration: 800.ms),
                          const SizedBox(height: 24),
                        ],
                      ),
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(child: Text('Hata: $e')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _dayShort(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Pzt';
      case DateTime.tuesday:
        return 'Sal';
      case DateTime.wednesday:
        return 'Çar';
      case DateTime.thursday:
        return 'Per';
      case DateTime.friday:
        return 'Cum';
      case DateTime.saturday:
        return 'Cmt';
      case DateTime.sunday:
        return 'Paz';
      default:
        return '';
    }
  }

  Widget _buildSummary(List<int> data, List<String> dayLabels) {
    final total = data.fold<int>(0, (sum, v) => sum + v);
    final max = data.isNotEmpty ? data.reduce((a, b) => a > b ? a : b) : 0;
    final maxIdx = data.indexOf(max);
    final avg = data.isNotEmpty ? (total / data.length).round() : 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            const Text(
              'Toplam',
              style: TextStyle(fontSize: 13, color: AppColors.textMedium),
            ),
            const SizedBox(height: 2),
            Text(
              '$total ml',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryPink,
              ),
            ),
          ],
        ),
        Column(
          children: [
            const Text(
              'Günlük Ortalama',
              style: TextStyle(fontSize: 13, color: AppColors.textMedium),
            ),
            const SizedBox(height: 2),
            Text(
              '$avg ml',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryPink,
              ),
            ),
          ],
        ),
        if (max > 0)
          Column(
            children: [
              const Text(
                'En yüksek gün',
                style: TextStyle(fontSize: 13, color: AppColors.textMedium),
              ),
              const SizedBox(height: 2),
              Text(
                '${dayLabels[maxIdx]} ($max ml)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPink,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
