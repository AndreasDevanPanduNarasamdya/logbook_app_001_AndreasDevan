import 'package:flutter/material.dart';

class OnBoardingView extends StatefulWidget {
  const OnBoardingView({super.key});
  @override
  State<OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView> {
  int step = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(40),
              child: Text("Halaman Onboarding"),
            ),
            Padding(padding: EdgeInsets.all(40), child: Text("$step")),
            Padding(
              padding: EdgeInsets.all(40),
              child: ElevatedButton(
                onPressed: () {
                  if (step < 3) {
                    setState(() {
                      step++;
                    });
                  } else {
                    print("Jump to Login!");
                  }
                },
                child: Text("Lanjut"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
