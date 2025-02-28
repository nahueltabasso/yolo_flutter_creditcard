import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {

  final double width;
  final String label;
  final VoidCallback? onPressed;

  const CustomButton({
    super.key, 
    required this.width, 
    required this.label, 
    this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
          // onPressed: () => context.read<YoloProcessBloc>().add(InitPicker(ImageSource.camera)),
          onPressed: onPressed,
          child: Text(label,
              style: const TextStyle(color: Colors.white))),
    );
  }
}