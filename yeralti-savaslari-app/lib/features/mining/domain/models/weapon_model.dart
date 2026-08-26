enum WeaponType {
  pistol,
  rifle,
  shotgun,
  laserGun,
  rocketLauncher,
}

extension WeaponTypeExtension on WeaponType {
  String get displayName {
    switch (this) {
      case WeaponType.pistol:
        return 'Tabanca';
      case WeaponType.rifle:
        return 'Tüfek';
      case WeaponType.shotgun:
        return 'Pompalı';
      case WeaponType.laserGun:
        return 'Lazer Silahı';
      case WeaponType.rocketLauncher:
        return 'Roketatar';
    }
  }

  String get iconEmoji {
    switch (this) {
      case WeaponType.pistol:
        return '🔫';
      case WeaponType.rifle:
        return '⚡🔫';
      case WeaponType.shotgun:
        return '💥';
      case WeaponType.laserGun:
        return '🪄';
      case WeaponType.rocketLauncher:
        return '🚀';
    }
  }

  int get damage {
    switch (this) {
      case WeaponType.pistol:
        return 18;
      case WeaponType.rifle:
        return 32;
      case WeaponType.shotgun:
        return 48;
      case WeaponType.laserGun:
        return 65;
      case WeaponType.rocketLauncher:
        return 110;
    }
  }

  int get tileDamage {
    switch (this) {
      case WeaponType.pistol:
        return 6;
      case WeaponType.rifle:
        return 12;
      case WeaponType.shotgun:
        return 24;
      case WeaponType.laserGun:
        return 35;
      case WeaponType.rocketLauncher:
        return 60;
    }
  }

  int get maxAmmo {
    switch (this) {
      case WeaponType.pistol:
        return 15;
      case WeaponType.rifle:
        return 25;
      case WeaponType.shotgun:
        return 10;
      case WeaponType.laserGun:
        return 12;
      case WeaponType.rocketLauncher:
        return 6;
    }
  }

  int get goldPrice {
    switch (this) {
      case WeaponType.pistol:
        return 0; // Başlangıç silahı
      case WeaponType.rifle:
        return 800;
      case WeaponType.shotgun:
        return 1600;
      case WeaponType.laserGun:
        return 2800;
      case WeaponType.rocketLauncher:
        return 5000;
    }
  }

  int get gemPrice {
    switch (this) {
      case WeaponType.pistol:
        return 0;
      case WeaponType.rifle:
        return 0;
      case WeaponType.shotgun:
        return 5;
      case WeaponType.laserGun:
        return 15;
      case WeaponType.rocketLauncher:
        return 30;
    }
  }

  String get description {
    switch (this) {
      case WeaponType.pistol:
        return 'Standart hafif silah. Seri ve temel hasar verir.';
      case WeaponType.rifle:
        return 'Hızlı ve etkili menzilli tüfek. Düşmanlara iyi hasar verir.';
      case WeaponType.shotgun:
        return 'Ağır saçma hasarı! Kutuları ve düşmanları sarsar.';
      case WeaponType.laserGun:
        return 'Yüksek teknolojili enerji silahı. Sert zırhları deler geçer.';
      case WeaponType.rocketLauncher:
        return 'Devasa patlama gücü! Çok yüksek hasar ve blok parçalama.';
    }
  }
}
