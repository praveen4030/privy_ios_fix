import 'package:flutter/material.dart';
import 'package:privy_ios_fix/utils/privy_utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PrivyUtils privyUtils = PrivyUtils.sharedInstance;
  TextEditingController emailController = TextEditingController();
  TextEditingController otpController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    privyUtils.initializePrivy();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: <Widget>[
              Text("Initialize Privy: ${privyUtils.isReady}"),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await privyUtils.initializePrivy();
                  setState(() {});
                },
                child: Text("Initialize"),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(hintText: "Email"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  privyUtils.privyLoginUtils.emailVal = emailController.text;
                  FocusScope.of(context).unfocus();
                  await privyUtils.privyLoginUtils.loginWithEmail();
                  setState(() {});
                },
                child: Text("Login"),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: otpController,
                decoration: InputDecoration(hintText: "OTP"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  privyUtils.privyLoginUtils.emailVal = emailController.text;
                  privyUtils.privyLoginUtils.otpVal = otpController.text;
                  FocusScope.of(context).unfocus();
                  await privyUtils.privyLoginUtils.verifyOtp();
                  setState(() {});
                },
                child: Text("Verify"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  privyUtils.isCreatingEvmWallet = true;
                  setState(() {});
                  await privyUtils.createEvmWallet();
                  setState(() {});
                },
                child:
                    privyUtils.isCreatingEvmWallet
                        ? CircularProgressIndicator()
                        : Text("Create EVM Wallet"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  privyUtils.isCreatingSolanaWallet = true;
                  setState(() {});
                  await privyUtils.createSolanaWallet();
                  setState(() {});
                },
                child:
                    privyUtils.isCreatingSolanaWallet
                        ? CircularProgressIndicator()
                        : Text("Create Solana Wallet"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await privyUtils.logoutUser();
                  setState(() {});
                },
                child: Text("Log out"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
