// lib/helloUI.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'contract_linking.dart';

class HelloUI extends StatelessWidget {
  const HelloUI({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final contract = Provider.of<ContractLinking>(context);
    final TextEditingController nameController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hello World DApp"),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: contract.isLoading
              ? const CircularProgressIndicator()
              : SingleChildScrollView(
                  child: Form(
                    child: Column(
                      children: [
                        // --- Affichage dynamique du nom enregistré sur la blockchain ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Hello ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 52,
                              ),
                            ),
                            Text(
                              contract.deployedName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 52,
                                color: Colors.tealAccent,
                              ),
                            ),
                          ],
                        ),

                        // --- Champ de texte ---
                        Padding(
                          padding: const EdgeInsets.only(top: 29),
                          child: TextFormField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Your Name",
                              hintText: "What is your name ?",
                              icon: Icon(Icons.drive_file_rename_outline),
                            ),
                          ),
                        ),

                        // --- Bouton pour appeler setName ---
                        Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: ElevatedButton(
                            child: const Text(
                              'Set Name',
                              style: TextStyle(fontSize: 30),
                            ),
                            onPressed: () async {
                              final name = nameController.text.trim();

                              if (name.isNotEmpty) {
                                await contract.setName(name);
                                nameController.clear();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
