import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:substring_highlight/substring_highlight.dart';

void main() => runApp(const AutocompleteExampleApp());

/// Widget principal da aplicação.
class AutocompleteExampleApp extends StatelessWidget {
  const AutocompleteExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exemplo de Autocomplete',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoaging = false;
  late List<String> autocompleteData;
  late TextEditingController controller;

  Future fetchAutocompleteData() async {
    setState(() {
      isLoaging = true;
    });

    final String stringData = await rootBundle.loadString("assets/data.json");
    final List<dynamic> json = jsonDecode(stringData);
    final List<String> jsonStringData = json.cast<String>();

    setState(() {
      isLoaging = false;
      autocompleteData = jsonStringData;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchAutocompleteData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Autocomplete Exemplo'),
      ),
      body: isLoaging
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                spacing: 32,
                children: [
                  Autocomplete(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text == '') {
                        return const Iterable<String>.empty();
                      }
                      return autocompleteData.where(
                        (option) => option
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase()),
                      );
                    },
                    onSelected: (option) {
                      debugPrint('Teste -> onSelected: $option');
                    },
                    fieldViewBuilder:
                        (context, controller, focusNode, onEditingComplete) {
                      this.controller = controller;

                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        onEditingComplete: onEditingComplete,
                        decoration: InputDecoration(
                          hintText: 'Pesquisar país...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[200]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.purple[900]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[600]!),
                          ),
                        ),
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Material(
                        elevation: 4,
                        child: ListView.separated(
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              final option = options.elementAt(index);
                              return ListTile(
                                // title: Text(option),
                                title: SubstringHighlight(
                                  text: option.toString(),
                                  term: controller.text,
                                  textStyleHighlight: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text('Descrição do item $option'),
                                leading: Icon(Icons.info),
                                onTap: () {
                                  onSelected(option.toString());
                                },
                              );
                            },
                            separatorBuilder: (context, index) =>
                                const Divider(),
                            itemCount: options.length),
                      );
                    },
                  ),

                  GestureDetector(
                    onTap: () => debugPrint('Teste -> Clicou no Container'),
                    child: Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.red[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text('Conteúdo abaixo do campo de pesquisa'),
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
