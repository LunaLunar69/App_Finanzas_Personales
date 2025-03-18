import 'package:flutter/material.dart'; 
import 'package:fl_chart/fl_chart.dart';

class ReportePage extends StatelessWidget {
  const ReportePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Text(
              'Bienvenid@ de vuelta',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tu actividad reciente se encuentra a continuación.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          const Text('Saldo Inicial',
                              style: TextStyle(fontSize: 14, color: Colors.black54)),
                          const SizedBox(height: 4),
                          Radio(value: true, groupValue: true, onChanged: (value) {}),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Column(
                        children: [
                          const Text('Saldo Final',
                              style: TextStyle(fontSize: 14, color: Colors.black54)),
                          const SizedBox(height: 4),
                          Radio(value: false, groupValue: true, onChanged: (value) {}),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: [
                          BarChartGroupData(x: 0, barRods: [
                            BarChartRodData(fromY: 0, toY: 200, color: const Color.fromARGB(255, 33, 132, 212), width: 20)
                          ]),
                          BarChartGroupData(x: 1, barRods: [
                            BarChartRodData(fromY: 0, toY: 566.5, color: const Color.fromARGB(255, 1, 50, 105), width: 20)
                          ]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Últimos 30 días', style: TextStyle(fontSize: 14, color: Colors.black54)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reporte',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Un resumen de tus Ahorros',
                      style: TextStyle(fontSize: 14, color: Colors.black54)),
                  SizedBox(height: 12),
                  Center(
                    child: Column(
                      children: [
                        Text('183%',
                            style: TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold)),
                        Text('Aumento del Ahorro',
                            style: TextStyle(fontSize: 14, color: Colors.black54)),
                        SizedBox(height: 8),
                        Text('\$683.50',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        Text('Ahorrados este período',
                            style: TextStyle(fontSize: 14, color: Colors.black54)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
