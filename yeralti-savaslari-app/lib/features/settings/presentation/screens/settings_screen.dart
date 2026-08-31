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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                color: AppColors.hudPanel,
                border: Border(bottom: BorderSide(color: Color(0xFF4A2518), width: 1.5)),
              ),
              child: Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.asset(
                      'assets/image/logo.jpg',
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.tr('game_settings', lang: lang),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),

            // 2. Ayar Bölümleri Listesi
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                children: [
                  // ⚡ TÜMÜNÜ AKTİFLEŞTİR HIZLI BUTONU
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF5722), Color(0xFFFF8A50)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF5722).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        minimumSize: const Size(double.infinity, 34),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.bolt, color: Colors.white, size: 16),
                      label: Text(
                        AppStrings.tr('activate_all_settings', lang: lang),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
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
                  const SizedBox(height: 8),

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
                  const SizedBox(height: 8),

                  // 3. Dil & Bölge
                  _buildSectionHeader(AppStrings.tr('language_region', lang: lang)),
                  _buildSegmentedTile(
                    title: AppStrings.tr('selected_language', lang: lang),
                    currentValue: player.languageCode,
                    options: const ['tr', 'en'],
                    labels: const ['Türkçe 🇹🇷', 'English 🇬🇧'],
                    onSelected: (val) => notifier.setLanguage(val),
                  ),
                  const SizedBox(height: 8),

                  // 4. Hakkında
                  _buildSectionHeader(AppStrings.tr('about', lang: lang)),
                  _buildInfoTile(AppStrings.tr('game_version', lang: lang), 'v1.0.2 (Build 3)'),
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
      padding: const EdgeInsets.only(bottom: 4, top: 2),
      child: Text(
        title,
        style: const TextStyle(color: AppColors.goldText, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
      ),
    );
  }

  Widget _buildSwitchTile({required String title, required String subtitle, required bool value, required ValueChanged<bool> onChanged}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.panelBox,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4A2518)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 9)),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              activeThumbColor: AppColors.neonGreen,
              activeTrackColor: AppColors.neonGreen.withValues(alpha: 0.5),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderTile({required String title, required double value, required ValueChanged<double> onChanged}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.panelBox,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4A2518)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: SliderTheme(
              data: const SliderThemeData(
                trackHeight: 3,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 12),
              ),
              child: Slider(
                value: value,
                min: 0.0,
                max: 1.0,
                activeColor: AppColors.goldText,
                inactiveColor: const Color(0xFF381F1A),
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 32,
            child: Text(
              '%${(value * 100).round()}',
              textAlign: TextAlign.end,
              style: const TextStyle(color: AppColors.goldText, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedTile({required String title, required String currentValue, required List<String> options, required List<String> labels, required ValueChanged<String> onSelected}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.panelBox,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4A2518)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold))),
          Row(
            children: List.generate(options.length, (idx) {
              final opt = options[idx];
              final label = labels[idx];
              final isSel = currentValue == opt;
              return Padding(
                padding: const EdgeInsets.only(left: 4),
                child: ChoiceChip(
                  label: Text(label, style: TextStyle(color: isSel ? Colors.black : Colors.white70, fontSize: 9, fontWeight: FontWeight.bold)),
                  selected: isSel,
                  selectedColor: AppColors.goldText,
                  backgroundColor: const Color(0xFF140D1A),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.panelBox,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4A2518)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
