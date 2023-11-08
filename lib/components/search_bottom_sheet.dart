import 'package:flutter/material.dart';
import 'package:gbooks/enums/filter.dart';
import 'package:gbooks/enums/language.dart';

class SearchBottomSheet extends StatefulWidget {
  final TextEditingController searchController;

  final Function() onSearchPressed;

  final String selectedLanguage;
  final Function(String?) onLanguageSelection;
  final Function(String?) onFilterSelection;

  const SearchBottomSheet({
    super.key,
    required this.searchController,
    required this.onSearchPressed,
    required this.selectedLanguage,
    required this.onLanguageSelection,
    required this.onFilterSelection,
  });

  @override
  State<SearchBottomSheet> createState() => _SearchBottomSheetState();
}

class _SearchBottomSheetState extends State<SearchBottomSheet> {
  int? _value = 0;
  int? _languageValue = 3;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: 20,
        left: 15,
        right: 15,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: widget.searchController,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onEditingComplete: widget.onSearchPressed,
            decoration: const InputDecoration(
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                  borderSide: BorderSide(color: Colors.black12)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(50)),
                borderSide: BorderSide(
                  color: Colors.black12,
                ),
              ),
              hintText: "Pesquisar",
            ),
          ),
          const SizedBox(height: 30),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Filtrar por:', style: textTheme.labelLarge),
              const SizedBox(height: 5.0),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Wrap(
                  alignment: WrapAlignment.start,
                  direction: Axis.horizontal,
                  spacing: 5.0,
                  children: List<Widget>.generate(
                    // filterList.length,
                    Filter.values.length,
                    (int index) {
                      return ChoiceChip(
                        side: BorderSide.none,
                        backgroundColor: Colors.black12,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(16),
                          ),
                        ),
                        label: Text(Filter.values[index].dropDownValue),
                        selected: _value == index,
                        onSelected: (bool selected) {
                          setState(() {
                            _value = selected ? index : null;
                            if (_value != null) {
                              widget.onFilterSelection(
                                  Filter.values[index].apiValue);
                            } else {
                              widget.onFilterSelection(
                                  Filter.all.apiValue);
                            }
                          });
                        },
                      );
                    },
                  ).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Idioma:', style: textTheme.labelLarge),
              const SizedBox(height: 5.0),
              Wrap(
                spacing: 5.0,
                children: List<Widget>.generate(
                  Language.values.length,
                  (int index) {
                    return ChoiceChip(
                      side: BorderSide.none,
                      backgroundColor: Colors.black12,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(16),
                        ),
                      ),
                      label: Text(Language.values[index].fullName),
                      selected: _languageValue == index,
                      onSelected: (bool selected) {
                        setState(() {
                          _languageValue = selected ? index : null;
                          if (_languageValue != null) {
                            widget.onLanguageSelection(
                                Language.values[index].name);
                          } else {
                            widget.onLanguageSelection(Language.all.name);
                          }
                          // this.widget.selectedLanguage = 'br';
                        });
                      },
                    );
                  },
                ).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
