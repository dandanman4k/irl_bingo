import 'package:flutter/material.dart';
import './game_detail_page.dart';
import './create_game_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game Lobby',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: const GameListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GameListPage extends StatefulWidget {
  const GameListPage({super.key});

  @override
  State<GameListPage> createState() => _GameListPageState();
}

class _GameListPageState extends State<GameListPage> {
  final List<Map<String, dynamic>> games = [
    {'name': 'Space Invaders', 'players': 5},
    {'name': 'Battle Royale', 'players': 12},
    {'name': 'Mystery Mansion', 'players': 3},
    {'name': 'Zombie Escape', 'players': 8},
    {'name': 'Trivia Clash', 'players': 6},
  ];

  final TextEditingController _codeController = TextEditingController();

  void joinGame() {
    String code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a game code!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Joining game with code: $code')));
    }
  }

  void createGame() {
    setState(() {
      games.add({'name': 'New Game ${games.length + 1}', 'players': 0});
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('New game created!')));
  }

  String? username;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsername();
    });
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('username');
    if (savedName == null) {
      _showUsernameDialog();
    } else {
      setState(() => username = savedName);
    }
  }

  void _showUsernameDialog() {
    final TextEditingController usernameController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, // Must enter name
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Your Username'),
          content: TextField(
            controller: usernameController,
            decoration: const InputDecoration(
              hintText: 'Your name',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (usernameController.text.trim().isEmpty) return;
                final name = usernameController.text.trim();

                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('username', name);

                setState(() => username = name);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Welcome, $name!')));
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(username == null ? 'Game Lobby' : 'Welcome, $username'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Game List
            Expanded(
              child: ListView.separated(
                itemCount: games.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final game = games[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameDetailPage(
                            name: game['name'],
                            imageUrl: 'https://picsum.photos/400?random=${index + 1}',
                            players: [
                              {'name': 'Alice', 'points': 120, 'completed': true},
                              {'name': 'Bob', 'points': 90, 'completed': false},
                              {'name': 'Charlie', 'points': 100, 'completed': true},
                            ],
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: const Offset(0, 2))],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(game['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                          Row(
                            children: [
                              const Icon(Icons.people, size: 20),
                              const SizedBox(width: 6),
                              Text('${game['players']}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Game Code Input
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Enter Game Code',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.vpn_key),
              ),
            ),

            const SizedBox(height: 16),

            // Join and Create Buttons
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: joinGame,
                icon: const Icon(Icons.login),
                label: const Text('Join Game'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateGamePage()),
                  );

                  if (result != null && mounted) {
                    setState(() {
                      games.add({'name': result['name'], 'players': 0});
                    });

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Game "${result['name']}" created!')));
                  }
                },

                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Create New Game'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
