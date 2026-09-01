import 'package:flutter/material.dart';

class CategorySummary extends StatelessWidget {
  final Map<String, double> categorySummary;

  const CategorySummary({
    super.key,
    required this.categorySummary,
  });

  @override
  Widget build(BuildContext context) {
    if (categorySummary.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'No expense data available.',
          ),
        ),
      );
    }

    final double maxAmount =
        categorySummary.values.reduce(
      (a, b) => a > b ? a : b,
    );

    return Column(
      children: categorySummary.entries.map(
        (entry) {
          final progress =
              maxAmount > 0
                  ? entry.value / maxAmount
                  : 0.0;

          return Padding(
            padding: const EdgeInsets.only(
              bottom: 18,
            ),

            child: Column(
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    Text(
                      '₹${entry.value.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ],
            ),
          );
        },
      ).toList(),
    );
  }
}