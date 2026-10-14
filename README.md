# Gemgala User App 🎮🎉

A high-performance, feature-first clean architecture Flutter application replicating the **Gemgala - Party, Chat & Games** experience.

## ✨ Features
- **Party & Live Audio Rooms**: Multi-seat live audio rooms, host controls, real-time speaking animations, category filtering, and virtual gifting.
- **Games Module (BlockMe)**: Drag-and-drop block puzzle game with 3D embossed jelly pieces, line-clear scoring, score multiplier (`x256`), and daily/monthly prize leaderboards.
- **Moments Feed**: Social timeline with Follow/Moments/Video sub-tabs, post creator, likes/comments, and custom cat mascot empty state.
- **Messages & Direct Chat**: Categorized inbox (System messages, Stranger messages, 1-on-1 direct conversations).
- **Profile & Dual-Currency Wallet**: User badges (Country, Level, VIP, Gender/Age), Gems & Coins balance cards, recent withdrawal live ticker, and recharge promotions.

## 🏗️ Architecture
- **Pattern**: Feature-First Clean Architecture (`core`, `features/{feature_name}/{domain, data, presentation}`)
- **State Management**: Flutter BLoC (`flutter_bloc`)
- **Supported Platforms**: Android (Mobile), Windows (Desktop)

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>= 3.13.0)
- Android SDK & Studio / VS Code

### Run the app
```bash
# Get dependencies
flutter pub get

# Run on Android Emulator
flutter run -d emulator-5554

# Or run on Windows Desktop
flutter run -d windows
```
