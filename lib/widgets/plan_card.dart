import 'package:flutter/material.dart';

class PlanCard extends StatelessWidget {
  final Map<String, double> budgetInputs;
  final ValueChanged<Map<String, double>> onPlanBudget;
  const PlanCard({
    required this.budgetInputs,
    required this.onPlanBudget,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ...UI for plan card...
    return Container(
      // ...existing decoration and layout...
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.edit, color: Colors.lightBlue, size: 32),
              SizedBox(width: 12),
              Text(
                'Plan Monthly Budget',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          GestureDetector(
            onTap: () async {
              Map<String, double> tempInputs = Map.from(budgetInputs);
              await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Plan Budget'),
                    content: SizedBox(
                      width: 300,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var key in tempInputs.keys)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: TextField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(labelText: key),
                                onChanged: (value) {
                                  tempInputs[key] = double.tryParse(value) ?? tempInputs[key]!;
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          onPlanBudget(tempInputs);
                          Navigator.pop(context);
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  );
                },
              );
            },
            child: Text(
              'Tap to add your monthly budget categories and amounts.',
              style: TextStyle(fontSize: 16, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 16),
          Column(
            children: budgetInputs.entries
                .map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: GestureDetector(
                        onTap: () async {
                          double? newValue = await showDialog<double>(
                            context: context,
                            builder: (context) {
                              double tempValue = e.value;
                              return AlertDialog(
                                title: Text('Edit ${e.key}'),
                                content: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(hintText: 'Enter amount for ${e.key}'),
                                  onChanged: (value) {
                                    tempValue = double.tryParse(value) ?? e.value;
                                  },
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context, tempValue),
                                    child: const Text('Save'),
                                  ),
                                ],
                              );
                            },
                          );
                          if (newValue != null) {
                            final updatedInputs = Map<String, double>.from(budgetInputs);
                            updatedInputs[e.key] = newValue;
                            onPlanBudget(updatedInputs);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: e.value > 0 ? Colors.lightBlueAccent.withOpacity(0.2) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            '${e.key}: ₩${e.value.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 18,
                              color: e.value > 0 ? Colors.blueAccent : Colors.blueGrey,
                              fontWeight: e.value > 0 ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
