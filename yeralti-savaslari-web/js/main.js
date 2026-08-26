/**
 * Yeraltı Savaşları - Resmi Web Sitesi Javascript
 */

// 1. 10 Biyom & 500 Katman Veri Seti (Dart Kodundaki StageConfigService ile %100 Uyumlu)
const biomesData = [
  {
    id: 'biome_1',
    name: 'Kızıl Toprak Vadisi',
    tier: 'easy',
    tierLabel: 'Kolay',
    stages: 'Kat 1 - 50',
    grid: '13 x 23',
    hpMult: '1.00x → 1.15x',
    goldMult: '1.00x → 1.10x',
    mineChance: '%10',
    boss: 'Kat 50: Toprak Golemi (575 HP) | Her 10 Katta Mini-Boss',
    desc: 'Yeraltına ilk adım atılan bölge. Yumuşak toprak dokusu ve temel maden damarları bulunur. Yeni madenciler için ideal eğitim sahası.',
    note: 'Öğretici Katman'
  },
  {
    id: 'biome_2',
    name: 'Bakır Yamaçları',
    tier: 'medium',
    tierLabel: 'Orta',
    stages: 'Kat 51 - 100',
    grid: '15 x 25',
    hpMult: '1.18x → 1.30x',
    goldMult: '1.15x → 1.25x',
    mineChance: '%18 - %20',
    boss: 'Kat 100: Bakır Dev (650 HP) | Kat 60, 70, 80, 90 Mini-Boss',
    desc: 'Bakır ve demir yataklarının yoğunlaştığı sertleşen kayaç katmanı. Gizli mayın tuzakları sıklaşmaya başlar.',
    note: 'Bakır / Demir Dengesi'
  },
  {
    id: 'biome_3',
    name: 'Kömür Galerileri',
    tier: 'medium',
    tierLabel: 'Orta',
    stages: 'Kat 101 - 150',
    grid: '15 x 25',
    hpMult: '1.30x → 1.43x',
    goldMult: '1.25x → 1.35x',
    mineChance: '%20 - %22',
    boss: 'Kat 150: Karbon Muhafız (715 HP)',
    desc: 'Yoğun kömür ve yanıcı gaz damarları. Zincirleme TNT patlamaları ve alan temizliği için stratejik planlama gerektirir.',
    note: 'Zincirleme TNT Patlamaları'
  },
  {
    id: 'biome_4',
    name: 'Demir Kemer',
    tier: 'medium',
    tierLabel: 'Orta',
    stages: 'Kat 151 - 200',
    grid: '15 x 25',
    hpMult: '1.43x → 1.55x',
    goldMult: '1.35x → 1.45x',
    mineChance: '%22',
    boss: 'Kat 200: Zırhlı Demir Lordu (775 HP)',
    desc: 'Kırılması güç Solid Gold (kırılmaz blok) barikatlarıyla çevrili labirent yapıları. Yüksek seviye kazma şart!',
    note: 'Yüksek Solid Gold Engeli'
  },
  {
    id: 'biome_5',
    name: 'Zümrüt Mağaraları',
    tier: 'hard',
    tierLabel: 'Zor',
    stages: 'Kat 201 - 250',
    grid: '17 x 27',
    hpMult: '1.60x → 1.77x',
    goldMult: '1.55x → 1.70x',
    mineChance: '%24',
    boss: 'Kat 250: Zümrüt Kraliçesi (885 HP)',
    desc: 'Göz alıcı yeşil parıltılar ve 1.5x zümrüt oranı. Sandıklardan nadir Elmas Kazma düşme şansı artar.',
    note: '1.5x Zümrüt Oranı & Elmas Kazma'
  },
  {
    id: 'biome_6',
    name: 'Obsidyen Yarıkları',
    tier: 'hard',
    tierLabel: 'Zor',
    stages: 'Kat 251 - 300',
    grid: '17 x 27',
    hpMult: '1.78x → 1.95x',
    goldMult: '1.70x → 1.85x',
    mineChance: '%26',
    boss: 'Kat 300: Obsidyen Şövalyesi (975 HP)',
    desc: 'Cam gibi keskin obsidyen kaya blokları. Standart vuruşlar kaya direncine çarpar, ağır çekiç desteği şart.',
    note: 'Sert Kaya Dokusu (+%10)'
  },
  {
    id: 'biome_7',
    name: 'Ejder Damarı',
    tier: 'expert',
    tierLabel: 'Uzman',
    stages: 'Kat 301 - 350',
    grid: '17 x 27',
    hpMult: '2.00x → 2.17x',
    goldMult: '2.00x → 2.15x',
    mineChance: '%28',
    boss: 'Kat 350: Yeraltı Ejderhası (1085 HP)',
    desc: 'Efsanevi ejderha kalıntılarının bulunduğu derin çatlaklar. Gizli sandıklarda nadir aletler (%8 şansla) saklı.',
    note: 'Nadir Alet Ödülleri (%8)'
  },
  {
    id: 'biome_8',
    name: 'Buzul Çekirdeği',
    tier: 'expert',
    tierLabel: 'Uzman',
    stages: 'Kat 351 - 400',
    grid: '17 x 29',
    hpMult: '2.18x → 2.35x',
    goldMult: '2.15x → 2.35x',
    mineChance: '%30',
    boss: 'Kat 400: Donmuş Kolos (1175 HP)',
    desc: 'Dondurucu soğuk ve sert buz kristalleri enerjinizi zorlar (-%20 enerji ödülü). Yüksek tempolu ve dikkatli kazı gerektirir.',
    note: 'Kısık Enerji Ödülleri (-%20)'
  },
  {
    id: 'biome_9',
    name: 'Volkanik Uçurum',
    tier: 'chaos',
    tierLabel: 'Kaos',
    stages: 'Kat 401 - 450',
    grid: '17 x 31',
    hpMult: '2.45x → 2.82x',
    goldMult: '2.50x → 3.00x',
    mineChance: '%32 - %34',
    boss: 'Kat 450: Magma Hükümdarı (1410 HP)',
    desc: 'Her adımda kaynayan lav tuzakları ve patlayıcı mayınlar. Yüksek risk, devasa altın ve elmas ödülleri!',
    note: 'Tehlikeli Magma Tuzakları'
  },
  {
    id: 'biome_10',
    name: "Titan'ın Kalbi",
    tier: 'chaos',
    tierLabel: 'Kaos & Final',
    stages: 'Kat 451 - 500',
    grid: '17 x 31',
    hpMult: '2.83x → 3.20x',
    goldMult: '3.00x → 3.50x',
    mineChance: '%35',
    boss: '👑 KAT 500: BÜYÜK TİTAN (1120 HP Final Boss)',
    desc: 'Yeraltının en derin merkezi. 500. katta Büyük Titan Çekirdeği madencileri bekliyor! Yeraltının mutlak fatihi olmak için savaş.',
    note: 'BÜYÜK TİTAN FINAL BOSS (Kat 500)'
  }
];

