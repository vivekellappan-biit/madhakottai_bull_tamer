import 'package:flutter/material.dart';
import 'package:madhakottai_bull_tamer/screens/pdf_generator_screen.dart';
import 'package:provider/provider.dart';
import '../providers/bull_tamer_search_provider.dart';
import '../widgets/labelvalue_Row.dart';

class BullTamerSearchScreen extends StatelessWidget {
  BullTamerSearchScreen({super.key});

  final TextEditingController _aadharController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Bull Tamer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _aadharController,
              decoration: const InputDecoration(
                labelText: 'Aadhar Number',
                hintText: 'Enter 12 digit Aadhar number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 12,
              onChanged: (value) {
                if (value.length == 12) {
                  context
                      .read<BullTamerSearchProvider>()
                      .searchBullTamer(value, context);
                }
              },
            ),
            // const SizedBox(height: 16),
            // ElevatedButton(
            //   onPressed: () {
            //     if (_aadharController.text.length == 12) {
            //       context
            //           .read<BullTamerSearchProvider>()
            //           .searchBullTamer(_aadharController.text, context);
            //     }
            //   },
            //   child: const Text('Search'),
            // ),
            const SizedBox(height: 24),
            Expanded(
              child: Consumer<BullTamerSearchProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.errorMessage.isNotEmpty) {
                    return Center(
                      child: Text(
                        provider.errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (provider.searchResults.isEmpty) {
                    return const Center(
                      child: Text('No results found'),
                    );
                  }

                  return ListView.builder(
                    itemCount: provider.searchResults.length,
                    itemBuilder: (context, index) {
                      final tamer = provider.searchResults[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const PdfGeneratorPage(
                                      name: "Moses Isaac Prakash Prassanna",
                                      bloodGroup: "O +ve",
                                      aadhar: "9876 9876 9876",
                                      mobile: "9876543212",
                                      address: "Addressline, City",
                                    )),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 0),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LabelValueRow(
                                    label: "காளையை அடக்குபவர் பெயர்:",
                                    value: tamer.name),
                                LabelValueRow(
                                    label: "இரத்த வகை:",
                                    value: tamer.bloodGroup),
                                LabelValueRow(
                                    label: "பிறந்த தேதி:",
                                    value: tamer.dateOfBirth),
                                LabelValueRow(
                                    label: "தொலைபேசி எண்:",
                                    value: tamer.mobileOne),
                                LabelValueRow(
                                    label: "ஆதார் எண்:",
                                    value: tamer.aadharNumber),
                                LabelValueRow(
                                  label: "Created By:",
                                  value: '${tamer.writeUid[1]}',
                                ),
                                LabelValueRow(
                                  label: "Created Date:",
                                  value: tamer.createDate,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
