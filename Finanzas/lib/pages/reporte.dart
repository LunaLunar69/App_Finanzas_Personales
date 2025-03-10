import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportePage extends StatelessWidget {
  const ReportePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Text(
              'Hola Usuari@',
              style: TextStyle(fontSize: 28, color: Colors.green),
            ),
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('SALDO INICIAL:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Text('200.00', style: TextStyle(color: Colors.black54)),
                SizedBox(width: 16),
                Text('SALDO FINAL:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.green)),
                SizedBox(width: 8),
                Text('566.50', style: TextStyle(color: Colors.black54)),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children:  [
                  Text('oct-2024',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('183%',
                      style: TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold)),
                  Text('Aumento del ahorro total',
                      style: TextStyle(fontSize: 14, color: Colors.black54)),
                  SizedBox(height: 8),
                  Text('\$366.50',
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('Ahorrados este período',
                      style: TextStyle(fontSize: 14, color: Colors.black54)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: BarChart(
                BarChartData(
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [
                      BarChartRodData(fromY: 0, toY: 200, color: Colors.blue, width: 16)
                    ]),
                    BarChartGroupData(x: 1, barRods: [
                      BarChartRodData(fromY: 0, toY: 566.5, color: Colors.green, width: 16)
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}