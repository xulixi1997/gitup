# GLITCH_KATANA (INFINITY_RONIN_OMEGA)

A high-octane, cyberpunk-themed action game built with Flutter. Experience intense combat, dynamic difficulty, and a unique glitch-art aesthetic.

> **Project Status**: Fully Implemented & Playable
> **Version**: 1.5.0-RC1

## 🎮 Game Overview

GLITCH_KATANA is a fast-paced hack-and-slash game where you control a Ronin in a digital void. The game features a unique "Bullet Time" mechanic that slows down time when you stop moving, allowing for strategic planning in the heat of combat.

### Key Features

*   **100% Procedural Graphics**: Every visual element, from the grid background to the glitch effects and particle explosions, is rendered in real-time using Flutter's `CustomPainter`. No external image assets are used.
*   **Dynamic Glitch Engine**: Custom-built rendering pipeline that simulates CRT scanlines, chromatic aberration, and digital noise based on game intensity.
*   **Reactive Visuals**: The UI and game world react to your actions with screen shakes, hit stops, and particle bursts ("Juice").

## ⚔️ Combat Mechanics

*   **Bullet Time**: Reality slows to 0.3x speed when you aren't dashing. Use this to dodge complex projectile patterns.
*   **Dash & Slash**: Drag and release to dash through enemies. Dashing grants temporary invulnerability (Ghost Mode).
*   **Combo System**: Chain kills to build your Combo Rank (D to SSS). High combos trigger **Glitch Pulses** that clear enemy projectiles.
*   **Parry / Reflect**: Dash *through* enemy bullets to hack them, turning them into friendly projectiles.

## 🛰️ Systems & Progression

*   **Neural Hub (Navigation)**:
    *   **CORE**: Main dashboard with stats and quick launch.
    *   **SECTORS**: Select missions with varying threat levels and enemy types.
    *   **NODES**: Achievement map that unlocks based on your high score.
    *   **SYSTEM**: Settings for haptics and data management.
*   **Persistent Upgrades**: Collect **Data Fragments** from enemies to purchase permanent upgrades:
    *   **Max Integrity**: Increase hull strength.
    *   **Attack Damage**: Boost output.
    *   **Data Magnet**: Automatically collect XP orbs.
    *   **Sword Beam**: Fire projectiles when dashing.

## 🛠️ Technical Architecture

This project demonstrates a clean, scalable Flutter architecture:

*   **Framework**: Flutter 3.x (Dart 3.0+ features enabled)
*   **State Management**: `Provider` pattern for reactive UI and game state.
*   **Persistence**: `shared_preferences` for saving high scores, upgrades, and settings.
*   **No Code Generation**: Pure Dart code without `build_runner` or `g.dart` files, ensuring fast compilation and simple maintenance.
*   **Performance**:
    *   `const` constructors usage for widget rebuilding optimization.
    *   `CustomPainter` for high-performance 60FPS rendering.
    *   `ListView.builder` for efficient list rendering.

### Directory Structure

```
lib/
├── core/           # Constants, Utils, SettingsProvider
├── game/           # GameEngine, Loop Logic, Physics
├── models/         # Data classes (Player, Enemy, Projectile)
├── screens/        # UI Screens (Menu, Game, Upgrades)
└── widgets/        # Reusable components (GlitchScaffold)
```

## � Getting Started

1.  **Prerequisites**: Ensure you have Flutter SDK installed (Version 3.0 or higher).
2.  **Clone & Install**:
    ```bash
    git clone [repository_url]
    cd glitch
    flutter pub get
    ```
3.  **Run**:
    ```bash
    flutter run
    ```

## � Compatibility

*   **Orientation**: Locked to Portrait mode for optimal one-handed play.
*   **UI Adaptation**: Responsive layout that adapts to various screen sizes (safe areas handled).

## 📝 TODO
- [ ] **Content Expansion (Phase 3)**
    - [ ] **New Biome**: "Deep Web" - Darker aesthetic with neon-root enemies.
    - [ ] **Boss Mechanics**: Add "Glitch Clone" phase for final boss.
- [x] **Visual & Experience Polish (Phase 2)**
    - [x] **UI Overhaul**: Animated Menu Buttons with glitch effects (`MenuButton`).
    - [x] **Transitions**: Matrix-style scanline page transitions (`GlitchPageRoute`).
    - [x] **Directional Shake**: Screen shakes dynamically based on impact direction.
    - [x] **Haptics & Access**: Vibration feedback and "Reduce Flashing" mode.
    - [x] **Accessibility**: Pause/Resume functionality.
    - [x] **Onboarding**: "How to Play" tutorial overlay.

## 🏗️ Architecture

