import 'package:flutter/material.dart';
import '../components/actionsheet.dart';
import '../components/button.dart';
import '../components/textfield.dart';

extension AxeThemeColors on BuildContext {
  ThemeData get theme => Theme.of(this);

  Color get primary => Color.alphaBlend(Color.fromARGB(209, 209, 214, 207), Color.fromARGB(0, 88, 44, 106));

  Color get bg1 => Color.fromARGB(255, 23, 5, 44);
  Color get bg2 => Color.fromARGB(255, 117, 106, 140);
  Color get bg3 => Color.fromRGBO(62, 38, 44, 1);

  Color get h1 => Color.fromARGB(255, 251, 251, 251);
  Color get h2 => Color.fromARGB(255, 249, 249, 249);
  Color get h3 => Color.fromARGB(255, 212, 212, 212);

  Color get red => theme.colorScheme.error;
  BoxDecoration get backgroundDecoration => const BoxDecoration(
          gradient: LinearGradient(colors: [
        Color.fromRGBO(0, 0, 0, 1),
        Color.fromRGBO(52, 28, 72, 1),
        Color.fromRGBO(62, 38, 44, 1),
      ], begin: Alignment.topCenter, end: AlignmentDirectional.bottomEnd));

  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;
  TextStyle get style => TextStyle(color: h1, fontSize: 12);
}

extension ContextNavigator on BuildContext {
  NavigatorState get navigator => Navigator.of(this);
  Future<T?> pushPage<T extends Object?>(Widget page) => navigator.push<T>(
        MaterialPageRoute(builder: (_) => page),
      );

  Future<T?> replacePage<T extends Object?, TO extends Object?>(Widget page) => navigator.pushReplacement<T, TO>(
        MaterialPageRoute(builder: (_) => page),
      );

  Future<T?> axeActionSheet<T>({
    required String title,
    String? subtitle,
    Widget? child,
    List<Widget>? children,
    String cancelButtonTitle = 'Cancel',
    AxButtonColor cancelButtonColorStyle = AxButtonColor.normal,
    VoidCallback? onCancel,
    VoidCallback? onDone,
    bool hidePrevKeyboard = false,
    bool useRootNavigator = true,
    AxButtonColor doneButtonColorStyle = AxButtonColor.primary,
  }) {
    if (hidePrevKeyboard) hideKeyboard();

    return showModalBottomSheet(
      context: this,
      builder: (_) => AxActionSheet(
          title: title,
          subtitle: subtitle,
          cancelButtonColorStyle: cancelButtonColorStyle,
          cancelButtonTitle: cancelButtonTitle,
          onCancel: onCancel,
          onDone: onDone,
          children: children,
          child: child,
          doneButtonColorStyle: doneButtonColorStyle),
      backgroundColor: Color.fromARGB(0, 122, 53, 53),
      isScrollControlled: true,
      useRootNavigator: useRootNavigator,
    );
  }
}

extension Routing on BuildContext {
  void Pop<T>({T? result, bool rootNavigator = true, int count = 1}) {
    for (var i = 0; i < count; i++) {
      Navigator.of(this, rootNavigator: rootNavigator).pop<T>(result);
    }
  }
}
