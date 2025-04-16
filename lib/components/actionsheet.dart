import 'dart:math';

import 'package:flutter/material.dart';
import '../components/spaces.dart';
import '../components/textfield.dart';
import '../components/theme.dart';

import 'button.dart';

class AxSheetHeader extends StatelessWidget {
  const AxSheetHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: context.style.copyWith(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500)),
        if (subtitle != null) ...[
          kVSpace4,
          Text(subtitle!, style: context.style),
        ]
      ],
    );
  }
}

class AxActionSheet extends StatelessWidget {
  const AxActionSheet({
    super.key,
    required this.title,
    this.subtitle,
    this.child,
    this.children,
    this.cancelButtonColorStyle = AxButtonColor.normal,
    this.cancelButtonTitle = 'Cancel',
    this.doneButtonTitle = 'Done',
    this.onCancel,
    this.onDone,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.doneButtonColorStyle = AxButtonColor.primary,
  });

  final String title;
  final String? subtitle;
  final Widget? child;
  final List<Widget>? children;
  final AxButtonColor cancelButtonColorStyle;
  final String cancelButtonTitle;
  final String doneButtonTitle;
  final VoidCallback? onCancel;
  final VoidCallback? onDone;
  final CrossAxisAlignment crossAxisAlignment;
  final AxButtonColor doneButtonColorStyle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: hideKeyboard,
      child: _FloatingModal(
        child: Column(
          crossAxisAlignment: crossAxisAlignment,
          mainAxisSize: MainAxisSize.min,
          children: [
            AxSheetHeader(title: title, subtitle: subtitle),
            kVSpace16,
            if (child != null) child!,
            if (children != null) ...children!,
            kVSpace16,
            Row(
              children: [
                if (onCancel != null)
                  AxButton(
                    title: cancelButtonTitle,
                    onTap: onCancel,
                    color: cancelButtonColorStyle,
                  ),
                if (onCancel != null && onDone != null) kHSpace12,
                if (onDone != null) AxButton(title: doneButtonTitle, onTap: onDone, color: doneButtonColorStyle),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _FloatingModal extends StatelessWidget {
  final Widget child;

  const _FloatingModal({required this.child});

  // double _getContainerHeight(BuildContext context) {
  //   MediaQueryData mediaQuery = MediaQuery.of(context);
  //   double safeAreaHeight = mediaQuery.padding.vertical;
  //   return mediaQuery.size.height - (AxeSpace.s16 * 2) - (safeAreaHeight * 2);
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.only(bottom: AxeSpace.s16),

      /// Outer container
      child: Container(
        margin: const EdgeInsets.only(left: AxeSpace.s16, right: AxeSpace.s16, top: 3 * AxeSpace.s16),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),

        /// Inner content
        child: Container(
          padding: const EdgeInsets.all(AxeSpace.s24).copyWith(
            bottom: max(AxeSpace.s24, context.mediaQuery.viewInsets.bottom),
          ),
          child: child,
        ),
      ),
    );
  }
}
