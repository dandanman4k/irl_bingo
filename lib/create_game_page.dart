import 'package:flutter/material.dart';
import 'dart:math';

class CreateGamePage extends StatefulWidget {
  const CreateGamePage({super.key});

  @override
  State<CreateGamePage> createState() => _CreateGamePageState();
}

class _CreateGamePageState extends State<CreateGamePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roundsController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  void _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    final code = List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
    setState(() => _codeController.text = code);
  }

  void _createGame() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final rounds = int.parse(_roundsController.text.trim());
      final code = _codeController.text.trim();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Game "$name" created! Code: $code, Rounds: $rounds')));

      Navigator.pop(context, {'name': name, 'rounds': rounds, 'code': code});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Game'),
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text('Set up your new game', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // Game Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Game Name',
                  prefixIcon: Icon(Icons.videogame_asset),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Enter a game name' : null,
              ),
              const SizedBox(height: 16),

              // Number of Rounds
              TextFormField(
                controller: _roundsController,
                decoration: const InputDecoration(
                  labelText: 'Number of Rounds',
                  prefixIcon: Icon(Icons.timelapse),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter number of rounds';
                  final num? rounds = int.tryParse(value);
                  if (rounds == null || rounds <= 0) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Game Code
              TextFormField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: 'Game Code',
                  prefixIcon: const Icon(Icons.vpn_key),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Generate random code',
                    onPressed: _generateCode,
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Enter or generate a code' : null,
              ),
              const SizedBox(height: 30),

              // Create Game Button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _createGame,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Create Game'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
