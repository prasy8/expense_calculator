import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ExpenseChart extends StatelessWidget {
  final Map<String, double> categorySummary;

  const ExpenseChart({
    super.key,
    required this.categorySummary,
  });

  @override
  Widget build(BuildContext context) {
    if (categorySummary.isEmpty) {
      return const SizedBox(
        height: 250,
        child: Center(
          child: Text(
            'No expense data available.',
          ),
        ),
      );
    }

    final entries = categorySummary.entries.toList();

    final total = entries.fold<double>(
      0,
      (sum, item) => sum + item.value,
    );

    final colors = [
      Colors.blue,
      Colors.red,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    return SizedBox(
      height: 320,

      child: Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 50,

                sectionsSpace: 2,

                sections:
                    List.generate(
                  entries.length,
                  (index) {
                    final entry =
                        entries[index];

                    final percentage =
                        total > 0
                            ? (entry.value / total) * 100
                            : 0;

                    return PieChartSectionData(
                      value: entry.value,

                      title:
                          '${percentage.toStringAsFixed(0)}%',

                      radius: 80,

                      color: colors[
                        index % colors.length
                      ],

                      titleStyle:
                          const TextStyle(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          Wrap(
            spacing: 12,
            runSpacing: 8,

            children:
                List.generate(
              entries.length,
              (index) {
                return Row(
                  mainAxisSize:
                      MainAxisSize.min,

                  children: [
                    Container(
                      width: 10,
                      height: 10,

                      decoration: BoxDecoration(
                        color: colors[
                          index % colors.length
                        ],

                        shape: BoxShape.circle,
                      ),
                    ),

                    const SizedBox(width: 5),

                    Text(
                      entries[index].key,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}