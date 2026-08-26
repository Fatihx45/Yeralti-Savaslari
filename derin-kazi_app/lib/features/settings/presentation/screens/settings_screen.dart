import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../mining/application/game_notifier.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameNotifierProvider);
    final player = gameState.player;
    final notifier = ref.read(gameNotifierProvider.notifier);
    final lang = player.languageCode;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Üst Başlık Çubuğu
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.hudPanel,
                border: Border(bottom: BorderSide(color: Color(0xFF4A2518), width: 1.5)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(
                      'assets/image/logo.jpg',
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.tr('game_settings', lang: lang),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            // 2. Ayar Bölümleri Listesi
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ⚡ TÜMÜNÜ AKTİFLEŞTİR HIZLI BUTONU
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF5722), Color(0xFFFF8A50)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF5722).withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.bolt, color: Colors.white, size: 22),
                      label: Text(
                        AppStrings.tr('activate_all_settings', lang: lang),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                      onPressed: () {
                        notifier.activateAllSettings();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.lavaOrange,
                            content: Text(
                              AppStrings.tr('all_settings_activated', lang: lang),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // 1. Ses & Titreşim
                  _buildSectionHeader(AppStrings.tr('audio_vibration', lang: lang)),
                  _buildSliderTile(
                    title: AppStrings.tr('sfx_volume', lang: lang),
                    value: player.sfxVolume,
                    onChanged: (val) {
                      notifier.updateSettings(sfxVolume: val);
                    },
                  ),
                  _buildSliderTile(
                    title: AppStrings.tr('music_volume', lang: lang),
                    value: player.musicVolume,
                    onChanged: (val) {
                      notifier.updateSettings(musicVolume: val);
                    },
                  ),
                  _buildSwitchTile(
                    title: AppStrings.tr('vibration', lang: lang),
                    subtitle: AppStrings.tr('vibration_sub', lang: lang),
                    value: player.vibrationEnabled,
                    onChanged: (val) => notifier.updateSettings(vibrationEnabled: val),
                  ),
                  const SizedBox(height: 16),

                  // 2. Bildirimler
                  _buildSectionHeader(AppStrings.tr('notifications', lang: lang)),
                  _buildSwitchTile(
                    title: AppStrings.tr('energy_full_notif', lang: lang),
                    subtitle: AppStrings.tr('energy_full_sub', lang: lang),
                    value: player.notificationsEnergyFull,
                    onChanged: (val) => notifier.updateSettings(notificationsEnergyFull: val),
                  ),
                  _buildSwitchTile(
                    title: AppStrings.tr('weekly_quest_notif', lang: lang),
                    subtitle: AppStrings.tr('weekly_quest_sub', lang: lang),
                    value: player.notificationsDailyQuest,
                    onChanged: (val) => notifier.updateSettings(notificationsDailyQuest: val),
                  ),
                  _buildSwitchTile(
                    title: AppStrings.tr('room_invite_notif', lang: lang),
                    subtitle: AppStrings.tr('room_invite_sub', lang: lang),
                    value: player.notificationsInvites,
                    onChanged: (val) => notifier.updateSettings(notificationsInvites: val),
                  ),
                  const SizedBox(height: 16),

                  // 3. Dil & Bölge
                  _buildSectionHeader(AppStrings.tr('language_region', lang: lang)),
                  _buildSegmentedTile(
                    title: AppStrings.tr('selected_language', lang: lang),
                    currentValue: player.languageCode,
                    options: const ['tr', 'en'],
                    labels: const ['Türkçe 🇹🇷', 'English 🇬🇧'],
                    onSelected: (val) => notifier.setLanguage(val),
                  ),
                  const SizedBox(height: 16),

                  // 4. Hakkında
                  _buildSectionHeader(AppStrings.tr('about', lang: lang)),
                  _buildInfoTile(AppStrings.tr('game_version', lang: lang), 'v1.0.0 (Build 500)'),
                  _buildInfoTile(AppStrings.tr('developer', lang: lang), 'Ölmez Tech — Oyun Tasarım Ekibi'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title,
        style: const TextStyle(color: AppColors.goldText, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1),
      ),
    );
  }

  Widget _buildSwitchTile({required String title, required String subtitle, required bool value, required ValueChanged<bool> onChanged}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.panelBox,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF4A2518)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 10)),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.neonGreen,
            activeTrackColor: AppColors.neonGreen.withValues(alpha: 0.5),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderTile({required String title, required double value, required ValueChanged<double> onChanged}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.panelBox,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF4A2518)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Slider(
              value: value,
              min: 0.0,
              max: 1.0,
              activeColor: AppColors.goldText,
              inactiveColor: const Color(0xFF381F1A),
              onChanged: onChanged,
            ),
          ),
          Text('%${(value * 100).round()}', style: const TextStyle(color: AppColors.goldText, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSegmentedTile({required String title, required String currentValue, required List<String> options, required List<String> labels, required ValueChanged<String> onSelected}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.panelBox,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF4A2518)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold))),
          Row(
            children: List.generate(options.length, (idx) {
              final opt = options[idx];
              final label = labels[idx];
              final isSel = currentValue == opt;
              return Padding(
                padding: const EdgeInsets.only(left: 6),
                child: ChoiceChip(
                  label: Text(label, style: TextStyle(color: isSel ? Colors.black : Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                  selected: isSel,
                  selectedColor: AppColors.goldText,
                  backgroundColor: const Color(0xFF140D1A),
                  onSelected: (_) => onSelected(opt),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.panelBox,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF4A2518)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
