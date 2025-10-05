import 'package:flutter/material.dart';

class HourlyForecastItem extends StatelessWidget {
  final String time;
  final String iconUrl;
  final String temperature;

  const HourlyForecastItem({
    super.key,
    required this.time,
    required this.iconUrl,
    required this.temperature,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(right: 8),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Text(
              time,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Image.network(iconUrl, width: 50, height: 50),
            const SizedBox(height: 8),
            Text(temperature, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
