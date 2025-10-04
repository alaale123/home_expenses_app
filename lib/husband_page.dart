import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'widgets/plan_card.dart';
import 'widgets/pay_card.dart';
import 'widgets/reports_card.dart';
import 'widgets/home_services_card.dart';
import 'widgets/image_placeholder.dart';
import 'utils/rent_storage.dart';
import 'utils/wallet_storage.dart';
import 'utils/company_storage.dart';

class HusbandPage extends StatelessWidget {
  final String name;
  const HusbandPage({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return _HusbandPageContent(name: name);
  }
}

class _HusbandPageContent extends StatefulWidget {
  final String name;
  const _HusbandPageContent({required this.name});

  @override
  State<_HusbandPageContent> createState() => _HusbandPageContentState();
}

class _HusbandPageContentState extends State<_HusbandPageContent> {
  // Firestore streams
  Stream<QuerySnapshot<Map<String, dynamic>>> get _testimonialsStream =>
      FirebaseFirestore.instance.collection('testimonials').snapshots();
  Stream<QuerySnapshot<Map<String, dynamic>>> get _servicesStream =>
      FirebaseFirestore.instance.collection('services').snapshots();

  final Map<String, TextEditingController> _companyControllers = {};
  Map<String, String> _companyNumbers = {};
  List<String> _defaultCategories = [
    'Home rent', 'Electric', 'Water', 'Internet', 'Bill', 'Others'
  ];
  List<String> _customCategories = [];
  double _recurringWallet = 0;
  double _recurringRent = 0;
  double _walletAmount = 0;
  int _selectedIndex = 0;
  Map<String, double> _budgetInputs = {
    'Home rent': 0,
    'Electric': 0,
    'Water': 0,
    'Internet': 0,
    'Bill': 0,
    'Others': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadRecurringRent();
    _loadRecurringWallet();
    _loadCompanyNumbers();
  }

  Future<void> _loadCompanyNumbers() async {
    final map = await CompanyStorage.loadCompanyNumbers();
    setState(() {
      _companyNumbers = map;
    });
  }

  Future<void> _loadRecurringWallet() async {
    final amount = await WalletStorage.loadWallet();
    setState(() {
      _recurringWallet = amount;
      _walletAmount = amount;
    });
  }

  Future<void> _loadRecurringRent() async {
    final rent = await RentStorage.loadRent();
    setState(() {
      _recurringRent = rent;
      _budgetInputs['Home rent'] = rent;
    });
  }

