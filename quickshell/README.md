# 🐚 QuickShell + Hyprland Setup

> Une configuration **modulaire, customizable et performante** de QuickShell pour Hyprland.  
> A **modular, customizable, and performant** QuickShell configuration for Hyprland.

![Hyprland](https://img.shields.io/badge/Hyprland-Wayland-blue?logo=wayland)
![QuickShell](https://img.shields.io/badge/QuickShell-v0.2+-purple)
![Qt](https://img.shields.io/badge/Qt-6.x-blue?logo=qt)
![License](https://img.shields.io/badge/License-MIT-green)
![CI](https://github.com/valorisa/quickshell-hyprland/actions/workflows/ci.yml/badge.svg)

---

<!-- FR -->

## 🇫🇷 Français

### 🤔 C'est quoi tout ça ? — Pour les grands débutants

Si vous débutez sous Linux et que vous venez de découvrir Hyprland, ces quelques mots
vous aideront à comprendre pourquoi ce projet existe et ce qu'il fait concrètement.

#### Linux, bureau et compositeur — les bases

Sous Windows ou macOS, le bureau (fond d'écran, barre des tâches, fenêtres) est géré
par le système d'exploitation lui-même. Sous Linux, c'est différent : vous choisissez
vous-même le **compositeur de fenêtres** qui dessine votre bureau.

**Hyprland** est l'un de ces compositeurs. Il fonctionne avec le protocole moderne
**Wayland** (le remplaçant de l'ancien X11) et est réputé pour ses animations fluides
et sa configuration entièrement textuelle. Concrètement, Hyprland gère :

- l'affichage et le placement de vos fenêtres ;
- les espaces de travail (workspaces) ;
- les raccourcis clavier globaux ;
- les règles visuelles (arrondis, ombres, animations).

Ce qu'Hyprland ne fait **pas** par défaut : une barre de statut, un centre de contrôle,
des notifications, un affichage du volume. C'est là qu'intervient **QuickShell**.

#### QuickShell — c'est quoi ?

**QuickShell** est un outil qui permet de créer des éléments graphiques pour votre
bureau Linux à l'aide du langage **QML** (un langage déclaratif développé par Qt,
proche du JSON et du CSS). QuickShell s'appuie sur **Qt 6**, un framework graphique
très répandu, qui garantit des rendus fluides et accélérés par le GPU.

Avec QuickShell vous pouvez construire :

- une **barre de statut** (heure, CPU, RAM, espaces de travail) ;
- un **centre de contrôle** (WiFi, Bluetooth, volume, luminosité) ;
- des **notifications** qui apparaissent en haut de l'écran ;
- des **OSD** (On-Screen Display) — ces petites fenêtres qui s'affichent
  brièvement quand vous changez le volume ou la luminosité.

#### Ce projet — ce qu'il vous apporte

Ce dépôt est une **configuration prête à l'emploi** de QuickShell, conçue pour
fonctionner avec Hyprland. Au lieu de partir de zéro (ce qui demande des semaines
d'apprentissage du QML), vous installez ce projet et vous obtenez immédiatement :

- une barre élégante en haut de l'écran ;
- un centre de contrôle qui s'ouvre d'un clic ;
- des notifications desktop ;
- des OSD pour le volume et la luminosité ;
- une palette de couleurs dynamique grâce à `pywal` (les couleurs s'adaptent
  automatiquement à votre fond d'écran).

Vous pouvez ensuite personnaliser chaque détail — couleurs, tailles, comportements —
sans tout réécrire, car tout est structuré en composants indépendants.

---

### ✨ Fonctionnalités

| Fonctionnalité | Description |
| --- | --- |
| 🎨 **Thème dynamique** | Intégration `pywal` : la palette de couleurs est générée automatiquement depuis votre fond d'écran |
| 🧩 **Architecture modulaire** | Chaque widget (barre, OSD, notifications…) est un fichier QML indépendant, facile à modifier ou remplacer |
| 🔔 **Notifications** | Toasts discrets en haut à droite, avec auto-disparition et dismiss au clic |
| 🎛️ **Centre de contrôle** | Panel slide-down : toggles WiFi / Bluetooth / DND / Night mode + sliders volume & luminosité + actions système |
| ⌨️ **OSD** | Affichage animé volume & luminosité à chaque changement |
| 📊 **Stats système** | CPU, RAM, batterie en temps réel dans la barre |
| ✨ **Animations** | Toutes les transitions sont accélérées par le GPU via Qt 6 |

---

### 🗺️ Vue d'ensemble de l'architecture

Avant d'installer quoi que ce soit, voici comment les pièces s'assemblent :

```text
Hyprland (compositeur)
  └── lance QuickShell au démarrage
        └── lit shell.qml  ← point d'entrée
              ├── Bar            (barre du haut)
              │     ├── Workspaces   (espaces de travail)
              │     ├── MediaControl (lecteur MPRIS — Spotify, mpv…)
              │     ├── Clock        (horloge + date)
              │     └── SystemStats  (CPU / RAM / batterie)
              ├── ControlCenter  (panel WiFi, BT, volume…)
              ├── OSD            (popup volume/luminosité)
              └── NotificationCenter (toasts DBus)

Les services (singletons) sont partagés entre les modules :
  AudioService      → pactl / PipeWire
  BrightnessService → brightnessctl
  WifiService       → nmcli
  BluetoothService  → bluetoothctl
  NightService      → hyprsunset
  MediaService      → playerctl (MPRIS)

config/Colors.qml est dynamique : surveille colors.json (pywal) en continu.
components/ fournit GlowRect, BlurPanel, PulseGlow — effets visuels réutilisables.
```

Chaque bloc est un fichier `.qml` indépendant dans `modules/` ou `services/`.
La configuration (couleurs, tailles) est centralisée dans `config/`.

---

### 🛠️ Prérequis — ce dont vous avez besoin

#### Prérequis système

Vous devez avoir un système Linux avec **Hyprland déjà fonctionnel**.
Ce projet ne remplace pas Hyprland, il s'y ajoute.

Distributions recommandées pour débuter avec Hyprland :

- **Arch Linux** ou **Manjaro** (paquets les plus à jour) ✅ recommandé
- **EndeavourOS** (installateur graphique + Arch underneath) ✅ facile
- **NixOS** (configuration déclarative, utilisateurs avancés)
- **Ubuntu / Debian** (possible mais demande de compiler depuis les sources)

#### Dépendances — explication de chaque paquet

| Paquet | Rôle | Obligatoire ? |
| --- | --- | --- |
| `quickshell` | Le moteur qui exécute les fichiers QML | ✅ Oui |
| `qt6-base` | Bibliothèque Qt 6 de base | ✅ Oui |
| `qt6-declarative` | Moteur QML (langage des fichiers `.qml`) | ✅ Oui |
| `qt6-wayland` | Support Wayland pour Qt 6 | ✅ Oui |
| `qt6-svg` | Support des icônes SVG | ✅ Oui |
| `hyprland` | Le compositeur de fenêtres | ✅ Oui |
| `python-pywal` | Génère une palette de couleurs depuis un fond d'écran | ✅ Recommandé |
| `jq` | Parsing JSON pour `wal-to-qml.sh` (export debug palette) | ✅ Recommandé |
| `pipewire` | Serveur audio moderne (remplace PulseAudio) | ✅ Oui |
| `wireplumber` | Gestionnaire de sessions PipeWire | ✅ Oui |
| `networkmanager` | Gestion WiFi / Ethernet | ✅ Oui |
| `bluez` + `bluez-utils` | Pile Bluetooth + outils CLI (`bluetoothctl`) | ⚡ Si vous utilisez le Bluetooth |
| `upower` | Informations batterie | ⚡ Si vous êtes sur laptop |
| `brightnessctl` | Contrôle de la luminosité de l'écran | ⚡ Si vous êtes sur laptop |
| `grim` | Capture d'écran (screenshot) | ⚡ Optionnel |
| `slurp` | Sélection de zone pour screenshot | ⚡ Optionnel |
| `playerctl` | Contrôle des lecteurs multimédia (Spotify, mpv…) | ✅ Oui — MediaControl |
| `hyprsunset` | Mode nuit (filtre lumière bleue) | ⚡ Optionnel |

#### Arch Linux (ou Manjaro / EndeavourOS)

```bash
yay -S quickshell qt6-base qt6-declarative qt6-wayland qt6-svg \
        hyprland python-pywal jq \
        pipewire wireplumber \
        networkmanager \
        bluez bluez-utils \
        upower brightnessctl \
        grim slurp playerctl \
        hyprsunset
```

> **Note :** `yay` est un helper AUR. Si vous n'avez que `pacman`, remplacez `yay` par
> `sudo pacman` — `quickshell` est disponible dans les dépôts officiels d'Arch.

#### Ubuntu / Debian (EN)

Voir [`docs/INSTALLATION.md`](docs/INSTALLATION.md) pour les instructions détaillées
de compilation depuis les sources (QuickShell n'est pas dans les dépôts Debian/Ubuntu).

---

### 🚀 Installation FR

#### Étape 1 — Cloner le dépôt

QuickShell cherche sa configuration dans `~/.config/quickshell/`.
On clone donc directement à cet emplacement :

```bash
git clone https://github.com/valorisa/quickshell-hyprland.git \
    ~/.config/quickshell
```

> **Pourquoi `~/.config/quickshell/` ?**  
> `~` désigne votre dossier personnel (`/home/votrenom`).  
> `~/.config/` est le dossier standard Linux pour les configurations d'applications.  
> QuickShell lit automatiquement `~/.config/quickshell/shell.qml` au démarrage.

#### Étape 2 — Lancer le setup automatique

```bash
cd ~/.config/quickshell
chmod +x scripts/setup.sh   # rend le script exécutable
./scripts/setup.sh          # installe les dépendances et configure l'environnement
```

Le script `setup.sh` fait les choses suivantes automatiquement :

1. Détecte votre distribution (Arch ou Debian/Ubuntu)
2. Installe les paquets manquants
3. Crée un lien symbolique si nécessaire
4. Génère une palette de couleurs si un fond d'écran est trouvé
5. Ajoute `exec-once = quickshell` à votre `hyprland.conf`

> **Vous pouvez tester sans rien modifier** avec `./scripts/setup.sh --dry-run`.
> Le script affichera ce qu'il ferait, sans rien exécuter.

#### Étape 3 — Générer votre palette de couleurs

```bash
wal -i /chemin/vers/votre/fond-decran.jpg
```

`pywal` analyse les couleurs dominantes de votre image et génère une palette
cohérente. QuickShell utilisera ces couleurs pour teinter la barre, les widgets, etc.

Exemple avec une image dans votre dossier Images :

```bash
wal -i ~/Images/wallpaper.jpg
```

#### Étape 4 — Redémarrer Hyprland (ou lancer QuickShell manuellement)

```bash
# Lancer QuickShell directement (pour tester sans redémarrer)
quickshell

# Ou recharger Hyprland pour que exec-once prenne effet
hyprctl reload
```

---

### 🎨 Thème dynamique pywal — fonctionnement détaillé

Depuis la version 0.4.0, **`config/Colors.qml` est dynamique**. Au lieu d'une palette
figée, ce fichier surveille en permanence `~/.cache/wal/colors.json` (généré par
`pywal`) et met à jour les couleurs de toute l'interface **automatiquement, sans
redémarrer QuickShell**.

#### Comment ça marche concrètement ?

1. Toutes les 2 secondes, QuickShell vérifie la date de modification de
   `~/.cache/wal/colors.json`.
2. Si le fichier a changé (ou vient d'apparaître), il est relu et sa palette
   (16 couleurs ANSI + couleurs spéciales `background`/`foreground`) est appliquée
   directement aux propriétés de `Colors.qml`.
3. Tous les widgets qui utilisent `Colors.colBg`, `Colors.colAccent`, etc. se
   redessinent instantanément avec les nouvelles couleurs.
4. Si vous supprimez `~/.cache/wal/colors.json`, l'interface revient automatiquement
   à la palette statique Catppuccin Macchiato après ~2 secondes.

#### Utilisation manuelle (à la demande)

```bash
wal -i /chemin/vers/wallpaper.jpg
```

C'est tout — pas besoin de relancer QuickShell. Les couleurs changent dans les 2
secondes qui suivent.

#### Utilisation via le script du projet (recommandé)

```bash
~/.config/quickshell/scripts/wal-gen.sh /chemin/vers/wallpaper.jpg
```

Ce script fait trois choses :

1. Lance `wal -i` avec un réglage de saturation adapté (`--saturate 0.7`)
2. Exporte un instantané lisible de la palette dans `config/ColorsWal.qml`
   (fichier de référence/debug, **non utilisé par le moteur** — `Colors.qml` lit
   directement `colors.json`)
3. Recharge QuickShell par sécurité (pour les widgets non couverts par le live-reload)

#### Mapping des couleurs pywal → propriétés Colors.qml

| Propriété `Colors.qml` | Source pywal | Rôle |
| --- | --- | --- |
| `colBg` | `special.background` | Fond principal |
| `colFg` | `special.foreground` | Texte principal |
| `colBgAlt` | `color0` | Fond plus sombre (barres, champs) |
| `colSurface` | `color8` | Surfaces de cartes/widgets |
| `colBorder` | `color7` | Bordures |
| `colFgMuted` | `color7` | Texte secondaire |
| `colAccent` | `color12` | Accent principal (boutons actifs, curseurs) |
| `colBlue` | `color4` | Bleu |
| `colGreen` | `color2` | Vert |
| `colYellow` | `color3` | Jaune |
| `colRed` / `colError` | `color1` | Rouge / fond d'erreur |

#### Vérifier que le thème dynamique fonctionne

```bash
# Vérifier que pywal a bien généré le fichier
cat ~/.cache/wal/colors.json | jq .

# Inspecter la palette actuellement appliquée (snapshot debug)
cat ~/.config/quickshell/config/ColorsWal.qml
```

> **Note :** `jq` est requis pour `wal-to-qml.sh`. S'il est absent, le thème
> dynamique fonctionne quand même (lecture native en QML) — seul l'export
> `ColorsWal.qml` sera ignoré.

---

### ✨ Effets visuels (Glow & Blur) — fonctionnement détaillé

La version 0.4.0 introduit trois composants réutilisables dans `components/`
pour des effets visuels modernes — halos lumineux et flou "verre dépoli" — sans
dépendance externe lourde (basés sur `QtQuick.Effects.MultiEffect`, inclus avec
`qt6-declarative`).

#### `GlowRect` — halo statique

Un halo coloré et flouté autour d'un élément, qui s'active/désactive avec un fondu.
Utilisé partout où un état "actif" doit être mis en valeur.

```qml
GlowRect {
    anchors.fill: someToggle
    active:    someToggle.active
    glowColor: Colors.colAccent
    intensity: 0.45
}
```

#### `BlurPanel` — fond "verre dépoli"

Un fond semi-transparent et flouté, teinté avec `Colors.colSurface` (donc
**compatible avec le thème pywal dynamique**). Utilisé pour le fond du
**ControlCenter**.

```qml
BlurPanel {
    anchors.fill: parent
    radius: Sizes.radius
    tintAlpha: 0.92

    ColumnLayout {
        // votre contenu ici
    }
}
```

#### `PulseGlow` — halo animé (shader custom)

Le composant le plus avancé : un anneau lumineux **pulsant** via un shader GLSL
personnalisé (`assets/shaders/pulseglow.frag`).

**Comportement à deux niveaux :**

- **Avec shader compilé** (`pulseglow.frag.qsb` présent) : animation pulsée fluide,
  pilotée par le GPU.
- **Sans shader compilé** (cas par défaut) : `PulseGlow` bascule automatiquement
  sur `GlowRect` — halo statique, sans erreur ni écran noir.

**Compiler le shader (optionnel) :**

```bash
# Nécessite qt6-shadertools (qsb)
qsb --glsl "100 es,120,150" \
    -o ~/.config/quickshell/assets/shaders/pulseglow.frag.qsb \
    ~/.config/quickshell/assets/shaders/pulseglow.frag
```

Une fois compilé, **aucun redémarrage requis** — `PulseGlow` détecte le fichier
au prochain affichage du composant.

**Où ces effets sont-ils utilisés actuellement ?**

| Composant | Emplacement | Effet |
| --- | --- | --- |
| `PulseGlow` | `CCToggle` (WiFi/BT/DND/Night actifs) | Halo coloré pulsé derrière le toggle actif |
| `BlurPanel` | `ControlCenter` | Fond flouté teinté, remplace le fond uni |
| `PulseGlow` | `NotificationItem` (urgence critique) | Halo rouge pulsé autour du toast |

---

### 🎵 Le widget MediaControl — fonctionnement détaillé

Si vous écoutez de la musique avec **Spotify**, **mpv**, **VLC**, ou même un onglet
audio dans **Firefox/Chromium**, un petit lecteur apparaît automatiquement dans la
barre, juste après les espaces de travail.

#### Comment ça fonctionne ?

Le widget utilise **MPRIS** (Media Player Remote Interfacing Specification), un
standard DBus que la plupart des lecteurs Linux implémentent. En coulisses, QuickShell
appelle l'outil `playerctl` toutes les secondes pour récupérer :

- le titre de la piste en cours ;
- l'artiste ;
- l'état (lecture / pause) ;
- le nom du lecteur actif.

#### Que voit-on dans la barre ?

```text
 ⏮  ⏯  ⏭   Nom de la piste — Artiste
```

| Élément | Action |
| --- | --- |
| ⏮ (précédent) | `playerctl previous` — piste précédente |
| ⏯ (lecture/pause) | `playerctl play-pause` — bascule lecture/pause, icône mise en accent |
| ⏭ (suivant) | `playerctl next` — piste suivante |
| Texte titre — artiste | Tronqué automatiquement si trop long (max ~220px) |

#### Et si rien ne joue ?

**Le widget disparaît complètement.** Aucune icône grisée, aucun espace réservé :
si `playerctl` ne détecte aucun lecteur MPRIS actif, le widget a une largeur de `0`
et n'occupe aucune place dans la barre. Dès qu'un lecteur démarre, il réapparaît
automatiquement (délai maximum : 1 seconde, le temps du prochain sondage).

#### Lecteurs testés / compatibles

- **Spotify** (client officiel Linux) ✅
- **mpv** — nécessite l'option `--input-ipc-server` ou le plugin `mpris` activé ✅
- **VLC** — MPRIS activé par défaut sur la plupart des distributions ✅
- **Firefox / Chromium** — onglets avec lecture audio/vidéo ✅
- Tout autre lecteur compatible MPRIS2

#### Dépannage spécifique

Si le widget ne s'affiche jamais alors que de la musique joue :

```bash
# Vérifier que playerctl détecte le lecteur
playerctl status

# Lister tous les lecteurs MPRIS actifs
playerctl -l
```

Si `playerctl -l` est vide alors que Spotify/mpv joue, le lecteur n'expose pas
son interface MPRIS — vérifiez sa configuration ou ses plugins.

---

### 🎛️ Le Centre de contrôle — fonctionnement détaillé

Le centre de contrôle s'ouvre en cliquant sur l'icône `󰍜` en haut à droite de la barre.
Il se referme en cliquant à nouveau dessus, ou en appuyant sur `Échap`.

Il contient quatre zones :

**1. Les toggles** — rangée de 4 boutons carrés :

| Bouton | Action | Commande système |
| --- | --- | --- |
| 󰤨 Wi-Fi | Active / désactive le WiFi | `nmcli radio wifi on/off` |
| 󰂯 BT | Active / désactive le Bluetooth | `bluetoothctl power on/off` |
| 󰂛 DND | Mode "Ne pas déranger" (bloque les notifications) | État interne QML |
| 󰌵 Night | Mode nuit — filtre lumière bleue | `hyprsunset -t 3500` |

**2. Les sliders** — deux barres de réglage :

- **Volume** : faites glisser pour ajuster, cliquez sur l'icône pour couper le son
- **Luminosité** : faites glisser pour ajuster (laptop uniquement)

**3. Les infos réseau** — SSID WiFi actuel + adresse IP locale

**4. Les actions système** — trois boutons : Éteindre / Redémarrer / Se déconnecter

---

### 🔧 Personnalisation

#### Changer les couleurs

Ouvrez `~/.config/quickshell/config/Colors.qml` :

```qml
// Couleur de fond de la barre
readonly property color colBg:      "#282c38"

// Couleur principale du texte
readonly property color colFg:      "#cad3f5"

// Couleur d'accentuation (boutons actifs, curseur slider…)
readonly property color colAccent:  "#8aadf4"

// Vert (batterie, confirmations)
readonly property color colGreen:   "#a6da95"

// Jaune (avertissements, mode nuit)
readonly property color colYellow:  "#eed49f"
```

Modifiez les valeurs hexadécimales (`#rrggbb`), sauvegardez, puis rechargez :

```bash
~/.config/quickshell/scripts/reload.sh
```

#### Changer la hauteur de la barre

Ouvrez `~/.config/quickshell/config/Sizes.qml` :

```qml
readonly property int barHeight: 40   // hauteur en pixels
readonly property int barSpacing: 12  // espacement entre les widgets
```

#### Recharger après modification

```bash
~/.config/quickshell/scripts/reload.sh
```

Ce script tente d'abord un rechargement via IPC (sans perdre l'état),
et bascule sur un redémarrage propre si l'IPC n'est pas disponible.

#### Regénérer les couleurs depuis un nouveau fond d'écran

```bash
~/.config/quickshell/scripts/wal-gen.sh /chemin/vers/nouveau-fond.jpg
```

---

### 📂 Structure complète du projet

```text
~/.config/quickshell/
│
├── shell.qml                      ← Point d'entrée : charge tous les modules
│
├── config/
│   ├── Colors.qml                 ← Palette dynamique (pywal auto-reload, modifiez les fallbacks ici)
│   ├── ColorsWal.qml              ← Snapshot debug généré par wal-to-qml.sh (gitignored)
│   ├── Sizes.qml                  ← Dimensions et durées d'animation
│   └── qmldir                    ← Déclare Colors et Sizes comme singletons
│
├── modules/
│   ├── Bar/
│   │   ├── Bar.qml               ← Barre principale (layout général)
│   │   ├── Workspaces.qml        ← Indicateurs d'espaces de travail Hyprland
│   │   ├── MediaControl.qml      ← Widget MPRIS (titre/artiste + contrôles)
│   │   ├── MCButton.qml          ← Bouton icône réutilisable (prev/play/next)
│   │   ├── Clock.qml             ← Horloge + date
│   │   └── SystemStats.qml       ← CPU / RAM / batterie
│   │
│   ├── ControlCenter/
│   │   ├── ControlCenter.qml     ← Panel principal (slide-down, fond BlurPanel)
│   │   ├── CCToggle.qml          ← Bouton toggle réutilisable (PulseGlow si actif)
│   │   ├── CCSlider.qml          ← Slider réutilisable
│   │   ├── CCNetworkInfo.qml     ← SSID + IP
│   │   └── CCActionButton.qml    ← Boutons power/reboot/logout
│   │
│   ├── Notifications/
│   │   ├── NotificationCenter.qml ← Serveur DBus + colonne de toasts
│   │   └── NotificationItem.qml  ← Un toast individuel (PulseGlow si urgence critique)
│   │
│   └── OSD/
│       └── OSD.qml               ← Popup volume / luminosité
│
├── services/
│   ├── AudioService.qml          ← Volume & mute via pactl (PipeWire)
│   ├── BrightnessService.qml     ← Luminosité via brightnessctl
│   ├── WifiService.qml           ← WiFi via nmcli
│   ├── BluetoothService.qml      ← Bluetooth via bluetoothctl
│   ├── NightService.qml          ← Mode nuit via hyprsunset
│   ├── MediaService.qml          ← Lecteur média MPRIS via playerctl
│   └── qmldir                   ← Déclare tous les services comme singletons
│
├── assets/
│   ├── icons/                    ← Icônes personnalisées (SVG)
│   ├── shaders/
│   │   └── pulseglow.frag        ← Shader GLSL custom (halo pulsé animé)
│   ├── wallpapers/               ← Fonds d'écran (non versionnés)
│   └── fonts/                   ← Polices recommandées
│
├── components/
│   ├── GlowRect.qml              ← Halo statique (MultiEffect)
│   ├── BlurPanel.qml             ← Fond "verre dépoli" (MultiEffect)
│   ├── PulseGlow.qml             ← Halo animé (shader + fallback GlowRect)
│   └── qmldir                   ← Déclare les composants réutilisables
│
├── scripts/
│   ├── setup.sh                  ← Installation automatique des dépendances
│   ├── reload.sh                 ← Rechargement de QuickShell (IPC ou restart)
│   ├── wal-gen.sh                ← Génération palette pywal + reload
│   └── backup.sh                 ← Sauvegarde de la configuration
│
├── docs/
│   ├── INSTALLATION.md           ← Guide détaillé (Debian/Ubuntu, sources)
│   └── gallery/                  ← Captures d'écran
│
├── hyprland-layer-config.conf    ← Règles Hyprland (blur, animations layer shell)
├── .gitattributes                ← Normalisation des fins de ligne (LF)
├── .gitignore                    ← Fichiers exclus du versionnement
├── .markdownlint.json            ← Configuration du linter Markdown
├── CHANGELOG.md                  ← Historique des versions
└── LICENSE                       ← Licence MIT
```

---

### 🐛 Dépannage

#### Problèmes courants et solutions

| Problème | Cause probable | Solution |
| --- | --- | --- |
| La barre n'apparaît pas | QuickShell ne se lance pas | Vérifier avec `quickshell` en terminal : lire l'erreur |
| Couleurs grises / manquantes | `pywal` non configuré | Lancer `wal -i /chemin/wallpaper.jpg` |
| Animations saccadées | Config Hyprland manquante | Vérifier que `hyprland-layer-config.conf` est sourcé |
| Volume ne répond pas | PipeWire inactif | `systemctl --user start pipewire wireplumber` |
| WiFi toggle sans effet | NetworkManager inactif | `sudo systemctl start NetworkManager` |
| Luminosité bloquée | `brightnessctl` absent ou droits insuffisants | `sudo usermod -aG video $USER` puis reconnexion |
| Bluetooth toggle sans effet | Service Bluetooth inactif | `sudo systemctl start bluetooth` |
| OSD n'apparaît pas | Conflit de layer shell | Vérifier les règles `layerrule` dans `hyprland-layer-config.conf` |

#### Vérifier que QuickShell tourne

```bash
pgrep -a quickshell
```

#### Lire les logs en direct

```bash
quickshell 2>&1 | tee /tmp/qs.log
```

#### Recharger proprement

```bash
~/.config/quickshell/scripts/reload.sh
```

---

### 🗺️ Roadmap

- [x] Bar — Workspaces, Clock, SystemStats
- [x] OSD — Volume & Brightness
- [x] Notifications — DBus toasts
- [x] ControlCenter — WiFi, Bluetooth, DND, Night, audio, brightness, power actions
- [x] MediaControl — MPRIS (Spotify, mpv, VLC, browsers)
- [x] pywal dynamic color reload
- [x] Custom shaders (glow & blur)

---

## 📄 License

MIT — see [LICENSE](LICENSE)

## 🤝 Contributing

Issues et PRs bienvenus. Voir [`docs/INSTALLATION.md`](docs/INSTALLATION.md)
pour la mise en place de l'environnement de développement.

---

**Author**: [valorisa](https://github.com/valorisa)

---

<!-- EN -->

## 🇬🇧 English

### 🤔 What is all this? — For complete beginners

If you are new to Linux and just discovered Hyprland, this section explains what this
project does and why it exists.

#### Linux, desktops, and compositors — the basics

On Windows or macOS, the desktop (wallpaper, taskbar, windows) is managed by the
operating system. On Linux it is different: you choose your own **window compositor**,
which draws everything on screen.

**Hyprland** is one such compositor. It runs on the modern **Wayland** protocol
(the successor to the older X11 system) and is known for smooth animations and
a fully text-based configuration. Hyprland manages:

- displaying and tiling your windows;
- workspaces (virtual desktops);
- global keyboard shortcuts;
- visual rules (rounded corners, shadows, animations).

What Hyprland does **not** provide out of the box: a status bar, a control panel,
desktop notifications, or a volume display. That is what **QuickShell** is for.

#### QuickShell — what is it?

**QuickShell** is a tool for building graphical desktop elements using **QML**
(a declarative language developed by Qt, similar in feel to JSON + CSS).
It is powered by **Qt 6**, a widely used graphics framework, ensuring GPU-accelerated,
smooth rendering.

With QuickShell you can build:

- a **status bar** (clock, CPU, RAM, workspaces);
- a **control center** (WiFi, Bluetooth, volume, brightness);
- **notifications** that appear on screen;
- **OSD** (On-Screen Display) popups for volume and brightness changes.

#### This project — what it gives you

This repository is a **ready-to-use QuickShell configuration** designed for Hyprland.
Instead of starting from scratch (which requires weeks of QML study), you install
this project and immediately get:

- a polished bar at the top of the screen;
- a control center panel that opens with one click;
- desktop notifications;
- OSD popups for volume and brightness;
- a dynamic color palette via `pywal` (colors automatically match your wallpaper).

You can then customize every detail — colors, sizes, behaviors — without rewriting
everything, because each piece is an independent, well-documented component.

---

### ✨ Features

| Feature | Description |
| --- | --- |
| 🎨 **Dynamic theming** | `pywal` generates a color palette from your wallpaper automatically |
| 🧩 **Modular architecture** | Each widget is an independent QML file — easy to edit or swap |
| 🔔 **Notifications** | Unobtrusive top-right toasts, auto-dismiss, click to close |
| 🎛️ **Control Center** | Slide-down panel: WiFi / Bluetooth / DND / Night toggles, audio & brightness sliders, system actions |
| ⌨️ **OSD** | Animated volume & brightness popup on every change |
| 📊 **System stats** | Real-time CPU, RAM, battery in the bar |
| ✨ **Animations** | All transitions GPU-accelerated via Qt 6 |

---

### 🗺️ Architecture overview

```text
Hyprland (compositor)
  └── launches QuickShell on startup
        └── reads shell.qml  ← entry point
              ├── Bar            (top bar)
              │     ├── Workspaces   (workspace indicators)
              │     ├── MediaControl (MPRIS player — Spotify, mpv…)
              │     ├── Clock        (clock + date)
              │     └── SystemStats  (CPU / RAM / battery)
              ├── ControlCenter  (WiFi, BT, volume panel)
              ├── OSD            (volume/brightness popup)
              └── NotificationCenter (DBus toasts)

Services (singletons) shared across modules:
  AudioService      → pactl / PipeWire
  BrightnessService → brightnessctl
  WifiService       → nmcli
  BluetoothService  → bluetoothctl
  NightService      → hyprsunset
  MediaService      → playerctl (MPRIS)

config/Colors.qml is dynamic: continuously watches colors.json (pywal).
components/ provides GlowRect, BlurPanel, PulseGlow — reusable visual effects.
```

---

### 🛠️ Prerequisites

#### System requirements

You need a working Linux system with **Hyprland already installed and running**.
This project adds to Hyprland — it does not replace it.

Recommended distributions for Hyprland beginners:

- **Arch Linux** or **Manjaro** (most up-to-date packages) ✅ recommended
- **EndeavourOS** (graphical installer + Arch underneath) ✅ easy start
- **NixOS** (declarative configuration, advanced users)
- **Ubuntu / Debian** (possible but requires compiling from source)

#### Package reference

| Package | Purpose | Required? |
| --- | --- | --- |
| `quickshell` | The engine that runs QML files | ✅ Yes |
| `qt6-base` | Qt 6 base library | ✅ Yes |
| `qt6-declarative` | QML engine | ✅ Yes |
| `qt6-wayland` | Wayland support for Qt 6 | ✅ Yes |
| `qt6-svg` | SVG icon support | ✅ Yes |
| `hyprland` | The window compositor | ✅ Yes |
| `python-pywal` | Generates a color palette from your wallpaper | ✅ Recommended |
| `jq` | JSON parsing for `wal-to-qml.sh` (debug palette export) | ✅ Recommended |
| `pipewire` | Modern audio server | ✅ Yes |
| `wireplumber` | PipeWire session manager | ✅ Yes |
| `networkmanager` | WiFi / Ethernet management | ✅ Yes |
| `bluez` + `bluez-utils` | Bluetooth stack + CLI tools | ⚡ If using Bluetooth |
| `upower` | Battery information | ⚡ Laptop only |
| `brightnessctl` | Screen brightness control | ⚡ Laptop only |
| `grim` | Screenshot tool | ⚡ Optional |
| `slurp` | Region selection for screenshots | ⚡ Optional |
| `playerctl` | Media player control (Spotify, mpv…) | ✅ Yes — MediaControl |
| `hyprsunset` | Night mode (blue light filter) | ⚡ Optional |

#### Arch Linux (EN)

```bash
yay -S quickshell qt6-base qt6-declarative qt6-wayland qt6-svg \
        hyprland python-pywal jq \
        pipewire wireplumber \
        networkmanager \
        bluez bluez-utils \
        upower brightnessctl \
        grim slurp playerctl \
        hyprsunset
```

#### Ubuntu / Debian — compile from source

See [`docs/INSTALLATION.md`](docs/INSTALLATION.md) for step-by-step compile
instructions (QuickShell is not in Debian/Ubuntu repositories).

---

### 🚀 Installation EN

#### Step 1 — Clone the repository

QuickShell looks for its configuration in `~/.config/quickshell/`.
Clone directly to that path:

```bash
git clone https://github.com/valorisa/quickshell-hyprland.git \
    ~/.config/quickshell
```

#### Step 2 — Run the automated setup

```bash
cd ~/.config/quickshell
chmod +x scripts/setup.sh   # make the script executable
./scripts/setup.sh           # installs dependencies and configures the environment
```

What `setup.sh` does automatically:

1. Detects your distribution (Arch or Debian/Ubuntu)
2. Installs any missing packages
3. Creates a symlink if needed
4. Generates a color palette if a wallpaper is found at `~/wallpaper.jpg`
5. Adds `exec-once = quickshell` to your `hyprland.conf`

> Test without making any changes: `./scripts/setup.sh --dry-run`

#### Step 3 — Generate your color palette

```bash
wal -i /path/to/your/wallpaper.jpg
```

`pywal` analyzes the dominant colors in your image and produces a coherent palette.
QuickShell uses those colors to tint the bar, widgets, and panels.

#### Step 4 — Restart Hyprland or launch QuickShell manually

```bash
# Test immediately without restarting
quickshell

# Or reload Hyprland so exec-once takes effect
hyprctl reload
```

---

### 🎨 Dynamic pywal theming — detailed walkthrough

Since version 0.4.0, **`config/Colors.qml` is dynamic**. Instead of a fixed palette,
this file continuously watches `~/.cache/wal/colors.json` (generated by `pywal`)
and updates the entire UI's colors **automatically, with no QuickShell restart**.

#### How does it actually work?

1. Every 2 seconds, QuickShell checks the modification time of
   `~/.cache/wal/colors.json`.
2. If the file changed (or just appeared), it is re-read and its palette
   (16 ANSI colors + `background`/`foreground` specials) is applied directly
   to `Colors.qml`'s properties.
3. Every widget using `Colors.colBg`, `Colors.colAccent`, etc. redraws instantly
   with the new colors.
4. If you delete `~/.cache/wal/colors.json`, the UI automatically reverts to the
   static Catppuccin Macchiato fallback palette after ~2 seconds.

#### Manual usage (on demand)

```bash
wal -i /path/to/wallpaper.jpg
```

That's it — no need to restart QuickShell. Colors update within 2 seconds.

#### Using the project script (recommended)

```bash
~/.config/quickshell/scripts/wal-gen.sh /path/to/wallpaper.jpg
```

This script does three things:

1. Runs `wal -i` with a tuned saturation setting (`--saturate 0.7`)
2. Exports a human-readable palette snapshot to `config/ColorsWal.qml`
   (a debug/reference file, **not used by the engine** — `Colors.qml` reads
   `colors.json` directly)
3. Reloads QuickShell as a safety net (for any widgets outside the live-reload path)

#### pywal color → Colors.qml property mapping

| `Colors.qml` property | pywal source | Role |
| --- | --- | --- |
| `colBg` | `special.background` | Main background |
| `colFg` | `special.foreground` | Main text |
| `colBgAlt` | `color0` | Darker background (bars, inputs) |
| `colSurface` | `color8` | Card/widget surfaces |
| `colBorder` | `color7` | Borders |
| `colFgMuted` | `color7` | Secondary text |
| `colAccent` | `color12` | Primary accent (active buttons, cursors) |
| `colBlue` | `color4` | Blue |
| `colGreen` | `color2` | Green |
| `colYellow` | `color3` | Yellow |
| `colRed` / `colError` | `color1` | Red / error background |

#### Verify dynamic theming is working

```bash
# Check pywal generated the file
cat ~/.cache/wal/colors.json | jq .

# Inspect the currently-applied palette (debug snapshot)
cat ~/.config/quickshell/config/ColorsWal.qml
```

> **Note:** `jq` is required for `wal-to-qml.sh`. If missing, dynamic theming
> still works (native QML parsing) — only the `ColorsWal.qml` export is skipped.

---

### ✨ Visual effects (Glow & Blur) — detailed walkthrough

Version 0.4.0 introduces three reusable components in `components/` for modern
visual effects — glowing halos and "frosted glass" blur — without heavy external
dependencies (built on `QtQuick.Effects.MultiEffect`, included with `qt6-declarative`).

#### `GlowRect` — static glow

A colored, blurred halo around an element, fading in/out smoothly. Used wherever
an "active" state needs visual emphasis.

```qml
GlowRect {
    anchors.fill: someToggle
    active:    someToggle.active
    glowColor: Colors.colAccent
    intensity: 0.45
}
```

#### `BlurPanel` — frosted glass background

A semi-transparent, blurred background tinted with `Colors.colSurface`
(so it's **compatible with dynamic pywal theming**). Used as the
**ControlCenter** background.

```qml
BlurPanel {
    anchors.fill: parent
    radius: Sizes.radius
    tintAlpha: 0.92

    ColumnLayout {
        // your content here
    }
}
```

#### `PulseGlow` — animated halo (custom shader)

The most advanced component: a **pulsing** glowing ring driven by a custom
GLSL shader (`assets/shaders/pulseglow.frag`).

**Two-tier behavior:**

- **With compiled shader** (`pulseglow.frag.qsb` present): smooth, GPU-driven
  pulsing animation.
- **Without compiled shader** (default): `PulseGlow` automatically falls back
  to `GlowRect` — static halo, no errors, no black screen.

**Compiling the shader (optional):**

```bash
# Requires qt6-shadertools (qsb)
qsb --glsl "100 es,120,150" \
    -o ~/.config/quickshell/assets/shaders/pulseglow.frag.qsb \
    ~/.config/quickshell/assets/shaders/pulseglow.frag
```

Once compiled, **no restart needed** — `PulseGlow` detects the file the next
time the component is shown.

**Where are these effects currently used?**

| Component | Location | Effect |
| --- | --- | --- |
| `PulseGlow` | `CCToggle` (active WiFi/BT/DND/Night) | Pulsing colored halo behind the active toggle |
| `BlurPanel` | `ControlCenter` | Blurred tinted background, replaces flat color |
| `PulseGlow` | `NotificationItem` (critical urgency) | Pulsing red halo around the toast |

---

### 🎵 The MediaControl widget — detailed walkthrough

If you're listening to music with **Spotify**, **mpv**, **VLC**, or even an audio
tab in **Firefox/Chromium**, a small player widget appears automatically in the bar,
right after the workspace indicators.

#### How does it work?

The widget relies on **MPRIS** (Media Player Remote Interfacing Specification),
a DBus standard implemented by most Linux media players. Behind the scenes,
QuickShell calls `playerctl` once per second to retrieve:

- the current track title;
- the artist;
- the playback state (playing / paused);
- the name of the active player.

#### What shows up in the bar?

```text
 ⏮  ⏯  ⏭   Track title — Artist
```

| Element | Action |
| --- | --- |
| ⏮ (previous) | `playerctl previous` — go to previous track |
| ⏯ (play/pause) | `playerctl play-pause` — toggles playback, icon highlighted when playing |
| ⏭ (next) | `playerctl next` — go to next track |
| Title — artist text | Auto-truncated if too long (max ~220px) |

#### What if nothing is playing?

**The widget disappears entirely.** No greyed-out icons, no reserved space:
if `playerctl` finds no active MPRIS player, the widget collapses to zero width
and takes no room in the bar. As soon as a player starts, it reappears
automatically (within 1 second, the polling interval).

#### Tested / compatible players

- **Spotify** (official Linux client) ✅
- **mpv** — requires `--input-ipc-server` or the `mpris` plugin enabled ✅
- **VLC** — MPRIS enabled by default on most distributions ✅
- **Firefox / Chromium** — tabs playing audio/video ✅
- Any other MPRIS2-compatible player

#### Widget-specific troubleshooting

If the widget never appears while music is playing:

```bash
# Check that playerctl detects the player
playerctl status

# List all active MPRIS players
playerctl -l
```

If `playerctl -l` is empty while Spotify/mpv is playing, the player is not
exposing its MPRIS interface — check its configuration or plugins.

---

### 🎛️ Control Center — detailed walkthrough

Open the control center by clicking the `󰍜` icon at the top-right of the bar.
Close it by clicking again or pressing `Esc`.

It contains four sections:

**1. Toggles** — a row of 4 square buttons:

| Button | Action | System command |
| --- | --- | --- |
| 󰤨 Wi-Fi | Enable / disable WiFi | `nmcli radio wifi on/off` |
| 󰂯 BT | Enable / disable Bluetooth | `bluetoothctl power on/off` |
| 󰂛 DND | Do Not Disturb (mutes notifications) | Internal QML state |
| 󰌵 Night | Night mode — blue light filter | `hyprsunset -t 3500` |

**2. Sliders** — two drag bars:

- **Volume**: drag to adjust; click the icon to mute/unmute
- **Brightness**: drag to adjust (laptop only)

**3. Network info** — current WiFi SSID + local IP address

**4. System actions** — three buttons: Power off / Reboot / Log out

---

### 🔧 Customization

#### Change colors

Edit `~/.config/quickshell/config/Colors.qml`:

```qml
readonly property color colBg:      "#282c38"  // bar background
readonly property color colFg:      "#cad3f5"  // primary text
readonly property color colAccent:  "#8aadf4"  // active buttons, slider cursor
readonly property color colGreen:   "#a6da95"  // battery, confirmations
readonly property color colYellow:  "#eed49f"  // warnings, night mode
```

Save the file, then reload:

```bash
~/.config/quickshell/scripts/reload.sh
```

#### Change bar height

Edit `~/.config/quickshell/config/Sizes.qml`:

```qml
readonly property int barHeight:  40   // height in pixels
readonly property int barSpacing: 12   // spacing between widgets
```

#### Regenerate colors from a new wallpaper

```bash
~/.config/quickshell/scripts/wal-gen.sh /path/to/new-wallpaper.jpg
```

---

### 🐛 Troubleshooting

| Problem | Likely cause | Solution |
| --- | --- | --- |
| Bar does not appear | QuickShell not starting | Run `quickshell` in a terminal and read the error |
| Colors look grey | `pywal` not configured | Run `wal -i /path/to/wallpaper.jpg` |
| Jerky animations | Missing Hyprland layer rules | Check `hyprland-layer-config.conf` is sourced |
| Volume unresponsive | PipeWire not running | `systemctl --user start pipewire wireplumber` |
| WiFi toggle has no effect | NetworkManager not running | `sudo systemctl start NetworkManager` |
| Brightness slider locked | `brightnessctl` missing or no permission | `sudo usermod -aG video $USER` then re-login |
| Bluetooth toggle has no effect | Bluetooth service not running | `sudo systemctl start bluetooth` |
| OSD does not appear | Layer shell conflict | Check `layerrule` entries in `hyprland-layer-config.conf` |

#### Check QuickShell is running

```bash
pgrep -a quickshell
```

#### Watch logs in real time

```bash
quickshell 2>&1 | tee /tmp/qs.log
```

---

### 🗺️ Roadmap EN

- [x] Bar — Workspaces, Clock, SystemStats
- [x] OSD — Volume & Brightness
- [x] Notifications — DBus toasts
- [x] ControlCenter — WiFi, Bluetooth, DND, Night, audio, brightness, power actions
- [x] MediaControl — MPRIS (Spotify, mpv, VLC, browsers)
- [x] pywal dynamic color reload
- [x] Custom shaders (glow & blur)

---

## 📄 License EN

MIT — see [LICENSE](LICENSE)

## 🤝 Contributing EN

Issues and PRs welcome. See [`docs/INSTALLATION.md`](docs/INSTALLATION.md) for dev setup.

---

**Author**: [valorisa](https://github.com/valorisa)
