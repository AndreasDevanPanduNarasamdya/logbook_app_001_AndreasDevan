import 'package:flutter/material.dart';
import '../auth/login_view.dart';

class OnBoardingView extends StatefulWidget {
  const OnBoardingView({super.key});
  @override
  State<OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView> {
  int step = 1;

  final List<String> onboardingImages = [
    'lib/assets/Bottom G.png',
    'lib/assets/Screenshot (668).png',
    'lib/assets/Screenshot 2026-02-05 060146.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(40),
              child: Text("Halaman Onboarding"),
            ),
            Padding(
              padding: const EdgeInsets.all(40),
              child: Image.asset(
                onboardingImages[step - 1],
                height: 200,
                fit: BoxFit.contain,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(40),
              child: ElevatedButton(
                onPressed: () {
                  if (step < 3) {
                    setState(() {
                      step++;
                    });
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginView(),
                      ),
                    );
                  }
                },
                child: const Text("Lanjut"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
