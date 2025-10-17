import 'package:flutter/material.dart';

// Import all your screens
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/game/game_board_screen.dart';
import '../../screens/lobby/lobby_screen.dart';
import '../../screens/lobby/matchmaking_waiting_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/splashScreen/splashScreen.dart';
import '../../screens/tournament/create_tournament_screen.dart';
// import '../../screens/tournament/tournament_list_screen.dart';
// import '../../screens/leaderboard/leaderboard_screen.dart';

class AppRoutes {
  // 🔹 Route names
  static const String splash = '/splash';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String lobby = '/lobby';
  static const String matchmaking = '/matchmaking';
  static const String gameBoard = '/game-board';
  static const String tournaments = '/tournaments';
  static const String createTournament = '/create-tournament';
  static const String profile = '/profile';
  static const String leaderboard = '/leaderboard';

  // 🔹 Route map
  static final Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    signup: (context) => const SignupScreen(),
    lobby: (context) => const LobbyScreen(),

    // 🟢 Matchmaking Screen
    matchmaking: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      return MatchmakingWaitingScreen(
        numPlayers: args?['numPlayers'] ?? 2,
        entryFee: args?['entryFee'] ?? 10,
      );
    },

    // 🟩 Game Board Screen (takes dynamic arguments)
    gameBoard: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      return GameBoardScreen(
        gameId: args?['gameId'] ?? '',
        currentUserId: args?['currentUserId'] ?? '',
      );
    },

    // 🏆 Tournament Screens
    // tournaments: (context) => const TournamentListScreen(),
    createTournament: (context) => const CreateTournamentScreen(),

    // 👤 Profile
    profile: (context) => const ProfileScreen(),

    // 🏅 Leaderboard (if available later)
    // leaderboard: (context) => const LeaderboardScreen(),
  };
}