  void _showManageCompanyNumbersDialog() async {
    for (var cat in [..._defaultCategories, ..._customCategories]) {
      _companyControllers.putIfAbsent(cat, () => TextEditingController(text: _companyNumbers[cat] ?? ''));
    }
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Manage Company Numbers'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var cat in [..._defaultCategories, ..._customCategories])
                      Row(
                        children: [
                          Expanded(child: Text(cat)),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _companyControllers[cat],
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(hintText: 'Company #'),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    setState(() {
                      for (var cat in [..._defaultCategories, ..._customCategories]) {
                        _companyNumbers[cat] = _companyControllers[cat]?.text ?? '';
                      }
                    });
                    await CompanyStorage.saveCompanyNumbers(_companyNumbers);
                    await _loadCompanyNumbers();
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showManageCategoriesDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        String newCategory = '';
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Manage Categories'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ..._customCategories.map((cat) => ListTile(
                        title: Text(cat),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _customCategories.remove(cat);
                              _budgetInputs.remove(cat);
                            });
                          },
                        ),
                        onTap: () async {
                          double? newAmount = await showDialog<double>(
                            context: context,
                            builder: (context) {
                              double tempAmount = _budgetInputs[cat] ?? 0;
                              return AlertDialog(
                                title: Text('Edit $cat Amount'),
                                content: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(hintText: 'Enter amount'),
                                  onChanged: (value) {
                                    tempAmount = double.tryParse(value) ?? tempAmount;
                                  },
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, null),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, tempAmount),
                                    child: const Text('Save'),
                                  ),
                                ],
                              );
                            },
                          );
                          if (newAmount != null) {
                            setState(() {
                              _budgetInputs[cat] = newAmount;
                            });
                          }
                        },
                      )),
                  TextField(
                    decoration: InputDecoration(hintText: 'Add new category'),
                    onChanged: (value) {
                      newCategory = value;
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
                TextButton(
                  onPressed: () {
                    if (newCategory.isNotEmpty && !_customCategories.contains(newCategory) && !_defaultCategories.contains(newCategory)) {
                      setState(() {
                        _customCategories.add(newCategory);
                        _budgetInputs[newCategory] = 0;
                      });
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showRecurringRentDialog() async {
    double tempRent = _recurringRent;
    double? newRent = await showDialog<double>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Set Recurring Rent'),
              content: TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Enter rent amount'),
                onChanged: (value) {
                  tempRent = double.tryParse(value) ?? _recurringRent;
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, tempRent),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
    if (newRent != null) {
      setState(() {
        _recurringRent = newRent;
        _budgetInputs['Home rent'] = newRent;
      });
      await RentStorage.saveRent(newRent);
    }
  }

  void _showRecurringWalletDialog() async {
    double tempWallet = _recurringWallet;
    double? newWallet = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Recurring Monthly Wallet'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Enter monthly wallet amount'),
            onChanged: (value) {
              tempWallet = double.tryParse(value) ?? _recurringWallet;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, tempWallet),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (newWallet != null) {
      setState(() {
        _recurringWallet = newWallet;
        _walletAmount = newWallet;
      });
      await WalletStorage.saveWallet(newWallet);
    }
  }

  Widget _buildCardContent() {
    switch (_selectedIndex) {
      case 0:
        return PlanCard(
          budgetInputs: _budgetInputs,
          onPlanBudget: (inputs) {
            setState(() {
              _budgetInputs = inputs;
            });
          },
        );
      case 1:
        return PayCard(
          walletAmount: _walletAmount,
          budgetInputs: _budgetInputs,
          companyNumbers: _companyNumbers,
          onPayExpense: (key, value) {
            setState(() {
              if (_walletAmount >= value) {
                _walletAmount -= value;
                _budgetInputs[key] = 0;
              }
            });
          },
          onUpdateCompanyNumber: (key, value) {
            setState(() {
              _companyNumbers[key] = value;
            });
          },
        );
      case 2:
        return ReportsCard(budgetInputs: _budgetInputs);
      case 3:
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _servicesStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            final docs = snapshot.data?.docs ?? [];
            final services = docs.map((doc) {
              final data = doc.data();
              return HomeService(
                name: data['name'] ?? '',
                imagePath: data['imagePath'] ?? '',
                description: data['description'] ?? '',
              );
            }).toList();
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: HomeServicesCard(
                      services: services,
                      onServiceTap: (service) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(service.name),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: service.imagePath.isNotEmpty
                                      ? Builder(
                                          builder: (context) {
                                            try {
                                              return Image.file(
                                                File(service.imagePath),
                                                width: 120,
                                                height: 120,
                                                fit: BoxFit.cover,
                                              );
                                            } catch (e) {
                                              return const ImagePlaceholder(width: 120, height: 120);
                                            }
                                          },
                                        )
                                      : const ImagePlaceholder(width: 120, height: 120),
                                ),
                                SizedBox(height: 16),
                                Text(service.description, style: TextStyle(fontSize: 16)),
                                SizedBox(height: 12),
                                Text('Contact details and booking for ${service.name} will be available soon.'),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  // ...existing code...
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Testimonials', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                        SizedBox(height: 10),
                        ElevatedButton.icon(
                          icon: Icon(Icons.add_comment),
                          label: Text('Add Testimonial'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                          onPressed: () async {
                            String author = '';
                            String text = '';
                            await showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Add Testimonial'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        decoration: InputDecoration(labelText: 'Your Name'),
                                        onChanged: (v) => author = v,
                                      ),
                                      TextField(
                                        decoration: InputDecoration(labelText: 'Your Feedback'),
                                        onChanged: (v) => text = v,
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        if (author.isNotEmpty && text.isNotEmpty) {
                                          await FirebaseFirestore.instance.collection('testimonials').add({
                                            'author': author,
                                            'text': text,
                                          });
                                          if (mounted) Navigator.pop(context);
                                        }
                                      },
                                      child: Text('Submit'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          height: 190,
                          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: _testimonialsStream,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              }
                              final docs = snapshot.data?.docs ?? [];
                              if (docs.isEmpty) {
                                return Center(child: Text('No testimonials yet.'));
                              }
                              return ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: docs.length,
                                separatorBuilder: (context, i) => SizedBox(width: 16),
                                itemBuilder: (context, i) {
                                  final t = docs[i].data();
                                  return Card(
                                    elevation: 6,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    color: Colors.white,
                                    clipBehavior: Clip.antiAlias,
                                    child: Container(
                                      width: 280,
                                      padding: EdgeInsets.all(18),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor: Colors.deepPurple.shade100,
                                                  child: Icon(Icons.person, color: Colors.deepPurple),
                                                ),
                                                SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    t['author'] ?? '',
                                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepPurple),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 14),
                                            Text(
                                              '"${t['text']}"',
                                              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.black87),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        title: Row(
          children: [
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Profile'),
                    content: Text('Logged in as ${widget.name}'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.deepPurple),
                  ),
                  SizedBox(width: 12),
                  Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.account_balance_wallet, color: Colors.deepPurple),
                  SizedBox(width: 6),
                  Text(
                    '₩${(_walletAmount - _budgetInputs.values.reduce((a, b) => a + b)).toStringAsFixed(0)}',
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            IconButton(
              icon: Icon(Icons.settings, color: Colors.lightBlue),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: Icon(Icons.account_balance_wallet, color: Colors.lightBlue),
                            title: Text('Set Recurring Monthly Wallet'),
                            onTap: () {
                              Navigator.pop(context);
                              _showRecurringWalletDialog();
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.home, color: Colors.lightBlue),
                            title: Text('Set Recurring Rent'),
                            onTap: () {
                              Navigator.pop(context);
                              _showRecurringRentDialog();
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.category, color: Colors.lightBlue),
                            title: Text('Manage Categories'),
                            onTap: () {
                              Navigator.pop(context);
                              _showManageCategoriesDialog();
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.business, color: Colors.lightBlue),
                            title: Text('Manage Company Numbers'),
                            onTap: () {
                              Navigator.pop(context);
                              _showManageCompanyNumbersDialog();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: Center(child: _buildCardContent()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Plan'),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Pay'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.home_repair_service), label: 'Home Services'),
        ],
      ),
    );
  }
}
