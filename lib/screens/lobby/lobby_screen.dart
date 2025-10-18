import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../configure/constants.dart';
import '../../provider/authProvider.dart';
import '../../provider/coinProvider.dart';
import '../../services/route/route.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser != null) {
      context.read<CoinProvider>().loadCoins(authProvider.currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ludo Masters'),
        actions: [
          Consumer<CoinProvider>(
            builder: (context, coinProvider, _) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.monetization_on, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        coinProvider.coins.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildGameModeCard(
                  context,
                  Icons.people,
                  '2 Player',
                  '${AppConstants.ENTRY_FEE_2P} Coins',
                  Colors.blue,
                  () => _startGame(context, 2),
                ),
                _buildGameModeCard(
                  context,
                  Icons.people,
                  '3 Player',
                  '${AppConstants.ENTRY_FEE_3P} Coins',
                  Colors.green,
                  () => _startGame(context, 3),
                ),
                _buildGameModeCard(
                  context,
                  Icons.people,
                  '4 Player',
                  '${AppConstants.ENTRY_FEE_4P} Coins',
                  Colors.purple,
                  () => _startGame(context, 4),
                ),
                _buildGameModeCard(
                  context,
                  Icons.wine_bar,
                  'Tournaments',
                  'Join Now',
                  Colors.orange,
                  () => Navigator.pushNamed(context, AppRoutes.tournaments),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.leaderboard),
                label: const Text('Leaderboard'),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.leaderboard);
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      drawer: _buildDrawer(context),
    );
  }

  Widget _buildGameModeCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.7),
              color.withValues(alpha: 0.4),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black26)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue.shade400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const CircleAvatar(radius: 30, child: Icon(Icons.person)),
                    const SizedBox(height: 8),
                    Text(
                      authProvider.userModel?.username ?? 'User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.profile);
                },
              ),
              ListTile(
                leading: const Icon(Icons.leaderboard),
                title: const Text('Leaderboard'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.leaderboard);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  authProvider.signOut();
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _startGame(BuildContext context, int numPlayers) {
    int entryFee = numPlayers == 2
        ? AppConstants.ENTRY_FEE_2P
        : numPlayers == 3
        ? AppConstants.ENTRY_FEE_3P
        : AppConstants.ENTRY_FEE_4P;

    final coinProvider = context.read<CoinProvider>();
    if (coinProvider.canAfford(entryFee)) {
      Navigator.pushNamed(
        context,
        AppRoutes.matchmaking,
        arguments: {'numPlayers': numPlayers, 'entryFee': entryFee},
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient coins!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