// 2. Lobi Galeri Resimleri (Kullanıcı yeni fotoğraflar sağladığında buraya eklenecektir)
const lobbyGalleryImages = [
  'img/logo.jpg'
];

// Sayfa Yüklendiğinde Başlat
document.addEventListener('DOMContentLoaded', () => {
  initNavbar();
  initEmberCanvas();
  initBiomes();
  initTabs();
// initGallery();
});

// Navbar Scroll & Mobil Menü
function initNavbar() {
  const navbar = document.querySelector('.navbar');
  const mobileToggle = document.querySelector('.mobile-toggle');
  const navMenu = document.querySelector('.nav-menu');

  window.addEventListener('scroll', () => {
    if (window.scrollY > 40) {
      navbar.classList.add('scrolled');
    } else {
      navbar.classList.remove('scrolled');
    }
  });

  if (mobileToggle) {
    mobileToggle.addEventListener('click', () => {
      navMenu.classList.toggle('active');
      mobileToggle.textContent = navMenu.classList.contains('active') ? '✕' : '☰';
    });

    document.querySelectorAll('.nav-link').forEach(link => {
      link.addEventListener('click', () => {
        navMenu.classList.remove('active');
        mobileToggle.textContent = '☰';
      });
    });
  }
}

// Biyom Navigasyonu ve Detay Gösterimi
function initBiomes() {
  const navContainer = document.getElementById('biomes-nav');
  const detailContainer = document.getElementById('biome-detail');
  if (!navContainer || !detailContainer) return;

  // Butonları Oluştur
  navContainer.innerHTML = '';
  biomesData.forEach((biome, index) => {
    const btn = document.createElement('button');
    btn.className = `biome-tab-btn ${index === 0 ? 'active' : ''}`;
    btn.textContent = `${biome.stages.split(' ')[0]} ${biome.stages.split(' ')[1]}: ${biome.name}`;
    btn.addEventListener('click', () => {
      document.querySelectorAll('.biome-tab-btn').forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      renderBiomeDetail(biome);
    });
    navContainer.appendChild(btn);
  });

  // İlk Biyomu Göster
  renderBiomeDetail(biomesData[0]);
}

