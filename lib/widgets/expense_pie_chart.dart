import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ExpensePieChart extends StatelessWidget {
  final Map<String, double> dataMap;
  const ExpensePieChart({required this.dataMap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sections = <PieChartSectionData>[];
    final total = dataMap.values.fold(0.0, (a, b) => a + b);
    dataMap.forEach((category, amount) {
      final percent = total == 0 ? 0 : (amount / total) * 100;
      sections.add(PieChartSectionData(
        value: amount,
        title: '${category}\n${percent.toStringAsFixed(1)}%',
        color: Colors.primaries[dataMap.keys.toList().indexOf(category) % Colors.primaries.length],
        radius: 60,
        titleStyle: TextStyle(fontSize: 12, color: Colors.white),
      ));
    });
    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 32,
        sectionsSpace: 2,
      ),
    );
  }
}
