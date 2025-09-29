import 'package:flutter/material.dart';

class ReportsCard extends StatelessWidget {
  const ReportsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ...UI for reports card...
    return Container(
      // ...existing decoration and layout...
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart, color: Colors.white, size: 32),
              SizedBox(width: 12),
              Text(
                'Reports',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Text(
            'View your monthly expense and budget reports here.',
            style: TextStyle(fontSize: 16, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