function renderBiomeDetail(biome) {
  const detailContainer = document.getElementById('biome-detail');
  if (!detailContainer) return;

  detailContainer.innerHTML = `
    <div class="biome-info">
      <span class="biome-badge tier-${biome.tier}">${biome.tierLabel.toUpperCase()} SEVİYE • ${biome.stages}</span>
      <h3>${biome.name}</h3>
      <p class="section-desc" style="text-align: left; margin: 0 0 16px 0;">${biome.desc}</p>
      
      <div class="biome-stats-grid">
        <div class="biome-stat-box">
          <div class="title">Izgara Boyutu</div>
          <div class="value text-cyan">${biome.grid}</div>
        </div>
        <div class="biome-stat-box">
          <div class="title">Blok HP Çarpanı</div>
          <div class="value text-lava">${biome.hpMult}</div>
        </div>
        <div class="biome-stat-box">
          <div class="title">Ödül / Altın Çarpanı</div>
          <div class="value text-gold">${biome.goldMult}</div>
        </div>
        <div class="biome-stat-box">
          <div class="title">Gizli Mayın Olasılığı</div>
          <div class="value text-green">${biome.mineChance}</div>
        </div>
      </div>

      <div class="boss-highlight">
        <div style="font-size: 0.85rem; color: var(--gold-text); font-weight: bold; text-transform: uppercase;">Biyom Boss & Tehdit</div>
        <div style="font-size: 1.1rem; color: #FFFFFF; font-weight: 700; margin-top: 4px;">${biome.boss}</div>
        <div style="font-size: 0.85rem; color: var(--text-secondary); margin-top: 4px;">📌 Özellik: ${biome.note}</div>
      </div>
    </div>
    
    <div class="biome-visual" style="display: flex; justify-content: center; align-items: center;">
      <div class="visual-frame" style="width: 100%; max-width: 400px; padding: 24px; text-align: center;">
        <div style="font-size: 4.5rem; margin-bottom: 12px;">🌋</div>
        <h4 style="font-size: 1.4rem; color: #FFFFFF; margin-bottom: 8px;">${biome.name}</h4>
        <p style="color: var(--gold-text); font-size: 0.95rem; font-weight: bold;">Derinlik: ${biome.stages}</p>
        <div style="margin-top: 16px; padding: 12px; background: rgba(14,10,20,0.8); border-radius: 8px; border: 1px dashed var(--border-glow); font-size: 0.85rem; color: var(--text-secondary);">
          Bu biyomda kazılan her blok, maden atölyesinde aletlerinizi güçlendirecek nadir cevherler barındırır.
        </div>
      </div>
    </div>
  `;
}

// Silahlar & Aletler Sekme Değişimi
function initTabs() {
  const switchBtns = document.querySelectorAll('.switch-btn');
  const weaponsGrid = document.getElementById('weapons-grid');
  const toolsGrid = document.getElementById('tools-grid');

  if (!switchBtns.length || !weaponsGrid || !toolsGrid) return;

  switchBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      switchBtns.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');

      const target = btn.getAttribute('data-target');
      if (target === 'weapons') {
        weaponsGrid.style.display = 'grid';
        toolsGrid.style.display = 'none';
      } else {
        weaponsGrid.style.display = 'none';
        toolsGrid.style.display = 'grid';
      }
    });
  });
}

// Galeri & Lobi Fotoğrafları
function initGallery() {
  const galleryGrid = document.getElementById('gallery-grid');
  if (!galleryGrid) return;

  galleryGrid.innerHTML = '';
  lobbyGalleryImages.forEach((src, idx) => {
    const item = document.createElement('div');
    item.className = 'gallery-item';
    item.innerHTML = `
      <img src="${src}" alt="Yeraltı Savaşları Ekran Görüntüsü ${idx + 1}">
      <div class="gallery-overlay">
        <span style="color: var(--gold-text); font-size: 1.5rem; font-weight: bold;">🔍 Yakınlaştır</span>
      </div>
    `;
    item.addEventListener('click', () => {
      window.open(src, '_blank');
    });
    galleryGrid.appendChild(item);
  });
}

// Kıvılcım (Ember / Lav Parçacıkları) Canvas Animasyonu
function initEmberCanvas() {
  const canvas = document.getElementById('ember-canvas');
  if (!canvas) return;
  const ctx = canvas.getContext('2d');

  let width = (canvas.width = window.innerWidth);
  let height = (canvas.height = window.innerHeight);

  window.addEventListener('resize', () => {
    width = canvas.width = window.innerWidth;
    height = canvas.height = window.innerHeight;
  });

  const particleCount = Math.min(50, Math.floor(width / 30));
  const particles = [];

  const colors = [
    'rgba(255, 87, 34, ',
    'rgba(255, 61, 0, ',
    'rgba(255, 179, 0, ',
    'rgba(255, 213, 79, '
  ];

  for (let i = 0; i < particleCount; i++) {
    particles.push({
      x: Math.random() * width,
      y: Math.random() * height,
      size: Math.random() * 2.5 + 1,
      speedY: Math.random() * 1.2 + 0.3,
      speedX: (Math.random() - 0.5) * 0.8,
      color: colors[Math.floor(Math.random() * colors.length)],
      opacity: Math.random() * 0.7 + 0.2,
      fadeSpeed: Math.random() * 0.01 + 0.005
    });
  }

  function render() {
    ctx.clearRect(0, 0, width, height);

    particles.forEach(p => {
      p.y -= p.speedY;
      p.x += p.speedX;
      p.opacity -= p.fadeSpeed;

      if (p.opacity <= 0 || p.y < 0) {
        p.y = height + 10;
        p.x = Math.random() * width;
        p.opacity = Math.random() * 0.7 + 0.3;
      }

      ctx.beginPath();
      ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
      ctx.fillStyle = p.color + p.opacity + ')';
      ctx.shadowBlur = 8;
      ctx.shadowColor = '#FF5722';
      ctx.fill();
    });

    requestAnimationFrame(render);
  }

  render();
}

