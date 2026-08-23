import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../mining/application/game_notifier.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  void _showResetConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF241018),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFFF5252), size: 24),
            SizedBox(width: 8),
            Text('İlerlemeyi Sıfırla', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Tüm altın, elmas, seviyeler ve yükseltmeler kalıcı olarak sıfırlanacaktır. Bu işlem geri alınamaz!\n\nEmin misiniz?',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Vazgeç', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5252), foregroundColor: Colors.white),
            onPressed: () {
              ref.read(gameNotifierProvider.notifier).resetAllProgress();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tüm ilerleme başarıyla sıfırlandı!')),
              );
            },
            child: const Text('Evet, Sıfırla', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context, String title) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141438),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Mesajınızı yazın...',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF0A0A1C),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Kapat', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonGreen, foregroundColor: Colors.black),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Geri bildiriminiz için teşekkür ederiz!')),
              );
            },
            child: const Text('Gönder', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showHowToPlayDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141438),
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: AppColors.goldText, size: 22),
            SizedBox(width: 8),
            Text('Nasıl Oynanır?', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const SingleChildScrollView(
          child: Text(
            '• ⛏️ D-Pad veya dokunarak kutuları kazın.\n'
            '• 🟡 Altın, elmas ve madenler toplayın.\n'
            '• 💣 TNT ve Gizli Bombalara dikkat edin!\n'
            '• ⚔️ Mini-Boss ve Biyom Bossları yenerek 500. bölüme ulaşın!\n'
            '• 🌐 Multiplayer modunda diğer madencilerle yarışın!',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldText, foregroundColor: Colors.black),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Anladım', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameNotifierProvider);
    final player = gameState.player;
    final notifier = ref.read(gameNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF090918),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Üst Başlık Çubuğu
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF121232),
                border: Border(bottom: BorderSide(color: Color(0xFF2E2E68), width: 1.5)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.settings, color: AppColors.goldText, size: 22),
                  const SizedBox(width: 8),
                  const Text(
                    'AYARLAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
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
                  // 1. Ses & Titreşim
                  _buildSectionHeader('🔊 SES & TİTREŞİM'),
                  _buildSliderTile(
                    title: 'Efekt Sesi (SFX)',
                    value: player.sfxVolume,
                    onChanged: (val) => notifier.updateSettings(sfxVolume: val),
                  ),
                  _buildSliderTile(
                    title: 'Müzik Sesi',
                    value: player.musicVolume,
                    onChanged: (val) => notifier.updateSettings(musicVolume: val),
                  ),
                  _buildSwitchTile(
                    title: 'Titreşim (Haptic Feedback)',
                    subtitle: 'Kutu kazma ve patlamalarda titreşir',
                    value: player.vibrationEnabled,
                    onChanged: (val) => notifier.updateSettings(vibrationEnabled: val),
                  ),
                  const SizedBox(height: 16),

                  // 2. Bildirimler
                  _buildSectionHeader('🔔 BİLDİRİMLER'),
                  _buildSwitchTile(
                    title: 'Enerji Dolumu',
                    subtitle: 'Enerji tamamen dolunca haber ver',
                    value: player.notificationsEnergyFull,
                    onChanged: (val) => notifier.updateSettings(notificationsEnergyFull: val),
                  ),
                  _buildSwitchTile(
                    title: 'Haftalık Görev Hatırlatıcı',
                    subtitle: 'Görevler yenilendiğinde bildir',
                    value: player.notificationsDailyQuest,
                    onChanged: (val) => notifier.updateSettings(notificationsDailyQuest: val),
                  ),
                  _buildSwitchTile(
                    title: 'Oda Daveti Bildirimi',
                    subtitle: 'Arkadaşların seni odaya çağırdığında bildir',
                    value: player.notificationsInvites,
                    onChanged: (val) => notifier.updateSettings(notificationsInvites: val),
                  ),
                  const SizedBox(height: 16),

                  // 3. Grafik & Performans
                  _buildSectionHeader('⚡ GRAFİK & PERFORMANS'),
                  _buildSegmentedTile(
                    title: 'Grafik Kalitesi',
                    currentValue: player.graphicsQuality,
                    options: const ['low', 'medium', 'high'],
                    labels: const ['Düşük', 'Orta', 'Yüksek'],
                    onSelected: (val) => notifier.updateSettings(graphicsQuality: val),
                  ),
                  _buildSwitchTile(
                    title: 'Pil Tasarrufu Modu',
                    subtitle: 'Animasyonları hafifletip pil tüketimini azaltır',
                    value: player.batterySaverMode,
                    onChanged: (val) => notifier.updateSettings(batterySaverMode: val),
                  ),
                  const SizedBox(height: 16),

                  // 4. Dil & Bölge
                  _buildSectionHeader('🌐 DİL & BÖLGE'),
                  _buildInfoTile('Seçili Dil', 'Türkçe 🇹🇷 (İngilizce Yakında)'),
                  const SizedBox(height: 16),

                  // 5. Hesap & Veri
                  _buildSectionHeader('💾 HESAP & VERİ'),
                  _buildActionTile(
                    title: 'Oyun Verisini Yedekle',
                    subtitle: 'Kayıtlı verileri yerel hafızada senkronize eder',
                    icon: Icons.cloud_upload_outlined,
                    color: AppColors.neonGreen,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Oyun verisi başarıyla yedeklendi!')),
                      );
                    },
                  ),
                  _buildActionTile(
                    title: 'İlerlemeyi Sıfırla',
                    subtitle: 'Tüm aşamaları ve altını kalıcı sıfırlar',
                    icon: Icons.delete_forever,
                    color: const Color(0xFFFF5252),
                    onTap: () => _showResetConfirmDialog(context),
                  ),
                  const SizedBox(height: 16),

                  // 6. Destek & Geri Bildirim
                  _buildSectionHeader('💬 DESTEK & GERİ BİLDİRİM'),
                  _buildActionTile(
                    title: 'Nasıl Oynanır? (SSS)',
                    subtitle: 'Oyun kuralları ve taktikler',
                    icon: Icons.help_outline,
                    color: AppColors.goldText,
                    onTap: () => _showHowToPlayDialog(context),
                  ),
                  _buildActionTile(
                    title: 'Hata Bildir',
                    subtitle: 'Karşılaştığınız bir sorunu iletin',
                    icon: Icons.bug_report_outlined,
                    color: const Color(0xFF4FC3F7),
                    onTap: () => _showFeedbackDialog(context, 'Hata Bildir'),
                  ),
                  _buildActionTile(
                    title: 'Öneri Gönder',
                    subtitle: 'Görmek istediğiniz yeni fikirleri paylaşın',
                    icon: Icons.lightbulb_outline,
                    color: const Color(0xFFE040FB),
                    onTap: () => _showFeedbackDialog(context, 'Öneri Gönder'),
                  ),
                  const SizedBox(height: 16),

                  // 7. Hakkında
                  _buildSectionHeader('ℹ️ HAKKINDA'),
                  _buildInfoTile('Oyun Sürümü', 'v1.0.0 (Build 500)'),
                  _buildInfoTile('Geliştirici', 'Ölmez Tech — Oyun Tasarım Ekibi'),
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
        color: const Color(0xFF141436),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF242456)),
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
        color: const Color(0xFF141436),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF242456)),
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
              inactiveColor: const Color(0xFF2C2C64),
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
        color: const Color(0xFF141436),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF242456)),
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
                  backgroundColor: const Color(0xFF0C0C24),
                  onSelected: (_) => onSelected(opt),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: const Color(0xFF141436),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(color: color, fontSize: 12.5, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 1),
                      Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: color.withValues(alpha: 0.6), size: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF141436),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF242456)),
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
