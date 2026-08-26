enum BattlePhase {
  countdown,  // 3 Saniyelik Geri Sayım (3→2→1→BAŞLA!)
  scavenge,   // 3 Dakikalık Hazine & Alet Avı
  deathmatch, // 1 Dakikalık Ölümcül Serbest Dövüş (Kutular kalkar, vuruşlar güçlenir)
  finished,   // Oyun Bitti (Kazanan veya Beraberlik)
}

class BattlePhaseState {
  final BattlePhase phase;
  final int countdownSeconds; // 3, 2, 1
  final int phaseSecondsRemaining; // Faz süresi (ör: 180s, 60s)
  final String? winnerName;
  final bool isDraw;

  const BattlePhaseState({
    this.phase = BattlePhase.countdown,
    this.countdownSeconds = 3,
    this.phaseSecondsRemaining = 180, // 3 dk
    this.winnerName,
    this.isDraw = false,
  });

  bool get isCountdown => phase == BattlePhase.countdown;
  bool get isScavenge => phase == BattlePhase.scavenge;
  bool get isDeathmatch => phase == BattlePhase.deathmatch;
  bool get isFinished => phase == BattlePhase.finished;

  String get formattedTime {
    final int mins = phaseSecondsRemaining ~/ 60;
    final int secs = phaseSecondsRemaining % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  BattlePhaseState copyWith({
    BattlePhase? phase,
    int? countdownSeconds,
    int? phaseSecondsRemaining,
    String? winnerName,
    bool? isDraw,
  }) {
    return BattlePhaseState(
      phase: phase ?? this.phase,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      phaseSecondsRemaining: phaseSecondsRemaining ?? this.phaseSecondsRemaining,
      winnerName: winnerName ?? this.winnerName,
      isDraw: isDraw ?? this.isDraw,
    );
  }
}