```mermaid
graph TD
    User[User Input] --> UI_Layer
    
    subgraph UI_Layer
        BootScreen
        MenuScreen
        GameScreen
        UpgradeScreen
        FragmentAssemblyScreen
        TerminalScreen
        SettingsScreen
        SystemInfoScreen
        Widgets[MenuButton / GlitchPageRoute]
        Overlays[PauseMenu / TutorialOverlay]
    end
    
    subgraph Logic_Layer
        GameEngine[GameEngine (Provider)]
        WaveManager
        FragmentManager
        SettingsProvider
    end
    
    subgraph Data_Layer
        Player
        Enemy
        Projectile
        Fragment
        SharedPreferences
    end
    
    subgraph Render_Layer
        GamePainter[CustomPainter]
        GlitchEffects
    end
    
    BootScreen --> MenuScreen
    MenuScreen --> GameEngine
    MenuScreen --> Widgets
    SettingsScreen --> SystemInfoScreen
    GameScreen --> GameEngine
    GameScreen --> GamePainter
    GameScreen --> Overlays
    FragmentAssemblyScreen --> FragmentManager
    GameEngine --> WaveManager
    GameEngine --> FragmentManager
    GameEngine --> Player
    GameEngine --> Enemy
    GameEngine --> Projectiles
    GameEngine --> SharedPreferences
    GamePainter --> GameEngine
```

## 📅 Changelog

### v1.5.0-RC1 (Release Candidate)
- **Compliance**: Implemented `SystemInfoScreen` consolidating Manual, Legal, and Credits.
- **Compliance**: Verified strict "No Audio/No Push" policy.
- **UX**: Enhanced Splash Screen transition.
- **System**: Updated versioning to 1.5.0-RC1.

### v1.4.1-DEV (UX Polish)
- **UX**: Implemented Game Pause system with "Abort Mission" option.
- **Onboarding**: Added interactive "Tutorial Overlay" explaining core mechanics (Dash, Time, Parry).
- **System**: Added persistence for tutorial completion state.
- **Visuals**: Styled new overlays with glitch aesthetics and animations.

### v1.4.0-DEV (Visual Polish)
- **Visuals**: Implemented "Matrix-style" scanline page transitions (`GlitchPageRoute`).
- **UI**: Added animated "Glitch Buttons" with reactive feedback (`MenuButton`).
- **Polish**: Added Directional Screen Shake (Screen moves based on impact source).
- **Refactor**: Modularized `MenuScreen` widgets for better maintainability.
- **Fixes**: Resolved multiple linter errors and widget tree issues in Menu.

### v1.3.3-DEV
- **System**: Implemented "The Terminal" - CLI for injecting custom game rules (spawn_rate, speed_mult).
- **System**: Added "Fragment Assembly System" (Crafting passive mods like SpeedHack, LogicGate).
- **UX**: Added Haptic Feedback (Vibration) for combat impact (Hits, Kills, Parry).
- **UI**: Improved Safe Area adaptation for notched devices (iPhone X/15+).
- **Polish**: Integrated "LogicGate" Mod (Defense Chance) with visual feedback.
- **Access**: Added "Reduce Flashing" mode and iPad layout optimizations.

### v1.3.2-DEV
- **System**: Added "Fragment Assembly System".
    - Collect fragments (Memory, Processor, Kernel, Glitch) from enemies.
    - Assemble fragments into passive "Mods" (Cheat Codes).
    - Added `FragmentAssemblyScreen` for crafting.
- **UI**: Added "Floating Text" feedback for item drops and damage.

### v1.3.1-DEV
- **Architecture**: Decoupled Wave Logic into `WaveManager` for better modularity and testing.
- **Refactor**: Cleaned up `GameEngine` legacy wave code.

### v1.3.0-BETA
- **System**: Implemented "Corruption Protocol" (Risk/Reward Difficulty Modifiers).
- **Boss**: Added "Mirror Ronin" (AI mimics player movement, Stalk/Charge/Dash).

### v1.2.1-BETA
- **System**: Added "Glitch-Stance System" (Switchable Weapon Forms: Katana/Heavy/Dual).

### v1.2.0 (Current)
- **New Boss**: Added "Data Worm" (Multi-segment entity).
    - Uses procedural animation (Inverse Kinematics) for snake-like movement.
    - **Mechanic**: Head is invulnerable; players must destroy body segments individually.
    - **Visuals**: Segments render as data blocks that shatter into glitch particles.
- **Engine**: Enhanced collision detection system to support multi-hitbox enemies.

### v1.1.1
- **Boss Mechanics**: Added "Phase System". Boss enters Enraged state at 50% HP (Red color, 2x fire rate, faster movement).
- **Visuals**: Added specific glitch rendering for Enraged Bosses.

### v1.1.0
- **New Mode**: Added "Boss Rush Protocol" - Face endless waves of increasing difficulty bosses.
- **New Enemies**:
    - **Teleporter**: Vanishes and ambushes from random angles (Sector 3+).
    - **Orbiter**: Circles the player and fires inward (Sector 5+).
- **Combat**: Implemented "Just Defend" (Perfect Parry). Dashing into a projectile within 0.2s reflects it with double damage.
- **UI**: Added Warning-style button for Boss Rush in Main Menu.

### v1.0.9
- **Compliance**: Removed all Audio/Sound code to strictly adhere to "No Sound" policy.
- **Refactor**: Cleaned up SettingsProvider and SettingsScreen.

### v1.0.8-STABLE
- **Core**: Full gameplay loop implementation (Start -> Play -> GameOver -> Restart).
- **Visuals**: Added "Blue Screen of Death" Game Over screen.
- **Systems**: Implemented Persistent Upgrades and High Score sync.

---

*System initialized. Welcome to the void, Ronin.*
