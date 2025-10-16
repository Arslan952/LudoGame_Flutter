import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/tournamentProvider.dart';
import '../../utils/validators.dart';

class CreateTournamentScreen extends StatefulWidget {
  const CreateTournamentScreen({Key? key}) : super(key: key);

  @override
  State<CreateTournamentScreen> createState() => _CreateTournamentScreenState();
}

class _CreateTournamentScreenState extends State<CreateTournamentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  int _maxPlayers = 8;
  int _entryFee = 50;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Tournament')),
      body: Consumer<TournamentProvider>(
        builder: (context, tournamentProvider, _) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      // validator: Validators.validateTournamentName,
                      decoration: InputDecoration(
                        labelText: 'Tournament Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Max Players: $_maxPlayers',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Slider(
                      value: _maxPlayers.toDouble(),
                      min: 8,
                      max: 16,
                      divisions: 1,
                      onChanged: (value) {
                        setState(() {
                          _maxPlayers = value.toInt();
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Entry Fee: $_entryFee Coins',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Slider(
                      value: _entryFee.toDouble(),
                      min: 10,
                      max: 500,
                      divisions: 49,
                      onChanged: (value) {
                        setState(() {
                          _entryFee = value.toInt();
                        });
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: tournamentProvider.isLoading ? null : _createTournament,
                      child: tournamentProvider.isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Text('Create Tournament'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _createTournament() {
    if (_formKey.currentState!.validate()) {
      final prizePool = _calculatePrizePool();

      context.read<TournamentProvider>().createTournament(
        _nameController.text,
        _maxPlayers,
        _entryFee,
        prizePool,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tournament created!')),
      );

      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context);
      });
    }
  }

  List<int> _calculatePrizePool() {
    int totalPool = _entryFee * _maxPlayers;

    if (_maxPlayers == 8) {
      return [
        (totalPool * 0.4).toInt(),
        (totalPool * 0.3).toInt(),
        (totalPool * 0.2).toInt(),
        (totalPool * 0.1).toInt(),
      ];
    } else {
      return [
        (totalPool * 0.4).toInt(),
        (totalPool * 0.25).toInt(),
        (totalPool * 0.15).toInt(),
        (totalPool * 0.1).toInt(),
        (totalPool * 0.05).toInt(),
        (totalPool * 0.03).toInt(),
        (totalPool * 0.02).toInt(),
      ];
    }
  }
}