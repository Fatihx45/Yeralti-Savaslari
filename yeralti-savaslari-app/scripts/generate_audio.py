import math
import struct
import wave
import os
import random

SAMPLE_RATE = 44100

def write_wav(filename, samples):
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)  # Mono
        wav_file.setsampwidth(2)  # 16-bit
        wav_file.setframerate(SAMPLE_RATE)
        
        max_val = max(abs(s) for s in samples) if samples else 1.0
        if max_val == 0:
            max_val = 1.0
            
        data = bytearray()
        for s in samples:
            val = int((s / max_val) * 30000)
            val = max(-32767, min(32767, val))
            data.extend(struct.pack('<h', val))
            
        wav_file.writeframes(data)
    print(f"[OK] Ses uretildi: {filename} ({len(samples)/SAMPLE_RATE:.2f}s)")

# 1. Kazma ve Maden Vurma Sesi (dig.wav)
def generate_dig():
    duration = 0.18
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 28)
        sine = math.sin(2 * math.pi * 520 * t) * 0.5 + math.sin(2 * math.pi * 1240 * t) * 0.3
        noise = (random.random() * 2 - 1) * 0.5
        samples.append((sine + noise) * env)
    return samples

# 2. Tabanca Ateşi (shoot_pistol.wav)
def generate_pistol():
    duration = 0.22
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 22)
        freq = 380 * math.exp(-t * 30) + 90
        sine = math.sin(2 * math.pi * freq * t)
        noise = (random.random() * 2 - 1) * 0.7
        samples.append((sine * 0.4 + noise * 0.6) * env)
    return samples

# 3. Tüfek Ateşi (shoot_rifle.wav)
def generate_rifle():
    duration = 0.16
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 32)
        freq = 550 * math.exp(-t * 40) + 120
        sine = math.sin(2 * math.pi * freq * t)
        noise = (random.random() * 2 - 1) * 0.8
        samples.append((sine * 0.3 + noise * 0.7) * env)
    return samples

# 4. Pompalı Ateşi (shoot_shotgun.wav)
def generate_shotgun():
    duration = 0.35
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 14)
        freq = 240 * math.exp(-t * 18) + 60
        sine = math.sin(2 * math.pi * freq * t) * 0.6
        noise = (random.random() * 2 - 1) * 0.8
        samples.append((sine + noise) * env)
    return samples

# 5. Lazer Silahı (shoot_laser.wav)
def generate_laser():
    duration = 0.25
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 12)
        freq = 1400 * (1.0 - (t / duration) ** 0.5) + 180
        sine = math.sin(2 * math.pi * freq * t)
        harm = math.sin(2 * math.pi * (freq * 2) * t) * 0.3
        samples.append((sine + harm) * env)
    return samples

# 6. Roketatar Ateşi (shoot_rocket.wav)
def generate_rocket():
    duration = 0.45
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 8)
        freq = 90 + t * 200
        sine = math.sin(2 * math.pi * freq * t) * 0.5
        noise = (random.random() * 2 - 1) * 0.7
        samples.append((sine + noise) * env)
    return samples

# 7. Patlama (explosion.wav)
def generate_explosion():
    duration = 0.65
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 6)
        freq = 80 * math.exp(-t * 10) + 40
        sub_bass = math.sin(2 * math.pi * freq * t) * 0.7
        noise = (random.random() * 2 - 1) * 0.8
        samples.append((sub_bass + noise) * env)
    return samples

# 8. Altın & Elmas Toplama (gold_pickup.wav)
def generate_gold():
    duration = 0.35
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    notes = [1046.50, 1318.51, 1567.98, 2093.00]
    note_dur = duration / len(notes)
    
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        note_idx = min(int(t / note_dur), len(notes) - 1)
        freq = notes[note_idx]
        note_t = t - (note_idx * note_dur)
        env = math.exp(-note_t * 20)
        sine = math.sin(2 * math.pi * freq * t)
        samples.append(sine * env)
    return samples

# 9. Düşman Darbe Sesi (hit_enemy.wav)
def generate_hit():
    duration = 0.15
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 30)
        freq = 280 * math.exp(-t * 35) + 80
        sine = math.sin(2 * math.pi * freq * t)
        noise = (random.random() * 2 - 1) * 0.4
        samples.append((sine * 0.7 + noise * 0.3) * env)
    return samples

