import 'package:flutter/material.dart';

class CustomLoading extends StatelessWidget {
  const CustomLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        const Center(child: CircularProgressIndicator()),
        const SizedBox(height: 15),
      ],
    );
  }
}