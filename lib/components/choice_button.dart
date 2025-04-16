import 'package:flutter/material.dart';
import '../components/theme.dart';

class ChoiceButton extends StatelessWidget {
  const ChoiceButton({super.key, required this.title, this.onTap});
  final String title;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 50,
          child: Center(
              child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.h1,
              fontWeight: FontWeight.bold,
            ),
          )),
          decoration: BoxDecoration(
              color: context.bg2.withOpacity(0.1),
              border: Border.all(color: context.bg2, width: 2),
              borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
