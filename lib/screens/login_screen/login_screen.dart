import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(
            16.0,
          ),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.lightBlue.withOpacity(
              0.1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.purpleAccent.withOpacity(
                  0.1,
                ),
                blurRadius: 10.0,
                spreadRadius: 50.0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    30.0,
                  ),
                  child: Image.asset(
                    'assets/images/roommates.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Find Your Perfect\nRoommate Here',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(
                      height: 16.0,
                    ),
                    Text(
                      'Explore all the most exciting job roles\nbased on your interest And study major',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/google.png',
                        width: 30.0,
                        height: 30.0,
                      ),
                      const SizedBox(
                        width: 6.0,
                      ),
                      Text(
                        'Sign in with Google',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
