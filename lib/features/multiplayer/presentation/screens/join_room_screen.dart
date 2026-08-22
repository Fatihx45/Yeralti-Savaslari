import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../application/lobby_notifier.dart';
import 'lobby_screen.dart';

class JoinRoomScreen extends ConsumerStatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  ConsumerState<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends ConsumerState<JoinRoomScreen> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lobbyState = ref.watch(lobbyNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('ODAYA KATIL', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F28),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF2E2E68), width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.vpn_key, color: Color(0xFFE040FB), size: 40),
                const SizedBox(height: 12),
                const Text(
                  '6 Haneli Oda Kodunu Girin',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Arkadaşınızın paylaştığı oda kodunu girerek lobiye katılın:',
                  style: TextStyle(color: Color(0xFF8E8EAE), fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Kod Giriş Alanı
                TextField(
                  controller: _codeController,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(
                    color: AppColors.goldText,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'ABCDEF',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2), letterSpacing: 8),
                    filled: true,
                    fillColor: const Color(0xFF16163A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF2E2E68)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE040FB), width: 2),
                    ),
                  ),
                ),
                if (lobbyState.errorMessage != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    lobbyState.errorMessage!,
                    style: const TextStyle(color: AppColors.resetRed, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E1038),
                      foregroundColor: const Color(0xFFE040FB),
                      side: const BorderSide(color: Color(0xFFE040FB), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 6,
                    ),
                    onPressed: () {
                      final success = ref.read(lobbyNotifierProvider.notifier).joinRoom(_codeController.text);
                      if (success) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (ctx) => const LobbyScreen()),
                        );
                      }
                    },
                    icon: const Icon(Icons.login, size: 20),
                    label: const Text(
                      'LOBİYE KATIL',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

