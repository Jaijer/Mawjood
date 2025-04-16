import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fuzzy/fuzzy.dart';

import '../components/spaces.dart';
import '../components/textfield.dart';
import '../components/theme.dart';

import 'button.dart';

class SelectFieldLayout extends HookWidget {
  const SelectFieldLayout(
      {super.key,
      required this.selectedOptions,
      required this.options,
      this.isMultiSelect = false,
      this.isSearchable = false,
      this.onAddTap});
  final ValueNotifier<List<Option>> selectedOptions;
  final List<Option> options;
  final bool isMultiSelect;
  final bool isSearchable;
  final void Function(String)? onAddTap;

  @override
  Widget build(BuildContext context) {
    void showSheet() async {
      context.axeActionSheet(
        title: "Select",
        doneButtonColorStyle: AxButtonColor.normal,
        cancelButtonTitle: "Clear",
        onCancel: isMultiSelect
            ? () {
                selectedOptions.value = [Option(id: 0, title: 'Select Type')];
                selectedOptions.notifyListeners();
              }
            : null,
        child: SelectPage(
            isMultiSelect: isMultiSelect,
            selectedOptions: selectedOptions,
            options: options,
            isSearchable: isSearchable,
            onAddTap: onAddTap),
        onDone: () {
          if (selectedOptions.value[0].title.contains('Select') && selectedOptions.value.length > 1) {
            selectedOptions.value = selectedOptions.value..removeAt(0);
            selectedOptions.notifyListeners();
          }
          Navigator.of(context).pop();
        },
      );
    }

    int length = selectedOptions.value.length;
    return AxTextField(
      readOnly: true,
      title: length > 1
          ? List.generate(length, (index) => selectedOptions.value[index].title).join(",")
          : selectedOptions.value[0].title,
      onTap: showSheet,
      suffixIcon: const Icon(Icons.expand_more),
    );
  }
}

class SelectPage extends HookWidget {
  const SelectPage(
      {super.key,
      required this.selectedOptions,
      required this.options,
      this.isMultiSelect = false,
      this.isSearchable = false,
      this.onAddTap});
  final ValueNotifier<List<Option>> selectedOptions;
  final List<Option> options;
  final bool isMultiSelect;
  final bool isSearchable;
  final void Function(String)? onAddTap;

  @override
  Widget build(BuildContext context) {
    final query = useState("");
    final searchController = useTextEditingController(text: query.value);
    Fuzzy<Option> computeFuzzy() {
      return Fuzzy<Option>(
        options,
        options: FuzzyOptions<Option>(
          keys: [
            WeightedKey<Option>(name: 'title', getter: (v) => v.title, weight: 2),
          ],
        ),
      );
    }

    final fuzzy = useState(computeFuzzy());
    List<Option> getSearchedList(String query) {
      if (query.trim().isEmpty) return options;

      return fuzzy.value.search(query).map((r) => r.item).toList();
    }

    return Column(
      children: [
        if (isSearchable)
          AxTextField(
            controller: searchController,
            prefixIcon: Icon(Icons.search),
            title: "Serach",
            onChanged: (value) {
              query.value = value;
            },
            borderColor: context.bg3,
          ),
        AxSelectGridSheetView(
          selectedOptions: selectedOptions,
          options: query.value.isNotEmpty ? getSearchedList(query.value) : options,
          isMultiSelect: isMultiSelect,
          onAddTap: onAddTap,
        ),
      ],
    );
  }
}

class AxSelectGridSheetView extends HookWidget {
  AxSelectGridSheetView(
      {super.key, required this.selectedOptions, required this.options, this.isMultiSelect = false, this.onAddTap});
  ValueNotifier<List<Option>> selectedOptions;
  List<Option> options;
  final bool isMultiSelect;
  final void Function(String)? onAddTap;

  @override
  Widget build(BuildContext context) {
    final isAdding = useState(false);
    final optionsIn = useState(options);
    final addController = useTextEditingController();
    return ValueListenableBuilder<List<Option>>(
      valueListenable: selectedOptions,
      builder: (context, value, _) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 250, minHeight: 120),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: onAddTap != null ? options.length + 1 : options.length,
            itemBuilder: (context, index) {
              if (index == optionsIn.value.length && onAddTap != null) {
                return Column(
                  children: [
                    if (!isAdding.value)
                      GestureDetector(
                          onTap: () => isAdding.value = true,
                          child: Flexible(
                            child: Container(
                              height: 50,
                              color: context.h1,
                              child: Center(
                                  child: Icon(
                                Icons.add,
                                color: context.bg3,
                              )),
                            ),
                          )),
                    if (isAdding.value)
                      SizedBox(
                        height: 40,
                        child: AxTextField(
                          topBorder: false,
                          rightBorder: false,
                          bottomBorder: false,
                          suffixIcon: IconButton(
                              onPressed: () {
                                onAddTap!.call(addController.text);

                                optionsIn.value = optionsIn.value..add(Option(id: 8, title: addController.text));

                                isAdding.value = false;
                              },
                              icon: Icon(
                                Icons.add,
                                color: context.bg3,
                              )),
                          controller: addController,
                          borderColor: context.bg3,
                          onSubmitted: (value) {
                            onAddTap!.call(value);

                            optionsIn.value = optionsIn.value..add(Option(id: 8, title: value));

                            isAdding.value = false;
                          },
                        ),
                      )
                  ],
                );
              }

              Option option = optionsIn.value[index];

              var isSelected = value.any((element) => element.title == option.title);

              return AxeOptionView(
                expandWidth: false,
                option: option,
                isSelected: isSelected,
                onTap: (option) {
                  if (isMultiSelect) {
                    if (!selectedOptions.value.any((element) => element.title == option.title)) {
                      selectedOptions.value = selectedOptions.value..add(option);
                    } else {
                      selectedOptions.value = selectedOptions.value..remove(option);
                    }
                  } else {
                    selectedOptions.value = [option];
                  }

                  selectedOptions.notifyListeners();
                },
              );
            },
            separatorBuilder: (context, index) => const Divider(height: 1),
          ),
        );

        // Wrap(
        //   spacing: 8,
        //   runSpacing: 8,
        //   children: options.map((option) {
        //     final isSelected = value.any((o) => o.id == option.id);
        //     return AxGridOptionView(
        //       expandWidth: false,
        //       option: option,
        //       isSelected: isSelected,
        //       onTap: (option) {
        //         selectedOptions.value = [option];
        //         selectedOptions.notifyListeners();
        //       },
        //     );
        //   }).toList(),
        // );
      },
    );
  }
}

class AxeOptionView extends StatelessWidget {
  AxeOptionView({
    super.key,
    required this.option,
    this.onTap,
    required this.isSelected,
    this.expandWidth = true,
  });

  final Option option;
  final ValueChanged<Option>? onTap;
  final bool isSelected;
  final bool expandWidth;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap!(option);
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AxeSpace.s12,
          // horizontal: withHPadding ? AxeSpace.s16 : 0,
        ),
        child: Row(
          children: [
            Text(
              option.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: context.bg3,
              ),
            ),

            kHSpace12,
            if (isSelected)
              Icon(
                CupertinoIcons.checkmark,
                size: 16,
                color: context.bg3,
              ),
            // AxeCheckboxView(checked: selected, unselectedBorderColor: unselectedBorderColor),
          ],
        ),
      ),
    );
  }
}

class Option {
  final int id;
  final String title;
  Option({
    required this.id,
    required this.title,
  });
}
