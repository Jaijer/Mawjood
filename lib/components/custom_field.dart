import 'package:flutter/material.dart';
import '../components/spaces.dart';

import '../components/theme.dart';

class CustomField extends StatelessWidget {
  const CustomField({super.key, required this.title, required this.onTap, this.value});
  final String title;
  final Function() onTap;
  final String? value;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AxeSpace.s16, vertical: AxeSpace.s8),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Color.fromARGB(255, 12, 11, 11),
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            Text(
              value ?? '',
              style: TextStyle(
                color: Color.fromARGB(255, 12, 11, 11),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
