import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/colors.dart';
import 'providers/growth_providers.dart';
import 'growth_input_page.dart';

class GrowthAnalysisPage extends ConsumerWidget {
  const GrowthAnalysisPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heightChartData = ref.watch(heightChartDataProvider);
    final weightChartData = ref.watch(weightChartDataProvider);
    final growthStats = ref.watch(growthStatsProvider);
    final growthTrend = ref.watch(growthTrendProvider);

    return Scaffold(
      backgroundColor: AppColors.softPink,
      appBar: AppBar(
        title: const Text(
          'Gelişim Analizi',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primaryPink),
            tooltip: 'Boy/Kilo Ekle',
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const GrowthInputPage(),
                ),
              );
              if (result == true) {
                // Sayfa dönince Riverpod provider'larını refresh et
                ref.invalidate(heightChartDataProvider);
                ref.invalidate(weightChartDataProvider);
                ref.invalidate(growthStatsProvider);
                ref.invalidate(growthTrendProvider);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primaryPink.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Icon(
                      Icons.trending_up,
                      color: AppColors.primaryPink,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gelişim Takibi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Son 30 günlük boy ve kilo değişimi',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: growthStats.when(
                    data:
                        (stats) => _buildStatCard(
                          '📏 Ortalama Boy',
                          '${stats['avgHeight']?.toStringAsFixed(1) ?? '0'} cm',
                          AppColors.primaryPink,
                        ),
                    loading:
                        () => _buildStatCard(
                          '📏 Ortalama Boy',
                          '...',
                          AppColors.primaryPink,
                        ),
                    error:
                        (_, __) => _buildStatCard(
                          '📏 Ortalama Boy',
                          'Hata',
                          AppColors.error,
                        ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: growthStats.when(
                    data:
                        (stats) => _buildStatCard(
                          '⚖️ Ortalama Kilo',
                          '${stats['avgWeight']?.toStringAsFixed(1) ?? '0'} kg',
                          AppColors.pastelBlue,
                        ),
                    loading:
                        () => _buildStatCard(
                          '⚖️ Ortalama Kilo',
                          '...',
                          AppColors.pastelBlue,
                        ),
                    error:
                        (_, __) => _buildStatCard(
                          '⚖️ Ortalama Kilo',
                          'Hata',
                          AppColors.error,
                        ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Trend Cards
            Row(
              children: [
                Expanded(
                  child: growthTrend.when(
                    data:
                        (trend) => _buildTrendCard(
                          '📈 Boy Değişimi',
                          trend['heightTrend']?.toStringAsFixed(1) ?? '0',
                          'cm',
                          (trend['heightTrend'] ?? 0) >= 0,
                        ),
                    loading:
                        () => _buildTrendCard(
                          '📈 Boy Değişimi',
                          '...',
                          'cm',
                          true,
                        ),
                    error:
                        (_, __) => _buildTrendCard(
                          '📈 Boy Değişimi',
                          'Hata',
                          'cm',
                          true,
                        ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: growthTrend.when(
                    data:
                        (trend) => _buildTrendCard(
                          '📈 Kilo Değişimi',
                          trend['weightTrend']?.toStringAsFixed(1) ?? '0',
                          'kg',
                          (trend['weightTrend'] ?? 0) >= 0,
                        ),
                    loading:
                        () => _buildTrendCard(
                          '📈 Kilo Değişimi',
                          '...',
                          'kg',
                          true,
                        ),
                    error:
                        (_, __) => _buildTrendCard(
                          '📈 Kilo Değişimi',
                          'Hata',
                          'kg',
                          true,
                        ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Height Chart
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Boy Grafiği (Son 30 Gün)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: heightChartData.when(
                      data:
                          (data) =>
                              data.isEmpty
                                  ? const Center(
                                    child: Text(
                                      'Henüz boy verisi bulunmuyor',
                                      style: TextStyle(
                                        color: AppColors.textMedium,
                                      ),
                                    ),
                                  )
                                  : LineChart(
                                    LineChartData(
                                      gridData: FlGridData(
                                        show: true,
                                        drawVerticalLine: false,
                                        horizontalInterval: 5,
                                        getDrawingHorizontalLine: (value) {
                                          return const FlLine(
                                            color: AppColors.mediumGray,
                                            strokeWidth: 1,
                                          );
                                        },
                                      ),
                                      titlesData: FlTitlesData(
                                        show: true,
                                        rightTitles: const AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: false,
                                          ),
                                        ),
                                        topTitles: const AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: false,
                                          ),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 30,
                                            interval: 1,
                                            getTitlesWidget: (
                                              double value,
                                              TitleMeta meta,
                                            ) {
                                              if (value.toInt() < data.length) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 8,
                                                      ),
                                                  child: Text(
                                                    data[value
                                                        .toInt()]['formattedDate'],
                                                    style: const TextStyle(
                                                      color:
                                                          AppColors.textMedium,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                );
                                              }
                                              return const Text('');
                                            },
                                          ),
                                        ),
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 40,
                                            interval: 5,
                                            getTitlesWidget: (
                                              double value,
                                              TitleMeta meta,
                                            ) {
                                              return Text(
                                                '${value.toInt()}',
                                                style: const TextStyle(
                                                  color: AppColors.textMedium,
                                                  fontSize: 12,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      borderData: FlBorderData(
                                        show: true,
                                        border: Border.all(
                                          color: AppColors.mediumGray,
                                        ),
                                      ),
                                      minX: 0,
                                      maxX: (data.length - 1).toDouble(),
                                      minY:
                                          data
                                              .map((d) => d['height'] as double)
                                              .reduce((a, b) => a < b ? a : b) -
                                          5,
                                      maxY:
                                          data
                                              .map((d) => d['height'] as double)
                                              .reduce((a, b) => a > b ? a : b) +
                                          5,
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots:
                                              data.asMap().entries.map((entry) {
                                                return FlSpot(
                                                  entry.key.toDouble(),
                                                  entry.value['height'],
                                                );
                                              }).toList(),
                                          isCurved: true,
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.primaryPink.withOpacity(
                                                0.8,
                                              ),
                                              AppColors.primaryPink,
                                            ],
                                          ),
                                          barWidth: 3,
                                          isStrokeCapRound: true,
                                          dotData: FlDotData(
                                            show: true,
                                            getDotPainter: (
                                              spot,
                                              percent,
                                              barData,
                                              index,
                                            ) {
                                              return FlDotCirclePainter(
                                                radius: 4,
                                                color: AppColors.primaryPink,
                                                strokeWidth: 2,
                                                strokeColor: Colors.white,
                                              );
                                            },
                                          ),
                                          belowBarData: BarAreaData(
                                            show: true,
                                            gradient: LinearGradient(
                                              colors: [
                                                AppColors.primaryPink
                                                    .withOpacity(0.1),
                                                AppColors.primaryPink
                                                    .withOpacity(0.05),
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error:
                          (_, __) => const Center(
                            child: Text(
                              'Grafik yüklenirken hata oluştu',
                              style: TextStyle(color: AppColors.error),
                            ),
                          ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Weight Chart
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kilo Grafiği (Son 30 Gün)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: weightChartData.when(
                      data:
                          (data) =>
                              data.isEmpty
                                  ? const Center(
                                    child: Text(
                                      'Henüz kilo verisi bulunmuyor',
                                      style: TextStyle(
                                        color: AppColors.textMedium,
                                      ),
                                    ),
                                  )
                                  : LineChart(
                                    LineChartData(
                                      gridData: FlGridData(
                                        show: true,
                                        drawVerticalLine: false,
                                        horizontalInterval: 1,
                                        getDrawingHorizontalLine: (value) {
                                          return const FlLine(
                                            color: AppColors.mediumGray,
                                            strokeWidth: 1,
                                          );
                                        },
                                      ),
                                      titlesData: FlTitlesData(
                                        show: true,
                                        rightTitles: const AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: false,
                                          ),
                                        ),
                                        topTitles: const AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: false,
                                          ),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 30,
                                            interval: 1,
                                            getTitlesWidget: (
                                              double value,
                                              TitleMeta meta,
                                            ) {
                                              if (value.toInt() < data.length) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 8,
                                                      ),
                                                  child: Text(
                                                    data[value
                                                        .toInt()]['formattedDate'],
                                                    style: const TextStyle(
                                                      color:
                                                          AppColors.textMedium,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                );
                                              }
                                              return const Text('');
                                            },
                                          ),
                                        ),
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 40,
                                            interval: 1,
                                            getTitlesWidget: (
                                              double value,
                                              TitleMeta meta,
                                            ) {
                                              return Text(
                                                '${value.toStringAsFixed(1)}',
                                                style: const TextStyle(
                                                  color: AppColors.textMedium,
                                                  fontSize: 12,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      borderData: FlBorderData(
                                        show: true,
                                        border: Border.all(
                                          color: AppColors.mediumGray,
                                        ),
                                      ),
                                      minX: 0,
                                      maxX: (data.length - 1).toDouble(),
                                      minY:
                                          data
                                              .map((d) => d['weight'] as double)
                                              .reduce((a, b) => a < b ? a : b) -
                                          0.5,
                                      maxY:
                                          data
                                              .map((d) => d['weight'] as double)
                                              .reduce((a, b) => a > b ? a : b) +
                                          0.5,
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots:
                                              data.asMap().entries.map((entry) {
                                                return FlSpot(
                                                  entry.key.toDouble(),
                                                  entry.value['weight'],
                                                );
                                              }).toList(),
                                          isCurved: true,
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.pastelBlue.withOpacity(
                                                0.8,
                                              ),
                                              AppColors.pastelBlue,
                                            ],
                                          ),
                                          barWidth: 3,
                                          isStrokeCapRound: true,
                                          dotData: FlDotData(
                                            show: true,
                                            getDotPainter: (
                                              spot,
                                              percent,
                                              barData,
                                              index,
                                            ) {
                                              return FlDotCirclePainter(
                                                radius: 4,
                                                color: AppColors.pastelBlue,
                                                strokeWidth: 2,
                                                strokeColor: Colors.white,
                                              );
                                            },
                                          ),
                                          belowBarData: BarAreaData(
                                            show: true,
                                            gradient: LinearGradient(
                                              colors: [
                                                AppColors.pastelBlue
                                                    .withOpacity(0.1),
                                                AppColors.pastelBlue
                                                    .withOpacity(0.05),
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error:
                          (_, __) => const Center(
                            child: Text(
                              'Grafik yüklenirken hata oluştu',
                              style: TextStyle(color: AppColors.error),
                            ),
                          ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMedium,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCard(
    String title,
    String value,
    String unit,
    bool isPositive,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMedium,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: isPositive ? AppColors.success : AppColors.error,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${isPositive ? '+' : ''}$value $unit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isPositive ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