# 10. Canavar Kükreme (enemy_roar.wav)
def generate_roar():
    duration = 0.6
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        env = math.sin(math.pi * (t / duration)) ** 0.5
        mod = math.sin(2 * math.pi * 18 * t)
        freq = 110 + mod * 40
        saw = 2 * ((freq * t) % 1.0) - 1.0
        noise = (random.random() * 2 - 1) * 0.3
        samples.append((saw * 0.7 + noise * 0.3) * env)
    return samples

# 11. Güçlendirme / Demirci Başarı (upgrade_success.wav)
def generate_upgrade():
    duration = 0.55
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    notes = [659.25, 830.61, 987.77, 1318.51]
    note_dur = duration / len(notes)
    
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        note_idx = min(int(t / note_dur), len(notes) - 1)
        freq = notes[note_idx]
        note_t = t - (note_idx * note_dur)
        env = math.exp(-note_t * 12)
        sine = math.sin(2 * math.pi * freq * t)
        harm = math.sin(2 * math.pi * freq * 2 * t) * 0.3
        samples.append((sine + harm) * env)
    return samples

# 12. Bölüm Tamamlama (stage_clear.wav)
def generate_stage_clear():
    duration = 0.9
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    notes = [523.25, 659.25, 783.99, 1046.50, 1318.51]
    note_dur = duration / len(notes)
    
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        note_idx = min(int(t / note_dur), len(notes) - 1)
        freq = notes[note_idx]
        note_t = t - (note_idx * note_dur)
        env = math.exp(-note_t * 8)
        sine = math.sin(2 * math.pi * freq * t)
        samples.append(sine * env)
    return samples

# 13. Oyuncu Hasar Sesi (player_hurt.wav)
def generate_hurt():
    duration = 0.22
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 18)
        freq = 190 * math.exp(-t * 20) + 50
        sine = math.sin(2 * math.pi * freq * t)
        noise = (random.random() * 2 - 1) * 0.35
        samples.append((sine * 0.7 + noise * 0.3) * env)
    return samples

# 14. Buton Tıklama (button_click.wav)
def generate_click():
    duration = 0.06
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 70)
        sine = math.sin(2 * math.pi * 950 * t)
        samples.append(sine * env)
    return samples

# 15. Mağara Ambiyans Müziği (cave_bgm.wav)
def generate_cave_bgm():
    duration = 8.0
    num_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * num_samples
    
    for beat in range(8):
        start_idx = int(beat * 1.0 * SAMPLE_RATE)
        for i in range(int(0.4 * SAMPLE_RATE)):
            if start_idx + i < num_samples:
                t = i / SAMPLE_RATE
                env = math.exp(-t * 10)
                sine = math.sin(2 * math.pi * 75 * t) * 0.35
                samples[start_idx + i] += sine * env
                
    drips = [1.2, 2.7, 4.3, 5.8, 7.1]
    drip_freqs = [880, 1174, 1318, 987, 1046]
    for d_time, d_freq in zip(drips, drip_freqs):
        start_idx = int(d_time * SAMPLE_RATE)
        for i in range(int(0.25 * SAMPLE_RATE)):
            if start_idx + i < num_samples:
                t = i / SAMPLE_RATE
                env = math.exp(-t * 22)
                sine = math.sin(2 * math.pi * d_freq * t) * 0.2
                samples[start_idx + i] += sine * env
                
    return samples

def main():
    target_dir = os.path.join(os.path.dirname(__file__), '..', 'assets', 'sounds')
    os.makedirs(target_dir, exist_ok=True)
    
    generators = {
        'dig.wav': generate_dig,
        'shoot_pistol.wav': generate_pistol,
        'shoot_rifle.wav': generate_rifle,
        'shoot_shotgun.wav': generate_shotgun,
        'shoot_laser.wav': generate_laser,
        'shoot_rocket.wav': generate_rocket,
        'explosion.wav': generate_explosion,
        'gold_pickup.wav': generate_gold,
        'hit_enemy.wav': generate_hit,
        'enemy_roar.wav': generate_roar,
        'upgrade_success.wav': generate_upgrade,
        'stage_clear.wav': generate_stage_clear,
        'player_hurt.wav': generate_hurt,
        'button_click.wav': generate_click,
        'cave_bgm.wav': generate_cave_bgm,
    }
    
    print("Python Ses Sentezleme Motoru Baslatildi...")
    for name, gen in generators.items():
        file_path = os.path.join(target_dir, name)
        samples = gen()
        write_wav(file_path, samples)
    print("Tum oyun sesleri basariyla sentezlendi ve kaydedildi!")

if __name__ == '__main__':
    main()
