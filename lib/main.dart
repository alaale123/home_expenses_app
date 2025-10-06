import 'package:flutter/material.dart';
import 'husband_page.dart';
import 'wife_page.dart';
import 'services_admin_page.dart';
import 'admin_dashboard_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  print('App started and Firebase initialized');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home Expenses App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String _selectedRole = 'husband';
  final TextEditingController _husbandEmailController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _smsController = TextEditingController();
  String? _error;
  bool _usePhone = false;
  String? _verificationId;

  // Example admin email list (replace with Firestore or custom claims for production)
  final List<String> _adminEmails = [
    'mutanaafis@gmail.com',
    'alaale123@gmail.com', // Add your admin email(s) here
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user == null) {
          // Login/Register screen with phone/email toggle
          return Scaffold(
            appBar: AppBar(title: Text('Login/Register')),
            body: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: Text('Email'),
                        selected: !_usePhone,
                        onSelected: (v) => setState(() => _usePhone = false),
                      ),
                      SizedBox(width: 12),
                      ChoiceChip(
                        label: Text('Phone'),
                        selected: _usePhone,
                        onSelected: (v) => setState(() => _usePhone = true),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  if (!_usePhone) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: Text('Husband'),
                        selected: _selectedRole == 'husband',
                        onSelected: (v) => setState(() => _selectedRole = 'husband'),
                      ),
                      SizedBox(width: 12),
                      ChoiceChip(
                        label: Text('Wife'),
                        selected: _selectedRole == 'wife',
                        onSelected: (v) => setState(() => _selectedRole = 'wife'),
                      ),
                    ],
                  ),
                  if (_selectedRole == 'wife') ...[
                    SizedBox(height: 16),
                    TextField(
                      controller: _husbandEmailController,
                      decoration: InputDecoration(labelText: "Husband's Email"),
                    ),
                  ],
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      child: Text('Login'),
                      onPressed: () async {
                        setState(() => _error = null);
                        try {
                          await FirebaseAuth.instance.signInWithEmailAndPassword(
                            email: _emailController.text.trim(),
                            password: _passwordController.text.trim(),
                          );
                        } catch (e) {
                          setState(() => _error = e.toString());
                        }
                      },
                    ),
                    SizedBox(height: 12),
                    ElevatedButton(
                      child: Text('Register'),
                      onPressed: () async {
                        setState(() => _error = null);
                        try {
                          final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                            email: _emailController.text.trim(),
                            password: _passwordController.text.trim(),
                          );
                          // Save user profile to Firestore
                          await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
                            'email': _emailController.text.trim(),
                            'role': _selectedRole,
                            'status': _selectedRole == 'wife' ? 'pending' : 'approved',
                            'createdAt': FieldValue.serverTimestamp(),
                            if (_selectedRole == 'wife') 'husbandEmail': _husbandEmailController.text.trim(),
                          });
                        } catch (e) {
                          setState(() => _error = e.toString());
                        }
                      },
                    ),
                  ] else ...[
                    TextField(
                      controller: _phoneController,
                      decoration: InputDecoration(labelText: 'Phone (+1234567890)'),
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      child: Text('Send Code'),
                      onPressed: () async {
                        setState(() => _error = null);
                        await FirebaseAuth.instance.verifyPhoneNumber(
                          phoneNumber: _phoneController.text.trim(),
                          verificationCompleted: (PhoneAuthCredential credential) async {
                            await FirebaseAuth.instance.signInWithCredential(credential);
                          },
                          verificationFailed: (e) {
                            setState(() => _error = e.toString());
                          },
                          codeSent: (verificationId, resendToken) {
                            setState(() => _verificationId = verificationId);
                          },
                          codeAutoRetrievalTimeout: (verificationId) {
                            setState(() => _verificationId = verificationId);
                          },
                        );
                      },
                    ),
                    if (_verificationId != null) ...[
                      SizedBox(height: 16),
                      TextField(
                        controller: _smsController,
                        decoration: InputDecoration(labelText: 'SMS Code'),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 12),
                      ElevatedButton(
                        child: Text('Verify & Login'),
                        onPressed: () async {
                          setState(() => _error = null);
                          try {
                            final credential = PhoneAuthProvider.credential(
                              verificationId: _verificationId!,
                              smsCode: _smsController.text.trim(),
                            );
                            await FirebaseAuth.instance.signInWithCredential(credential);
                          } catch (e) {
                            setState(() => _error = e.toString());
                          }
                        },
                      ),
                    ],
                  ],
                  if (_error != null) ...[
                    SizedBox(height: 16),
                    Text(_error!, style: TextStyle(color: Colors.red)),
                  ],
                ],
              ),
            ),
          );
        } else {
          // Fetch user profile from Firestore
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              final exists = snapshot.data!.exists;
              final data = snapshot.data!.data() as Map<String, dynamic>?;
              final role = data?['role'] ?? 'husband';
              final status = data?['status'] ?? 'approved';
              final isAdmin = _adminEmails.contains(user.email);
              if (role == 'wife' && (!exists || status != 'approved')) {
                return Scaffold(
                  appBar: AppBar(title: Text('Login Restricted')),
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock, size: 64, color: Colors.red),
                        SizedBox(height: 24),
                        Text(
                          !exists
                              ? 'Your account was declined and removed by your husband.'
                              : (status == 'pending'
                                  ? 'Your account is pending approval by your husband.'
                                  : 'Your account was declined by your husband.'),
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          child: Text('Logout'),
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Scaffold(
                appBar: AppBar(
                  title: Text(isAdmin ? 'Admin Dashboard' : 'Home Expenses App'),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.logout),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                      },
                    ),
                  ],
                ),
                body: isAdmin
                    ? AdminDashboardPage()
                    : role == 'wife'
                        ? WifePage(name: user.displayName ?? user.email ?? user.phoneNumber ?? 'Wife', userId: user.uid)
                        : HusbandPage(name: user.displayName ?? user.email ?? user.phoneNumber ?? 'User'),
              );
            },
          );
        }
      },
    );
  }
}
