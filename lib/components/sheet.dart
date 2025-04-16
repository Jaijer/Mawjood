import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../components/button.dart';
import '../components/spaces.dart';
import 'package:flutter/cupertino.dart';

import '../components/textfield.dart';
import '../components/theme.dart';

class EditSheet extends StatelessWidget {
  const EditSheet({
    super.key,
    this.title,
    this.subtitle,
    this.cancelTitle = 'Cancel',
    this.onCancel,
    this.onDone,
    this.doneTitle = 'Done',
    this.separated = true,
    this.spacing = AxeSpace.s24,
    this.children = const [],
    this.padding = defaultPadding,
    this.showDragGrip = true,
    this.builder,
    this.shrinkWrap = false,
    this.child,
  });

  /// AppBar
  final String? title;
  final String? subtitle;
  final String cancelTitle;
  final VoidCallback? onCancel;
  final String doneTitle;
  final VoidCallback? onDone;

  final bool shrinkWrap;

  final List<Widget> children;
  final Widget? child;

  final bool separated;
  final double spacing;
  final EdgeInsets padding;
  final bool showDragGrip;
  final Widget Function(BuildContext context)? builder;

  static const EdgeInsets defaultPadding = EdgeInsets.all(AxeSpace.s24);

  @override
  Widget build(BuildContext context) {
    Widget containChildren(List<Widget> children) {
      return (separated)
          ? ListView.separated(
              padding: padding.copyWith(bottom: 64),
              itemCount: children.length + 1,
              shrinkWrap: shrinkWrap,
              itemBuilder: (_, i) => i == 0
                  ? AxeSheetScreenNavbar(
                      showDragGrip: showDragGrip,
                      title: title,
                      subtitle: subtitle,
                      cancelTitle: cancelTitle,
                      onCancel: onCancel,
                      doneTitle: doneTitle,
                      onDone: onDone,
                      hPadding: 0,
                    )
                  : children[i - 1],
              separatorBuilder: (_, i) => SizedBox(height: spacing),
            )
          : SingleChildScrollView(
              padding: padding.copyWith(bottom: 64),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  AxeSheetScreenNavbar(
                    showDragGrip: showDragGrip,
                    title: title,
                    subtitle: subtitle,
                    cancelTitle: cancelTitle,
                    onCancel: onCancel,
                    doneTitle: doneTitle,
                    onDone: onDone ?? context.Pop,
                    hPadding: 0,
                  ),
                  ...children,
                ],
              ),
            );
    }

    Widget containedChildren() => Container(decoration: context.backgroundDecoration, child: containChildren(children));

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: hideKeyboard,
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: child == null
            ? Material(child: builder?.call(context) ?? containedChildren())
            : Scaffold(
                backgroundColor: context.bg1,
                body: SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: padding.copyWith(bottom: 12),
                        child: AxeSheetScreenNavbar(
                          showDragGrip: showDragGrip,
                          title: title,
                          subtitle: subtitle,
                          cancelTitle: cancelTitle,
                          onCancel: onCancel,
                          doneTitle: doneTitle,
                          onDone: onDone ?? context.pop,
                          hPadding: 0,
                        ),
                      ),
                      child!,
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class DraggableSheetTBR extends StatelessWidget {
  const DraggableSheetTBR(
      {super.key,
      this.title,
      this.subtitle,
      this.separated = true,
      this.spacing = AxeSpace.s24,
      this.children = const [],
      this.padding = defaultPadding,
      this.showDragGrip = true,
      this.isFilterEditor = false,
      this.onCancel,
      this.onSave,
      this.fontSize,
      required this.initialChildSize,
      required this.minChildSize});

  /// AppBar
  final String? title;
  final String? subtitle;
  final VoidCallback? onCancel;
  final VoidCallback? onSave;
  final List<Widget> children;
  final bool separated;
  final bool isFilterEditor;
  final double spacing;
  final EdgeInsets padding;
  final bool showDragGrip;
  final double initialChildSize;
  final double minChildSize;
  final double? fontSize;

  static const EdgeInsets defaultPadding = EdgeInsets.all(AxeSpace.s24);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      // maxChildSize: 0.95,
      minChildSize: minChildSize,
      initialChildSize: initialChildSize,
      builder: (context, scrollController) {
        return Stack(
          alignment: Alignment.bottomCenter,
          //   fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: hideKeyboard,
              child: SafeArea(
                child: Padding(
                  padding: MediaQuery.of(context).viewInsets.add(defaultPadding),
                  child: CustomScrollView(
                    clipBehavior: Clip.none,
                    controller: scrollController,
                    slivers: [
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: AxeSheetScreenNavbar(
                              showDragGrip: true,
                              title: title,
                              hPadding: 0,
                            ),
                          ),
                          childCount: 1,
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) => Padding(
                            padding: EdgeInsets.only(bottom: spacing),
                            child: children[i],
                          ),
                          childCount: children.length,
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) => kVSpace96,
                          childCount: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (onCancel != null && onSave != null)
              AxeSheetActions(onCancel: onCancel!, onSave: onSave!, isFilterEditor: isFilterEditor),
          ],
        );
      },
    );
  }
}

class AxeSheetActions extends StatelessWidget {
  const AxeSheetActions({
    super.key,
    required this.onCancel,
    required this.onSave,
    this.isFilterEditor = false,
  });

