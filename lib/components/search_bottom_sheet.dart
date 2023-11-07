import 'package:flutter/material.dart';
import 'package:gbooks/enums/filter.dart';

class SearchBottomSheet extends StatefulWidget {
  final TextEditingController searchController;
  final bool portugueseOnly;
  final String dropdownValue;
  final Function() onSearchPressed;
  final Function(bool?) onPortugueseOnlyChanged;
  final Function(String?) onDropdownValueChanged;

  const SearchBottomSheet({
    super.key,
    required this.searchController,
    required this.portugueseOnly,
    required this.dropdownValue,
    required this.onSearchPressed,
    required this.onPortugueseOnlyChanged,
    required this.onDropdownValueChanged,
  });

  @override
  State<SearchBottomSheet> createState() => _SearchBottomSheetState();
}

class _SearchBottomSheetState extends State<SearchBottomSheet> {
  final List<String> list = <String>[
    Filter.partial.dropDownValue,
    Filter.ebooks.dropDownValue,
    Filter.freeEbooks.dropDownValue,
    Filter.full.dropDownValue,
    Filter.all.dropDownValue
  ];

  late String dropdownValue = list.last;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 15,
        right: 15,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextFormField(
                  controller: widget.searchController,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  // onTapOutside: (PointerDownEvent event) {
                  //   FocusManager.instance.primaryFocus?.unfocus();
                  // },
                  onEditingComplete: widget.onSearchPressed,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Pesquisar",
                  ),
                ),
              ),
              IconButton(
                onPressed: widget.onSearchPressed,
                icon: const Icon(Icons.search_outlined),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CheckboxMenuButton(
                value: widget.portugueseOnly,
                onChanged: widget.onPortugueseOnlyChanged,
                child: const Text('Em português'),
              ),
              Listener(
                onPointerDown: (_) => FocusScope.of(context).unfocus(),
                child: DropdownMenu<String>(
                  initialSelection: widget.dropdownValue,
                  requestFocusOnTap: false,
                  enableFilter: false,
                  enableSearch: false,
                  inputDecorationTheme: InputDecorationTheme(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none),
                    // fillColor: Colors.grey,
                    filled: true,
                  ),
                  onSelected: widget.onDropdownValueChanged,
                  dropdownMenuEntries: list.map<DropdownMenuEntry<String>>(
                    (String value) {
                      return DropdownMenuEntry<String>(
                          value: value, label: value);
                    },
                  ).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