  final VoidCallback onCancel;
  final VoidCallback onSave;
  final bool isFilterEditor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.bg2,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
        // boxShadow: kBoxShadow,
      ),
      padding: EdgeInsets.fromLTRB(
        24 + context.mediaQuery.padding.left,
        24 + context.mediaQuery.padding.top,
        24 + context.mediaQuery.padding.right,
        24 + context.mediaQuery.padding.bottom,
      ),
      child: Row(
        children: [
          AxButton(
            expanded: isFilterEditor,
            title: 'Cancel',
            color: isFilterEditor ? AxButtonColor.delete : AxButtonColor.h2,
            onTap: onCancel,
          ),
          kHSpace64,
          AxButton(
            expanded: true,
            title: 'Save',
            color: AxButtonColor.primary,
            onTap: onSave,
          ),
        ],
      ),
    );
  }
}

class AxPushPage extends StatelessWidget {
  const AxPushPage({
    super.key,
    this.title,
    this.subtitle,
    this.separated = true,
    this.spacing = AxeSpace.s24,
    this.children = const [],
    this.padding = defaultPadding,
    this.showDragGrip = true,
    this.onCancel,
    this.onSave,
    required this.initialChildSize,
    required this.minChildSize,
  });

  /// AppBar
  final String? title;
  final String? subtitle;
  final VoidCallback? onCancel;
  final VoidCallback? onSave;
  final List<Widget> children;
  final bool separated;
  final double spacing;
  final EdgeInsets padding;
  final bool showDragGrip;
  final double initialChildSize;
  final double minChildSize;

  static const EdgeInsets defaultPadding = EdgeInsets.all(AxeSpace.s24);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      // maxChildSize: 0.95,
      minChildSize: minChildSize,
      initialChildSize: initialChildSize,
      builder: (context, scrollController) {
        return Stack(
          alignment: Alignment.bottomCenter,
          //   fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: hideKeyboard,
              child: SafeArea(
                child: Padding(
                  padding: MediaQuery.of(context).viewInsets.add(defaultPadding),
                  child: CustomScrollView(
                    clipBehavior: Clip.none,
                    controller: scrollController,
                    slivers: [
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: AxeSheetScreenNavbar(
                              showDragGrip: true,
                              title: title,
                              hPadding: 0,
                            ),
                          ),
                          childCount: 1,
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: children[i],
                          ),
                          childCount: children.length,
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) => kVSpace96,
                          childCount: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (onCancel != null && onSave != null) AxeSheetActions(onCancel: onCancel!, onSave: onSave!),
          ],
        );
      },
    );
  }
}

typedef DoneBuilder = Widget Function(Widget Function(VoidCallback callback));

class AxeSheetScreenNavbar extends StatelessWidget {
  const AxeSheetScreenNavbar({
    super.key,
    this.title,
    this.subtitle,
    this.onTitleTap,
    this.actions = const [],
    this.vPadding = AxeSpace.s12,
    this.hPadding = AxeSpace.s24,

    /// Cancel button
    this.cancelTitle = 'Cancel',
    this.onCancel,

    /// Done button
    this.doneTitle = 'Done',
    this.onDone,
    this.doneBuilder,
    this.showDragGrip = true,
  });

  final String? title;
  final String? subtitle;
  final VoidCallback? onTitleTap;
  final List<Widget> actions;

  final String cancelTitle;
  final VoidCallback? onCancel;

  final String doneTitle;
  final VoidCallback? onDone;
  final DoneBuilder? doneBuilder;

  final double vPadding;
  final double hPadding;
  final bool showDragGrip;

  Widget doneButton([VoidCallback? callback]) {
    return AxButton(
      title: doneTitle,
      color: AxButtonColor.primary,
      onTap: callback ?? onDone,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 48,
      padding: EdgeInsets.symmetric(vertical: vPadding, horizontal: hPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ExpandedRow(
                mainAxisAlignment: MainAxisAlignment.start,
                showChild: onCancel != null,
                child: AxButton(
                  title: cancelTitle,
                  color: AxButtonColor.normal,
                  onTap: onCancel,
                ),
              ),
              if (showDragGrip)
                _ExpandedRow(
                  mainAxisAlignment: MainAxisAlignment.center,
                  child: Container(
                    height: 6,
                    width: 60,
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              _ExpandedRow(
                showChild: doneBuilder != null || onDone != null,
                mainAxisAlignment: MainAxisAlignment.end,
                child: (doneBuilder == null) ? doneButton() : doneBuilder!(doneButton),
              ),
            ],
          ),
          if (title != null) kVSpace24,
          if (title != null)
            Text(
              title ?? '',
              style: TextStyle(
                color: context.h1,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          if (title != null && subtitle != null) kVSpace4,
          if (subtitle != null)
            Text(
              subtitle ?? '',
              style: TextStyle(
                color: context.h2,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
    );
  }
}

class _ExpandedRow extends StatelessWidget {
  const _ExpandedRow({this.mainAxisAlignment = MainAxisAlignment.start, this.showChild = true, required this.child});

  final MainAxisAlignment mainAxisAlignment;
  final bool showChild;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        children: [if (showChild) child],
      ),
    );
  }
}
